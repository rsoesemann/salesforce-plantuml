public class ApexParser {
    private static final Pattern CLASSHEADER = Pattern.compile('(?i)(@isTest\\s+private|public|global)\\s*(with\\s+sharing|without\\s+sharing)*\\s*(static|virtual|abstract)*\\s*(with\\s+sharing|without\\s+sharing)*\\s*(class|interface|enum)\\s+(\\w+)(\\s+(extends|implements)\\s+(\\w+(\\s*,\\s*\\w+)*))*\\s*\\n*\\{');
    private static final Pattern CLASSMEMBER = Pattern.compile('(?i)(static testmethod|@isTest\\s+private|public|global|private)\\s*\\b(static|abstract|virtual)?\\b\\s*(((?!class|interface)\\w+)(<\\b[^>]*>)*)\\s*(\\w+)(\\((.*?)\\))*\\s*\\n*\\{');
    private static final String COMMENT_LITERAL = '/\\*([^*]|[\\r\\n]|\\*+(?:[^*/]|[\\r\\n]))*\\*+/|//.*|\'.*\'';
    private static final String EMPTY_LINE = '\n\\s*\n';
    private static final Pattern BRACES = Pattern.compile('\\{|\\}');
    
    private String cleanedSource;
    private ParsedClass parsed;
    
    public ParsedClass parse(ApexClass originalClass) {
        this.cleanedSource = getCleaned(originalClass.Body); 
        this.parsed = new ParsedClass();
        
        parseHeader();
        parseAndRemoveInnerClasses();
        parseMembers();
         
        return parsed;
    }
    

    private ParsedClass parse(String cleanedSource) {
        this.cleanedSource = cleanedSource;
        this.parsed = new ParsedClass();
        
        parseHeader();
        parseMembers();
         
        return parsed;
    }
    
    
    // PRIVATE METHODS
    
        
    private String getCleaned(String original) {
        String cleaned = original.replaceAll(COMMENT_LITERAL, '');
        cleaned = cleaned.replaceAll(EMPTY_LINE, '\n'); 
        return cleaned;
    }
    
    
    private void parseHeader() {
        Matcher classMatch = CLASSHEADER.matcher(this.cleanedSource);
   
        // Parse top class header
        if(classMatch.find()) {
            this.parsed.name = extractName(classMatch);
            this.parsed.visibility = extractClassVisibility(classMatch);
            this.parsed.scope = extractClassScope(classMatch);
            this.parsed.type = extractClassType(classMatch);
            this.parsed.sharing = extractSharing(classMatch);
            this.parsed.doesImplement = extractDoesImplement(classMatch);
            this.parsed.interfaces = extractImplementedInterfaces(classMatch);
            this.parsed.doesExtend = extractDoesExtend(classMatch);
            this.parsed.superName = extractSuperClass(classMatch);
            this.parsed.body = getBlockStartingWith(classMatch, this.cleanedSource);
        }
        else {
            throw new ParsingException();
        }
    }
    
    
    private String extractName(Matcher classMatch) {
        return classMatch.group(6);
    }
    
    
    private String extractClassVisibility(Matcher classMatch) {
        String g = classMatch.group(1);
        return (g != null) ? g : '';
    }
    
    private String extractClassScope(Matcher classMatch) {
        String g = classMatch.group(3);
        return (g != null) ? g : '';
    }
    
    private String extractSharing(Matcher classMatch) {
        String first = classMatch.group(2);
        first = (first != null) ? first : '';
        String second = classMatch.group(4);
        second = (second != null) ? second : '';
        return (first + second);
    }
      
    private String extractClassType(Matcher classMatch) {
        String g = classMatch.group(5);
        return (g != null) ? g : '';
    }
    
    private Boolean extractDoesImplement(Matcher classMatch) {
        String g = classMatch.group(8);
        return (g != null) ? g == 'implements' : false;
    }
    
    private List<String> extractImplementedInterfaces(Matcher classMatch) {
        List<String> results = new List<String>();
        String g = classMatch.group(9);
        
        if(g != null) { 
            for(String part : g.split('\\,')) {
                results.add(part.trim());
            }
        }
        
        return results;
    }
    
    private Boolean extractDoesExtend(Matcher classMatch) {
        String g = classMatch.group(8);
        return (g != null) ? g == 'extends' : false;
    }
    
    private String extractSuperClass(Matcher classMatch) {
        String g = classMatch.group(9);
        return (g != null) ? g : '';   
    } 

        
    private void parseMembers() { 
        Matcher memberMatch = CLASSMEMBER.matcher(this.cleanedSource);
        
        while(memberMatch.find()) {
            ClassMember member = new ClassMember();
            
            member.visibility = extractMemberVisibility(memberMatch);
            member.scope = extractMemberScope(memberMatch);
            member.returnType = extractReturnType(memberMatch);
            member.name = extractMemberName(memberMatch);
            member.parameters = extractParameters(memberMatch);
            member.body = getBlockStartingWith(memberMatch, this.cleanedSource);
            
            parsed.members.add(member);
        }
    }
    
    
    private void parseAndRemoveInnerClasses() { 
        Matcher innerClassHeader = CLASSHEADER.matcher(this.parsed.body);
        
        // For each matches class
        while(innerClassHeader.find()) {
            String innerClassBody = getBlockStartingWith(innerClassHeader, this.parsed.body);
            String wholeInnerClass = innerClassHeader.group() + innerClassBody.substring(1);
            
            ParsedClass innerClass = new ApexParser().parse(wholeInnerClass);
            parsed.innerClasses.add(innerClass);
                    
            // Remove innerclass source from outer class' body to not interfere with member matching
            this.cleanedSource = this.cleanedSource.remove(wholeInnerClass);
        } 
    }   
    
    
    public String extractMemberVisibility(Matcher memberMatch) {
        String g = memberMatch.group(2);
        return (g != null) ? g : '';
    }
    
    public String extractMemberScope(Matcher memberMatch) {
        String g = memberMatch.group(3);
        return (g != null) ? g : '';
    }
    
    
    private String extractReturnType(Matcher memberMatch) {
        return memberMatch.group(4);
    }
    
    
    private String extractMemberName(Matcher memberMatch) {
        return memberMatch.group(6);
    }
    
    
    private static String extractParameters(Matcher memberMatch) {
        String g = memberMatch.group(7);
        return (g != null) ? g : '';
    }
    
    
    /**
     * Returns block for a given header match and a context string
     * 
     * Note: Regexp is only able to match header but not whole block. Counting braces is used to find block end
     */
    private String getBlockStartingWith(Matcher blockStartMatch, String context) {
        Integer blockStart = blockStartMatch.end()-1;
        Integer blockEnd = blockStart;
        Integer braceCounter = 0;
        
        Matcher braceMatch = BRACES.matcher(context.substring(blockStart));
        do {
            braceMatch.find();
            braceCounter = (braceMatch.group() == '{') ? braceCounter + 1 : braceCounter -1;
            blockEnd = braceMatch.end();
        } while(braceCounter > 0);
        
        return context.substring(blockStart, blockStart+blockEnd);
    }
    
    
    public class ParsedClass {
        public String visibility { get; private set; }
        public String scope { get; private set; }
        public String type { get; private set; }
        public String sharing { get; private set; }
        public String name { get; private set; }
        public Boolean doesImplement { get; private set; }
        public List<String> interfaces { get; private set; }
        public Boolean doesExtend { get; private set; }
        public String superName { get; private set; }
        public String body { get; private set; }
        public List<ClassMember> members { get; private set; }
        public List<ParsedClass> innerClasses { get; private set; }
        
        ParsedClass() {
            this.members = new List<ClassMember>();
            this.innerClasses = new List<ParsedClass>();
            this.doesImplement = false;
            this.doesExtend = false;
        }
    } 
    
    public class ClassMember {
        public String visibility { get; private set; }
        public String scope { get; private set; }
        public String returnType { get; private set; }
        public String name { get; private set; }
        public String parameters { get; private set; }
        public String body { get; private set; }
        
        ClassMember() {}
    }
        
    public class ParsingException extends Exception {}  
}