/*
BLOCK COMMENT TO BE IGNORED
public class IGNORE { 
*/ 
public abstract with sharing class ApexClassForTests extends ABaseClass implements AnInterface, AnotherInterface {
    private static Integer privateStaticVariable;
    public String publicVariable;
    
    
    private static void privateStaticVoid() {

    }
    
    /**
     * BLOCK COMMENT TO BE IGNORED
     * public class IGNORE { 
     */ 
    private static String privateStaticString() {
        return 'String'; // INLINE COMMENT TO BE IGNORED
    }
    
    // INLINE COMMENT TO BE IGNORED
    private abstract void abstractMethod();
    
    public static List<String> publicStaticReturnsList() 
    {
        return new List<String>{'foo', 'bar'};
    }
    
    
    public void complexityOf7(String stringParam, Integer integerParam) { 
        if(true) { // 2
            do {
                
            }while(false); //3
        }
        
        for (Integer i=0; i>1; i++) { // 4
            if(true) { // 5
                
            }   
            else if(true) { /// 6
                
            }   
            else {
                
            }   
        }
        
        Integer a = 1;
        
        while(true) { // 7
            
        }
    }
    
    private void ccCalculationIgnoresCommentsAndLiterals(String stringParam, Integer integerParam) { 

        
        /*
        while(false) {
        
        }
        */
        
        // if(sadfys) {
        
        
        String test = ' if(true) { do this'; // for(wsdasd) {
        String literal = 'if(a==b) { ignore(); }';
    }
    
    
    public virtual class ABaseClass {
        public String pubicString { get; set; }
        
        public Integer foo(Object bar) { 
            return 42;
        }
        
        public void bar(Object foo) {
            
        }
    }
    
    public interface AnInterface {
        
    }
    
    public interface AnotherInterface {  }
    
    public enum AnEnum {
        thing,thong
    }
}