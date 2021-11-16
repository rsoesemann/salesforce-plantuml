public with sharing class PlantUMLERDiagram {

    private Set<String> sobjectNames;
    private Map<String, Map<String, Boolean>> fieldsCache;

    public String plantUMLText { get; private set; }
    public Boolean showFields { get; set; }
    public Boolean hideStandard { get; set; }
    
    
    // CONSTRUCTOR

    public PlantUMLERDiagram() {
        showFields = false;
        hideStandard = true;
    }
  

    // PUBLIC

    public void setObjects(Set<String> sobjectNames) {
        plantUMLText = 'skinparam roundCorner 10\n';

        this.sobjectNames = sobjectNames;

        for(String objectName : sobjectNames) {
            plantUMLText += translateSObject(objectName);
        }
    }
    
    
    public String translateSObject(String objectName) {  
        String result = '';
                
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
        
        result += '\nclass ' + objectName + ' as "' + describe.getLabel() + '"' + (describe.isCustom() ? '' : ' << (S,red) >>') + '{\n' +
                translateObjectAttributes(describe) +
                '\n}';
               
        // Translate child relationships
        for(ChildRelationship relationship : describe.getChildRelationships()) {
            result += translateChildRelationship(describe, relationship);
        }
        
        return result;
    }
    

    // PRIVATE 

    private String translateObjectAttributes(DescribeSObjectResult objectDescribe) {
        String result = '';
        
        if(showFields) {
            result += translateFields(objectDescribe);
        }
                
        return result;
    }
    
    
    private String translateChildRelationship(DescribeSObjectResult objectDescribe, ChildRelationship relationship) {
        String result = '';
        
        DescribeSObjectResult child = relationship.getChildSObject().getDescribe();
        String objectName = objectDescribe.getName();
        String childName = child.getName();
        
        if(isRelevantRelationship(objectName, childName)) {
            result += '\n' + objectName + ' ' + (relationship.isCascadeDelete() ? ' o-- ' : ' *-- ') + childName + ' : < ' + relationship.getField() + ' (' + relationship.getRelationshipName() + ')';
        }
        
        return result;
    }
    
    
    private Boolean isRelevantRelationship(String objectName, String childName) {       
        return sobjectNames.contains(childName);
    }
        
     
    private String translateFields(DescribeSObjectResult objectDescribe) {
        String result = '';
        
        for(SObjectField field : objectDescribe.fields.getMap().values()) {
            if(field.getDescribe().isCustom() || !hideStandard) {
                result += '\n' + field + ' : ' + field.getDescribe().getType();
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