public with sharing class PlantUmlErdDiagram {

    private transient Map<SObjectType, List<ChildRelationship>> selected;

    public Boolean showLabels { get; set; }
    public Boolean showFields { get; set; }
    public Boolean hideStandard { get; set; }
    public Boolean showRelationNames { get; set; }

    public String plantUMLText { get; private set; }
    
    
    // CONSTRUCTOR

    public PlantUmlErdDiagram() {
        showLabels = false;
        showFields = false;
        hideStandard = false;
        showRelationNames = false;
    }


    // PUBLIC

    public void setTypes(Set<String> types) {
        prepare(types);
        plantUMLText = render();
    }


    // PRIVATE 

    private void prepare(Set<String> types) {
        selected = new Map<SObjectType, List<ChildRelationship>>();

        for(String name : types) {
            SObjectType type = type(name);
            selected.put(type, type.getDescribe().getChildRelationships());
        }
    }


    private String render() {
        String result = '\nskinparam roundCorner 10 \nset namespaceSeparator __ \nhide circle ';

        if(!showFields) {
            result += '\nhide members';
        }

        result += render(selected);

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
        DescribeSObjectResult describe = type.getDescribe();
        String label = (showLabels) ? '<<' + describe.getLabel() + '>>' : '';

        return String.format('\n\n\tclass {0}{1} {2}', 
                                new List<String>{ describe.getLocalName(), label, translateFields(describe)});
    }
    

    private String translate(DescribeSObjectResult describe, ChildRelationship relationship) {
        String result = '\n\t' + describe.getLocalName() + (relationship.isCascadeDelete() ? ' o-- ' : ' *-- ') + relationship.getChildSObject().getDescribe().getName();

        if(showRelationNames) {
            result +=  ': < ' + removeSuffix('' + relationship.getField() );
        }
        
        return result;
    }
    

    private String removeSuffix(String original) {
        return (original == null) ? original : original.removeEnd('__c').removeEnd('__r');
    }
        
     
    private String translateFields(DescribeSObjectResult describe) {
        String result = ' {';

        Map<String, SObjectField> fields = describe.fields.getMap();
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
