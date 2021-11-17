public with sharing class PlantUMLERDiagram {

    private transient Map<SObjectType, List<ChildRelationship>> selected;
    private transient Map<SObjectType, List<ChildRelationship>> parents;

    public Boolean showFields { get; set; }
    public Boolean hideStandard { get; set; }
    public Boolean showRelationNames { get; set; }
    public Boolean autoAddParents { get; set; }

    public String plantUMLText { get; private set; }
    
    
    // CONSTRUCTOR

    public PlantUMLERDiagram() {
        showFields = false;
        hideStandard = true;
        showRelationNames = false;
        autoAddParents = false;
    }
  

    // PUBLIC

    public void setObjects(Set<String> typeNames) {
        prepare(typeNames);
        plantUMLText = render();
    }


    // PRIVATE 

    private void prepare(Set<String> typeNames) {
        selected = new Map<SObjectType, List<ChildRelationship>>();
        parents = new Map<SObjectType, List<ChildRelationship>>();

        for(String name : typeNames) {
            SObjectType type = type(name);
            selected.put(type, type.getDescribe().getChildRelationships());

            if(autoAddParents) {
                for(SObjectField field: type.getDescribe().fields.getMap().values()) {
                    if(field.getDescribe().getType() == Schema.DisplayType.Reference) {
                        SObjectType parent = field.getDescribe().getReferenceTo()[0];
                        parents.put(type, parent.getDescribe().getChildRelationships());
                    }
                }
            }
        }
    }


    private String render() {
        String result = '\tskinparam roundCorner 10';

        if(autoAddParents) {
            result = '\npackage "Selected" {\n' + render(selected) + '\n}\n';
            result += render(parents);
        }
        else {
            result += render(selected);
        }

        return result;
    }



    private String render(Map<SObjectType, List<ChildRelationship>> typeMap) {
        String result = '';

        for(SObjectType type : typeMap.keySet()) {
            result += translate(type);

            for(ChildRelationship relationship : typeMap.get(type)) {
                if(selected.containsKey(relationship.getChildSObject())) {
                    result += translate(type.getDescribe(), relationship);
                }
            }
        }

        return result;
    }


    private SObjectType type(String objectName) {
        String namespace = '';
        List<String> fragments = objectName.split('__');
        if(fragments.size()==3) {
            namespace = fragments.get(0);
        }

        if(Schema.getGlobalDescribe().get(objectName) == null) {
            objectName = objectName.removeStart(namespace + '__');
        }

        return Schema.getGlobalDescribe().get(objectName);   
    }


    private String translate(SObjectType type) {  
        String result = '';

        DescribeSObjectResult describe = type.getDescribe();
                
        result += String.format('\n\n\tclass "{0}" as {1}{2}', new List<String>{ 
                    describe.getLabel(), describe.getLocalName(), translateFields(describe)});
               
        return result;
    }
    

    private String translate(DescribeSObjectResult describe, ChildRelationship relationship) {
        String result = '\n\t' + describe.getLocalName() + (relationship.isCascadeDelete() ? ' o-- ' : ' *-- ') + relationship.getChildSObject().getDescribe().getName();

        if(showRelationNames) {
            result +=  ': < ' + removeSuffix('' + relationship.getField() ) + ' (' + removeSuffix( relationship.getRelationshipName() ) + ')';
        }
        
        return result;
    }
    

    private String removeSuffix(String original) {
        return (original == null) ? original : original.removeEnd('__c').removeEnd('__r');
    }
        
     
    private String translateFields(DescribeSObjectResult objectDescribe) {
        String result = ' {';

        Map<String, SObjectField> fields = objectDescribe.fields.getMap();
        List<String> ordered = new List<String>(fields.keySet());
        ordered.sort();
        
        if(showFields && !fields.isEmpty()) {
            for(String name : ordered) {
                SObjectField field = fields.get(name);

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