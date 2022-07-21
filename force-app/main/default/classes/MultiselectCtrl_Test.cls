@IsTest
private class MultiselectCtrl_Test {

    @IsTest
    private static void happyPath() {
        MultiselectCtrl ctrl = new MultiselectCtrl();
        
        ctrl.leftOptions = new List<SelectOption>();
        ctrl.rightOptions = new List<SelectOption>();

        ctrl.leftOptionsHidden = 'A&a&b&b&C&c';
        ctrl.rightOptionsHidden = '';
        
        System.assertEquals(ctrl.leftOptions.size(), 3);
        System.assertEquals(ctrl.rightOptions.size(), 0);
    }
}