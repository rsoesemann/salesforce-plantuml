public with sharing class ClassDiagramCreatorCtrl {
    
    public PlantUMLClassDiagram classDiagram { get; private set; }
    
    public SelectOption[] accessibleClasses { get; set; }
    public SelectOption[] selectedClasses { get; set; }
    public String[] selectedClassesArray { get; set; }
    
    
    public ClassDiagramCreatorCtrl() {
        this.classDiagram = new PlantUMLClassDiagram();
        
        // Init sobject Multiselect list
        this.accessibleClasses = new List<SelectOption>();
        this.selectedClasses = new List<SelectOption>();
    
        for(ApexClass c : [SELECT Name, Body FROM ApexClass WHERE Status = 'Active' ORDER BY NamespacePrefix, Name]) {
            if(c.Body != '(hidden)') {
                this.accessibleClasses.add(new SelectOption(c.Name, c.Name));
            }
        }
    }
    
    
    public PageReference doCreateDiagram() {
        
        if(this.selectedClasses.isEmpty()) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Info, 'Please select at least one class.');
            ApexPages.addMessage(msg);
        }
        else {
            try {
                Set<ApexParser.ParsedClass> parsedClasses = new Set<ApexParser.ParsedClass>();
                Set<String> classList = new Set<String>();
                
                // Create set of selected class names
                for(SelectOption o : this.selectedClasses) {
                    classList.add(o.getValue());
                }
                
                
                // Query and parse selected classes
                ApexParser parser = new ApexParser();
                
                for(ApexClass originalClass : [SELECT Name, ApiVersion, Status, IsValid, Body, LastModifiedBy.UserName
                                               FROM ApexClass 
                                               WHERE Name IN :classList
                                               ORDER BY NamespacePrefix, Name]) {
                                                                        
                    ApexParser.ParsedClass parsedClass = parser.parse(originalClass);      
                    parsedClasses.add(parsedClass);
                }
                
                // Init diagram with selected classes
                this.classDiagram.setClasses(parsedClasses);
            }
            catch(Exception e) {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Soemthing went wrong: ' + e.getMessage());
                ApexPages.addMessage(msg);
            }
         }
         return null;
    }
    
    
    // TEST METHODS
    
    
    static testmethod void testUIIsPopulatedOnConstructor() {
        // Setup
        Boolean noExceptionWasThrown = true;
        
        // Execute
        Test.setCurrentPageReference(Page.classDiagramCreator);
        try {
            ClassDiagramCreatorCtrl ctrl = new ClassDiagramCreatorCtrl();
        }
        catch(Exception ignored) {
            noExceptionWasThrown = false;               
        }
        
        // Verify not much more than that no Exception was thrown
        System.assert(noExceptionWasThrown);
    }
    
    static testmethod void errorShownOnCreateWithNoSelectedClass() {
        // Setup 
        Test.setCurrentPageReference(Page.classDiagramCreator);
        ClassDiagramCreatorCtrl pageCtrl = new ClassDiagramCreatorCtrl();
        
        // Execute
        pageCtrl.doCreateDiagram();
        
        // Verify
        System.assert(ApexPages.hasMessages());
    }
    
    static testmethod void noErrorOnCreateWithSelectedClass() { 
        // Setup 
        Test.setCurrentPageReference(Page.classDiagramCreator);
        ClassDiagramCreatorCtrl pageCtrl = new ClassDiagramCreatorCtrl();
        
        // Execute
        Boolean hasClasses = pageCtrl.accessibleClasses.size() > 0;
        if(hasClasses) {
            SelectOption anObject = pageCtrl.accessibleClasses.get(0);
            pageCtrl.selectedClasses.add(anObject);
            pageCtrl.classDiagram.showPublicMethods = true;
            pageCtrl.classDiagram.showPublicVariables = true;
            pageCtrl.classDiagram.showMetrics = true;
        }
        pageCtrl.doCreateDiagram();
        
        // Verify
        System.assert(!hasClasses || !ApexPages.hasMessages());
        System.assert(!hasClasses || pageCtrl.classDiagram.plantUMLText != '');
    }
}