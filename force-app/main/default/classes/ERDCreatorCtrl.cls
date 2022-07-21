public with sharing class ERDCreatorCtrl {

    public SelectOption[] options { get; set; }
    public SelectOption[] selection { get; set; }
	public PlantUmlErdDiagram diagram { get; set; }


    // CONSTRUCTOR
     
    public ERDCreatorCtrl() {
        diagram = new PlantUmlErdDiagram();
        
        selection = new List<SelectOption>();
        options = getOptions();
    }
    
    // PUBLIC
    
    public PageReference doCreateDiagram() {
        if(!selection.isEmpty()) {
        	Set<String> types = new Set<String>();

        	for(SelectOption option : selection) {
        		types.add(option.getValue());
        	}
        	
            diagram.setTypes(types);
        }
        else {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.Info, 'Please select at least one sobject.') );
        }

        return null;
    }
    
    
    // PRIVATE 
    
    private List<SelectOption> getOptions(){
        List<SelectOption> result = new List<SelectOption>();
    
        for(SObjectType type : Schema.getGlobalDescribe().values()) {
            DescribeSObjectResult describe = type.getDescribe();
            
            if(isAllowed(describe)) {
                String name = describe.getName();
                result.add( new SelectOption(name, name +  + ' - ' + describe.getLabel()) );
            }
        }

        SelectOptionSorter.sort(result, SelectOptionSorter.FieldToSort.Label);
        
        return result;
    }
    
    
    private Boolean isAllowed(DescribeSObjectResult describe) {
        String name = describe.getName();
        return describe.isCustom() || !diagram.hideStandard
                && !name.endsWith('History') 
                && !name.endsWith('Feed') 
                && !name.endsWith('Tag')  
                && !name.endsWith('Event') 
                && !name.endsWith('Share');   
    }
}