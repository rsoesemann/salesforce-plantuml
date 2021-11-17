public with sharing class ErdDiagramCreatorCtrl {
	
	public PlantUMLERDiagram erDiagram { get; set; }
    public SelectOption[] accessibleSObjects { get; set; }
    public SelectOption[] selectedSObjects { get; set; }

    // CONSTRUCTOR
     
    public ErdDiagramCreatorCtrl() {
        selectedSObjects = new List<SelectOption>();
        accessibleSObjects = getAccessibleSObjects();
        
		erDiagram = new PlantUMLERDiagram();
    }
    
    // PUBLIC
    
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
        	
            erDiagram.setObjects(sobjectNames);
        }
        return null;
    }
    
    
    // PRIVATE 
    
    private List<SelectOption> getAccessibleSObjects(){
        List<SelectOption> accessibleSObjects = new List<SelectOption>();
    
        for(Schema.SObjectType type : Schema.getGlobalDescribe().values()) {
            Schema.DescribeSObjectResult objectDescribe = type.getDescribe();
            
            String name = objectDescribe.getName();
            String label = objectDescribe.getLabel();
            accessibleSObjects.add(new SelectOption(name, name +  + ' - ' + label));
        }

        SelectOptionSorter.sort(accessibleSObjects, SelectOptionSorter.FieldToSort.Label);
        
        return accessibleSObjects;
    }
    
    
    private Boolean isAllowedObject(Schema.DescribeSObjectResult objectDescribe) {
        String name = objectDescribe.getName();
        return objectDescribe.isCustom() || !erDiagram.hideStandard
                && !name.endsWith('History') 
                && !name.endsWith('Feed') 
                && !name.endsWith('Tag')  
                && !name.endsWith('Event') 
                && !name.endsWith('Share');   
    }
}