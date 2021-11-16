@IsTest
private class CodeMetric_Test {
    
    @IsTest
    private static void calculateMethodCCCorrectly() {

        // Setup
        ApexClass original = [SELECT Name, Body FROM ApexClass WHERE Name = 'ApexClassForTests'];
        
        
        // Execute && Verify
        ApexParser parser = new ApexParser();
        for(ApexParser.ClassMember method : parser.parse(original).members) {
            if(method.Name == 'complexityOf7') {
                System.assertEquals(7, CodeMetrics.CC(method));
            }
        }
    }
        
    
    @IsTest
    private static void calculateMethodCCIgnoresCommentsAndLiterals() {

        // Setup
        ApexClass original = [SELECT Name, Body FROM ApexClass WHERE Name = 'ApexClassForTests'];
        

        // Execute + Verify
        ApexParser parser = new ApexParser();
        for(ApexParser.ClassMember method :  parser.parse(original).members) {
            if(method.Name == 'ccCalculationIgnoresCommentsAndLiterals') {
                System.assertEquals(1, CodeMetrics.CC(method));
            }
        }
    }
}