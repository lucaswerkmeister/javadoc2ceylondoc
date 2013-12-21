"""A simple converter from Javadoc to Ceylon doc.
   
   Usage
   =====
   
       ceylon run herd.javadoc2ceylondoc inputFile outputFile
   
   Example
   =======
   
   Let’s say you’re porting a library from Java to Ceylon.
   You have already updated all the code, but you don’t feel like rewriting all the documentation.
   What you currently have is this:
   ~~~ceylon
   import java.util { Date }
   
   /**
   * A person.
   * 
   * @author Jane Doe
   * @author Jim Coworker
   */
   shared class Person(String firstName, String lastName, Date birthday = Date(0)) {
       
       /**
       * <p>
       * Returns the current age of the person, in days.
       * </p>
       * <p>
       * Note that the age of a person can’t be negative; if the birthday
       * of the person is {@link Date#after(Date) after} the current date,
       * an exception is thrown.
       * </p>
       * @throws Exception if the person wasn’t born yet,
       *                   i. e. if {@code birthday.after(now)}.
       * @see Date#after(Date)
       */
       shared Integer getAge() {
           Date now = Date();
           if(birthday.after(now)) {
               throw Exception("Person wasn’t born yet!");
           }
           return ((now.time - birthday.time) / (1000 * 60 * 60 * 24));
       }
   }
   ~~~
   After running `javadoc2ceylondoc`, you get:
   ~~~ceylon
   import java.util { Date }
   
   "A person."
   by("Jane Doe", "Jim Coworker")
   shared class Person(String firstName, String lastName, Date birthday = Date(0)) {
       
       "Returns the current age of the person, in days.
        
        Note that the age of a person can’t be negative; if the birthday
        of the person is [[after|Date.after]] the current date,
        an exception is thrown."
       see(`function Date.after`)
       throws(`class Exception`, "if the person wasn’t born yet,
                                  i. e. if `birthday.after(now)`.")
       shared Integer getAge() {
           Date now = Date();
           if(birthday.after(now)) {
               throw Exception("Person wasn’t born yet!");
           }
           return ((now.time - birthday.time) / (1000 * 60 * 60 * 24));
       }
   }
   ~~~
   
   Features
   ========
   
   The following Javadoc tags are converted into Ceylon annotations:
   
   * `@author` → [[by]]
   * `@throws` → [[throws]]
   * `@see` → [[see]]
   
   The following Javadoc and HTML tags are converted into Markdown equivalents:
   
   * `{@link identifier label text}` → `[[label text|identifier]]`
   * `{@code}` → \`\`
   * `<b>` → `**`
   * `<i>` → `*`
   * `<tt>` → \`\`
   * `<p>` → paragraphs
   
   Limitations
   ===========
   
   * `@return` isn’t parsed.
   * `@param` isn’t parsed. Since this is not possible in the current architecture
     (it requires text manipulation inside the parameter list), it has been postponed to 1.1.
   * javadoc2ceylondoc is purely text based; it doesn’t analyse types or anything like that.
     For example, it splits `java.lang.String#indexOf(String)` purely by the cases of the first
     letters of each part, so if you have lowercase class names or uppercase package names or
     something like that, the resulting ceylondoc might have weird identifiers.
     (In other words, if you don’t need`\i`/`\I` in your Ceylon code, you’ll be fine.) 
   """
module herd.javadoc2ceylondoc "1.0.1" {
    shared import ceylon.file "1.0.0";
    import java.base "7"; // for regexes
}
