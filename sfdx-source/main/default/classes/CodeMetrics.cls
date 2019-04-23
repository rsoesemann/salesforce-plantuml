public class CodeMetrics {
    private static final Pattern CODE_DECISION_PATTERN = Pattern.compile('(?i)(if|for|while|catch)\\s*\\(.*?\\)');
    private static final Pattern LINES_PATTERN = Pattern.compile('\n');

    private static Integer countLines(String text) {
        Integer loc = 1;
        
        Matcher lineMatch = LINES_PATTERN.matcher(text);
        while(lineMatch.find()) {
            loc++;
        }
        return loc;
    }
     
    public static Integer LOC(ApexParser.ParsedClass clazz) {
        return countLines(clazz.body);
    }
    
    public static Integer LOC(ApexParser.ClassMember method) {
        return countLines(method.body);
    }         
    
    public static Integer CC(ApexParser.ClassMember method) {
        Integer methodCC = 1;
        
        Matcher ccRelevantMatch = CODE_DECISION_PATTERN.matcher(method.body);
        while(ccRelevantMatch.find()) {
            methodCC++;
        }
        
        return methodCC;
    }

    
    // TEST METHODS
    
    
    static testMethod void calculateMethodCCCorrectly() {
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
        
    
    static testMethod void calculateMethodCCIgnoresCommentsAndLiterals() {
        // Setup
        ApexClass original = [SELECT Name, Body FROM ApexClass WHERE Name = 'ApexClassForTests'];
        
        // Execute && Verify
        ApexParser parser = new ApexParser();
        for(ApexParser.ClassMember method :  parser.parse(original).members) {
            if(method.Name == 'ccCalculationIgnoresCommentsAndLiterals') {
                System.assertEquals(1, CodeMetrics.CC(method));
            }
        }
    }
}