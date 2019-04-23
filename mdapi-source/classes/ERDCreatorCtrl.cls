public with sharing class ERDCreatorCtrl {
	
	public PlantUMLERDiagram erDiagram { get; set; }
    public SelectOption[] accessibleSObjects { get; set; }
    public SelectOption[] selectedSObjects { get; set; }

     
    public ERDCreatorCtrl() {
        selectedSObjects = new List<SelectOption>();
        accessibleSObjects = getAccessibleSObjects();
        
		erDiagram = new PlantUMLERDiagram();
		erDiagram.profile = 'System Administrator';
    }
    
    
    public List<SelectOption> getProfiles() {    
        List<SelectOption> profiles = new List<SelectOption>();
        
        for(Profile pr : [SELECT Name FROM Profile]) {
            profiles.add(new SelectOption(pr.Name, pr.Name));
        }
        
        SelectOptionSorter.sort(profiles, SelectOptionSorter.FieldToSort.Label);
        profiles.add(new SelectOption('NONE', ' - '));
        
        return profiles;
    }
    
    
    public List<SelectOption> getPermSets() {
        List<SelectOption> permSets = new List<SelectOption>();
        
        String profileName = (this.erDiagram.profile == 'NONE') ? null : this.erDiagram.profile;
        for(PermissionSet ps : [SELECT Name, Label FROM PermissionSet WHERE Profile.Name = :profileName AND (NOT Name LIKE 'X00%')]) {
            permSets.add(new SelectOption(ps.Name, ps.Name));
        }
        
        SelectOptionSorter.sort(permSets, SelectOptionSorter.FieldToSort.Label);
        
        return permSets;    
    }
    
    
    public PageReference doCreateDiagram() {
        
        if(selectedSObjects.isEmpty()) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Info, 'Please select at least one sobject.');
            ApexPages.addMessage(msg);
        }
        else {
        	Set<String> sobjectNames = new Set<String>();
        	for(SelectOption so : selectedSObjects) {
        		sobjectNames.add(so.getValue());
        	}
        	
            this.erDiagram.setObjects(sobjectNames);
        }
        return null;
    }
    
    
    // PRIVATE METHODS
    
    private List<SelectOption> getAccessibleSObjects(){
        List<SelectOption> accessibleSObjects = new List<SelectOption>();
    
        for(Schema.SObjectType type : Schema.getGlobalDescribe().values()) {
            Schema.DescribeSObjectResult objectDescribe = type.getDescribe();
            
            if(isAllowedObject(objectDescribe)) {
                String name = objectDescribe.getName();
                accessibleSObjects.add(new SelectOption(name, name));
            }
        }
        SelectOptionSorter.sort(accessibleSObjects, SelectOptionSorter.FieldToSort.Label);
        
        return accessibleSObjects;
    }
    
    
    private Boolean isAllowedObject(Schema.DescribeSObjectResult objectDescribe) {
        String name = objectDescribe.getName();
        return objectDescribe.isAccessible() 
               && !name.endsWith('History') 
               && !name.endsWith('Feed') 
               && !name.endsWith('Tag') 
               && !name.endsWith('Share') ;   
    }
    
    
    // TEST METHODS
    
    static testmethod void testUIIsPopulatedOnConstructor() {
        // Setup
        Test.setCurrentPageReference(Page.erdCreator);
        
        // Execute
        ERDCreatorCtrl ctrl = new ERDCreatorCtrl();
        
        // Verify
        System.assertNotEquals(0, ctrl.accessibleSObjects.size());
        System.assertNotEquals(null, ctrl.getPermSets());
        System.assertNotEquals(0, ctrl.getProfiles().size());
        System.assertEquals(null, ctrl.erDiagram.permSet);
        System.assertEquals('System Administrator', ctrl.erDiagram.profile);
        System.assertEquals(0, ctrl.selectedSObjects.size());
    }
    
    
    static testmethod void errorShownOnCreateWithNoSelectedObject() {
        // Setup 
        Test.setCurrentPageReference(Page.erdCreator);
        ERDCreatorCtrl pageCtrl = new ERDCreatorCtrl();
        
        // Execute
        pageCtrl.doCreateDiagram();
        
        // Verify
        System.assert(ApexPages.hasMessages());
    }
    
    
    static testmethod void noErrorOnCreateWithSelectedObject() {
        // Setup 
        Test.setCurrentPageReference(Page.erdCreator);
        ERDCreatorCtrl pageCtrl = new ERDCreatorCtrl();
        
        // Execute
        pageCtrl.selectedSObjects.add(pageCtrl.accessibleSObjects.get(0));
        pageCtrl.doCreateDiagram();
        
        // Verify
        System.assert(!ApexPages.hasMessages());
    }
}