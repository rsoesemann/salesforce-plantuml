@IsTest
private class ClassDiagramCreatorCtrl_Test {

    @IsTest
    private static void testUIIsPopulatedOnConstructor() {

        // Setup
        Boolean noExceptionWasThrown = true;
        

        // Execute
        Test.setCurrentPageReference(Page.classDiagramCreator);
        try {
            new ClassDiagramCreatorCtrl();
        }
        catch(Exception ignored) {
            noExceptionWasThrown = false;               
        }
        

        // Verify 
        System.assert(noExceptionWasThrown);
    }
    

    @IsTest
    private static void errorShownOnCreateWithNoSelectedClass() {

        // Setup 
        Test.setCurrentPageReference(Page.classDiagramCreator);
        ClassDiagramCreatorCtrl pageCtrl = new ClassDiagramCreatorCtrl();
        

        // Execute
        pageCtrl.doCreateDiagram();
        

        // Verify
        System.assert(ApexPages.hasMessages());
    }
    

    @IsTest
    private static void noErrorOnCreateWithSelectedClass() { 

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
