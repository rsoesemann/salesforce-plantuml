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
        plantUMLText = '\tskinparam roundCorner 10';

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
        
        result += String.format('\n\n\tclass "{0}" as {1}{2}{3}', new List<String>{ 
                describe.getLabel(), objectName, (describe.isCustom() ? '' : '<<(S,red)>>'), translateFields(describe)});
               
        for(ChildRelationship relationship : describe.getChildRelationships()) {
            result += translateChildRelationship(describe, relationship);
        }
        
        return result;
    }
    

    // PRIVATE 

    private String translateChildRelationship(DescribeSObjectResult objectDescribe, ChildRelationship relationship) {
        String result = '';
        
        DescribeSObjectResult child = relationship.getChildSObject().getDescribe();
        String objectName = objectDescribe.getName();
        String childName = child.getName();
        
        if(isRelevantRelationship(objectName, childName)) {
            result += '\n\t' + objectName + ' ' + (relationship.isCascadeDelete() ? ' o-- ' : ' *-- ') + childName + ' : < ' + relationship.getField() + ' (' + relationship.getRelationshipName() + ')';
        }
        
        return result;
    }
    
    
    private Boolean isRelevantRelationship(String objectName, String childName) {       
        return sobjectNames.contains(childName);
    }
        
     
    private String translateFields(DescribeSObjectResult objectDescribe) {
        String result = ' {';

        List<SObjectField> fields = objectDescribe.fields.getMap().values();
        
        if(showFields && !fields.isEmpty()) {
            for(SObjectField field : fields) {
                if(field.getDescribe().isCustom() || !hideStandard) {
                    result += '\n\t\t' + field + ' : ' + field.getDescribe().getType();
                }
            }

            result += '\n\t}';
        }
        else {
            result += '}';
        }
        
        return result;
    } 
}