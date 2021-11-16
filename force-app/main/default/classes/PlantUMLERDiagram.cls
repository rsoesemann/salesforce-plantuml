public with sharing class PlantUMLERDiagram {

    public String plantUMLText { get; private set; }

    public Boolean showFields { get; set; }
    public Boolean hideStandard { get; set; }
    
    private Set<String> sobjectNames;
    private Map<String, Map<String, Boolean>> fieldsCache;
    
    
    public PlantUMLERDiagram() {
        this.plantUMLText = 'skinparam roundCorner 10\n';
        this.showFields = false;
        this.hideStandard = true;
    }
  
    
    public void setObjects(Set<String> sobjectNames) {
    	this.sobjectNames = sobjectNames;
    	
        if(!sobjectNames.isEmpty()) {
            for(String objectName : sobjectNames) {
                this.plantUMLText += translateSObject(objectName);
            }
        }
    }
    
    
    public String translateSObject(String objectName) {  
        String text = '';
                
        // Extract namespace from fully qualified name
        String namespace = '';
        List<String> fragments = objectName.split('__');
        if(fragments.size()==3) {
            namespace = fragments.get(0);
        }

        // Remove namespace suffix when current object is Managed in this org
        if(Schema.getGlobalDescribe().get(objectName) == null) {
            objectName = objectName.removeStart(namespace + '__');
        }
        DescribeSObjectResult describe = Schema.getGlobalDescribe().get(objectName).getDescribe();   
        
        text += '\nclass ' + objectName + ' as "' + describe.getLabel() + '"' + (describe.isCustom() ? '' : ' << (S,red) >>') + '{\n' +
                translateObjectAttributes(describe) +
                '\n}';
               
        // Translate child relationships
        for(ChildRelationship relationship : describe.getChildRelationships()) {
            text += translateChildRelationship(describe, relationship);
        }
        
        return text;
    }
    
    private String translateObjectAttributes(DescribeSObjectResult objectDescribe) {
        String text = '';
        
        if(this.showFields) {
            text += translateFields(objectDescribe);
        }
                
        return text;
    }
    
    
    private String translateChildRelationship(DescribeSObjectResult objectDescribe, ChildRelationship relationship) {
        String text = '';
        
        DescribeSObjectResult child = relationship.getChildSObject().getDescribe();
        String objectName = objectDescribe.getName();
        String childName = child.getName();
        
        if(isRelevantRelationship(objectName, childName)) {
            text += '\n' + objectName + ' ' + (relationship.isCascadeDelete() ? ' o-- ' : ' *-- ') + childName + ' : < ' + relationship.getField();
        }
        
        return text;
    }
    
    
    private Boolean isRelevantRelationship(String objectName, String childName) {       
        return this.sobjectNames.contains(childName);
    }
        
     
    private String translateFields(DescribeSObjectResult objectDescribe) {
        String result = '';
        
        for(SObjectField field : objectDescribe.fields.getMap().values()) {
            if(field.getDescribe().isCustom() || !hideStandard) {
                result += '\n' + field;
            }
        }
        
        return result;
    } 
    
    
    private String translateRelatedSObjects(List<SObject> related, String sectionLabel) {
        String result = '';
        
        if(related != null) {
            if(!related.isEmpty()) {
                result += '\n-- ' + sectionLabel + ' --';
            }
            
            for(SObject o : related) {
                result += '\n' + o.get('Name');
            }
        }     
        return result;   
    }
}