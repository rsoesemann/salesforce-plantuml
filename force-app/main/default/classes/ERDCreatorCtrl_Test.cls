@IsTest
private class ERDCreatorCtrl_Test {

    @IsTest
    private static void testUiIsPopulatedOnConstructor() {

        // Setup
        Test.setCurrentPageReference(Page.erdCreator);
        

        // Execute
        ERDCreatorCtrl ctrl = new ERDCreatorCtrl();
        

        // Verify
        System.assertNotEquals(0, ctrl.options.size());
        System.assertEquals(0, ctrl.selection.size());
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
        ERDCreatorCtrl ctrl = new ERDCreatorCtrl();
        

        // Execute
        ctrl.selection.add( ctrl.options.get(0) );
        ctrl.doCreateDiagram();
        
        
        // Verify
        System.assert(!ApexPages.hasMessages());
    }
}
