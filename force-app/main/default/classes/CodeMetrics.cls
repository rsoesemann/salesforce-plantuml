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
}