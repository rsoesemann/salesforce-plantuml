public class PlantUMLClassDiagram {
    public String plantUMLText { get; private set; }
    
    // Diagram options
    public Boolean showPublicVariables { get; set; }
    public Boolean showPublicMethods { get; set; }
    public Boolean showMetrics { get; set; }

    
    public PlantUMLClassDiagram() {
        this.plantUMLText = '';
    }
    

    public void setClasses(Set<ApexParser.ParsedClass> classes) {
        this.plantUMLText = 'skinparam packageStyle frame\nset namespaceSeparator ::\n';
        
        for(ApexParser.ParsedClass clazz : classes) {
            this.plantUMLText += translateClass(clazz);
        }
    }
    

    // PRIVATE MEHTODS
    
    
    private String translateClass(ApexParser.ParsedClass clazz) {
        String text = translateRelations(clazz) + translateHeader(clazz) + translateMembers(clazz);
        return text;
    }
    
    private String translateRelations(ApexParser.ParsedClass clazz) {
        String text = '';
      
        if(clazz.doesExtend) {
            text += '\n' + clazz.name + ' --|> ' + clazz.superName;
        }
        if(clazz.doesImplement) {
            for(String i: clazz.interfaces) {
                text += '\ninterface ' + i;
                text += '\n' + clazz.name + ' ..|> ' + i;
            }
        }
        for(ApexParser.ParsedClass innerClass : clazz.innerClasses) {
            text += '\n' + translateHeader(innerClass) + '<< Inner >> ' + translateMembers(innerClass);
            text += '\n' + clazz.name + ' +-- ' + innerClass.name; 
        }
        
        return text;
    }
    
        
    private String translateHeader(ApexParser.ParsedClass clazz) {
        String scope = '';
        if(clazz.scope == 'static' || clazz.scope == 'abstract') {
            scope = clazz.scope;
        }
        String text = '\n' + scope + ' ' + clazz.type + ' '+ clazz.Name;
        return text;
    }
    
        
    private String translateMembers(ApexParser.ParsedClass clazz) {
        String text = '';

        for(ApexParser.ClassMember member : clazz.members) {
            Boolean variableToShow = member.parameters == '' && showPublicVariables;
            Boolean memberToShow = member.parameters != '' && showPublicMethods;
            
            if(variableToShow || memberToShow) {
                String visibility = (clazz.visibility == 'private' ? '-' : '+');
                String scope = '';
                if(clazz.scope == 'static' || clazz.scope == 'abstract') {
                    scope = ' {' + clazz.scope + '} ';
                }
                text += '\n' + visibility +  scope + member.returnType + ' ' + member.name;
                
                if(showMetrics & memberToShow) {
                    text += '(CC = ' + CodeMetrics.CC(member) + ', LOC = ' + CodeMetrics.LOC(member) + ')';
                }
                else {
                    text += member.parameters;
                }
            }
            
        }
        
        return ' {\n' + text + '\n}\n';
    }
}