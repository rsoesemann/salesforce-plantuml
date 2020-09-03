public class PlantUMLERDiagram {

    public String plantUMLText { get; private set; }

    public String profile { get; set; }
    public String permSet { get; set; }
    public Boolean showRelatedMetadata { get; set; }
    public Boolean showSelfReferences { get; set; }
    public Boolean showFields { get; set; }
    
    
    private Set<String> sobjectNames;
    private Map<String, Map<String, Boolean>> fieldsCache;
    private Map<String, List<RecordType>> recordTypesCache; 
    private Map<String, List<ApexTrigger>> triggersCache;
    private Map<String, List<ApexPage>> pagesCache;
    
    
    public PlantUMLERDiagram() {
        this.plantUMLText = '';
        this.showFields = false;
        this.showRelatedMetadata = false;
    	this.showSelfReferences = false;
    }
  
    
    public void setObjects(Set<String> sobjectNames) {
    	this.sobjectNames = sobjectNames;
    	
        if(!sobjectNames.isEmpty()) {
            this.plantUMLText = this.showFields ? '' : 'hide members\nset namespaceSeparator __\n';
            
            // Bulkfetch required schema information
            if(showFields) {
                this.fieldsCache = getFieldPermsOfAllObjects();
            }
            if(showRelatedMetadata) {
                this.recordTypesCache = getRecordTypesOfAllObjects();
                this.triggersCache = getTriggersOfAllObjects();
                this.pagesCache = getPagesOfAllObjects();
            }
        
            // Generate UML description
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
        Schema.DescribeSObjectResult objectDescribe = Schema.getGlobalDescribe().get(objectName).getDescribe();   
        
        text += '\nclass ' + objectName.removeEnd('__c') + (objectDescribe.isCustom() ? '' : ' << (S,red) >>') + '{\n' +
                translateObjectAttributes(objectDescribe) +
                '\n}';
               
        // Translate child relationships
        for(Schema.ChildRelationship relationship : objectDescribe.getChildRelationships()) {
            text += translateChildRelationship(objectDescribe, relationship);
        }
        
        return text;
    }
    
    private String translateObjectAttributes(Schema.DescribeSObjectResult objectDescribe) {
        String text = '';
        
        if(this.showFields) {
            text += translateFields(objectDescribe);
        }
                
        if(this.showRelatedMetadata) {
            text += translateRecordTypes(objectDescribe);
            text += translatePages(objectDescribe);
            text += translateTriggers(objectDescribe);                   
        }
        
        return text;
    }
    
    
    private String translateChildRelationship(Schema.DescribeSObjectResult objectDescribe, Schema.ChildRelationship relationship) {
        String text = '';
        
        Schema.DescribeSObjectResult child = relationship.getChildSObject().getDescribe();
        String objectName = objectDescribe.getName();
        String childName = child.getName();
        
        if(isRelevantRelationship(objectName, childName)) {
            text += '\n' + objectName.removeEnd('__c') + ' ' + (relationship.isCascadeDelete() ? ' o-- "Detail" ' : ' *-- "many" ') + childName.removeEnd('__c');
        }
        
        return text;
    }
    
    
    private Boolean isRelevantRelationship(String objectName, String childName) {       
        return this.sobjectNames.contains(childName) && (childName != objectName || this.showSelfReferences);
    }
    
    
    private Map<String, Map<String, Boolean>> getFieldPermsOfAllObjects() {
        Map<String, Map<String, Boolean>> objectPerms = new Map<String, Map<String, Boolean>>();

        for(PermissionSet ps : [SELECT (SELECT SObjectType, Field, PermissionsEdit FROM FieldPerms WHERE PermissionsRead = true AND SObjectType IN :this.sobjectNames) 
                                FROM PermissionSet
                                WHERE Name = :permSet OR Profile.Name = :profile]) {

            for(FieldPermissions fp : ps.FieldPerms) {
                Map<String, Boolean> fieldPerms = objectPerms.get(fp.SObjectType);
                
                if(fieldPerms == null) {
                    fieldPerms = new Map<String, Boolean>();
                    objectPerms.put(fp.SObjectType, fieldPerms);
                }
                
                String fieldName = fp.Field.removeStart(fp.SObjectType + '.');  // NS_OBJECT__c.NS_FIELD__c -> NS_FIELD__c
                String namespace = fieldName.split('__').size() == 3 ? fieldName.substring(0, fieldName.indexOf('__')): '';
                fieldName = fieldName.removeStart(namespace + '__');
                fieldPerms.put(fieldName, fp.PermissionsEdit);
            }
        }
        
        return objectPerms;
    }
        
     
    private String translateFields(Schema.DescribeSObjectResult objectDescribe) {
        String result = '';
        
        Map<String, Boolean> fieldPerms = this.fieldsCache.get(objectDescribe.getName());
        
        if(fieldPerms != null) {
            for(String field : this.fieldsCache.get(objectDescribe.getName()).keySet()) {
                Boolean isEditable = this.fieldsCache.get(objectDescribe.getName()).get(field);
                result += '\n' + (isEditable ? '+' : '-') + field ;
            }
        }
        
        return result;
    } 
    
    
    private Map<String, List<RecordType>> getRecordTypesOfAllObjects() {
        Map<String, List<RecordType>> resultMap = new Map<String, List<RecordType>>();

        for(RecordType rt : [SELECT Name, SObjectType FROM RecordType WHERE SObjectType IN :this.sobjectNames]) {
            List<RecordType> rtList = resultMap.get(rt.SObjectType);
            if(rtList == null) {
                rtList = new List<RecordType>();
                resultMap.put(rt.SObjectType, rtList);
            }
            rtList.add(rt);
        }
        
        return resultMap;
    }
    
            
    private Map<String, List<ApexTrigger>> getTriggersOfAllObjects() {
        Map<String, List<ApexTrigger>> resultMap = new Map<String, List<ApexTrigger>>();

        for(ApexTrigger t : [SELECT Name, TableEnumOrId FROM ApexTrigger WHERE TableEnumOrId IN :this.sobjectNames]) {
            List<ApexTrigger> tList = resultMap.get(t.TableEnumOrId);
            if(tList == null) {
                tList = new List<ApexTrigger>();
                resultMap.put(t.TableEnumOrId, tList);
            }
            tList.add(t);
        }
        return resultMap;
    }        
    
 
    private Map<String, List<ApexPage>> getPagesOfAllObjects() {
        Map<String, List<ApexPage>> resultMap = new Map<String, List<ApexPage>>();
        
        for(ApexPage p : [SELECT Name, NamespacePrefix, ControllerKey FROM ApexPage WHERE ControllerType = '1']) {
            // Not able to filter query by  ' AND ControllerKey IN :this.relevantObjects' as ControllerKey stores local names without namespaces
            String fullName = (p.NamespacePrefix != null) ? p.NamespacePrefix + '__' + p.ControllerKey : p.ControllerKey;
            if(this.sobjectNames.contains(fullName)) {
                List<ApexPage> pList = resultMap.get(p.ControllerKey);
                if(pList == null) {
                    pList = new List<ApexPage>();
                    resultMap.put(p.ControllerKey, pList);
                }
                pList.add(p);
            }
        }
        
        return resultMap;
    }
  
    
    private String translateTriggers(Schema.DescribeSObjectResult objectDescribe) {
        List<ApexTrigger> triggers = this.triggersCache.get(objectDescribe.getName());
        return translateRelatedSObjects(triggers, 'Triggers');
    }
    
    private String translateRecordTypes(Schema.DescribeSObjectResult objectDescribe) {
        List<RecordType> recordTypes = this.recordTypesCache.get(objectDescribe.getName());
        return translateRelatedSObjects(recordTypes, 'Record Types');
    }
    
    private String translatePages(Schema.DescribeSObjectResult describe) {
        List<ApexPage> pages = this.pagesCache.get(describe.getLocalName());
        return translateRelatedSObjects(pages, 'Pages');
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