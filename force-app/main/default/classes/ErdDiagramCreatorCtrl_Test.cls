@IsTest
private class ErdDiagramCreatorCtrl_Test {

    @IsTest
    private static void testUIIsPopulatedOnConstructor() {

        // Setup
        Test.setCurrentPageReference(Page.erdCreator);
        

        // Execute
        ERDCreatorCtrl ctrl = new ERDCreatorCtrl();
        

        // Verify
        System.assertNotEquals(0, ctrl.accessibleSObjects.size());
        System.assertEquals(0, ctrl.selectedSObjects.size());
    }
    
    
    @IsTest
    private static void errorShownOnCreateWithNoSelectedObject() {
        // Setup 
        Test.setCurrentPageReference(Page.erdCreator);
        ERDCreatorCtrl pageCtrl = new ERDCreatorCtrl();
        
        // Execute
        pageCtrl.doCreateDiagram();
        
        // Verify
        System.assert(ApexPages.hasMessages());
    }
    
    
    @IsTest
    private static void noErrorOnCreateWithSelectedObject() {

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
