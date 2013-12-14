import java.lang { JString=String, StringBuffer }
import java.util.regex { Pattern { compilePattern=compile }, Matcher }

"Converts javadoc/HTML text to Ceylon/Markdown."
String convertText(String text) {
    return convertHtml(convertCode(convertLink(text)));
}

"Converts
     bla {@link bar baz} blub
 into
     bla [[baz|bar]] blub"
String convertLink(String text) {
    "This pattern splits
         {@link java.lang.Integer.parseInt(String s) string2int method}
     into the groups
     1. `java.lang.Integer.parseInt`
     2. `(String s)` (not used)
     3. `string2int method`"
    Pattern p = compilePattern("\\{@link(?:plain)? ([^} (]*)(\\([^)]*\\))?(?: ([^}]*))?}");
    Matcher m = p.matcher(JString(text)); // wrap the string because a Ceylon string is not a CharSequence
    StringBuffer sb = StringBuffer();
    while(m.find()) {
        String javaRef = m.group(1);
        // String methodParams = m.group(2); // ignored
        String? label = m.group(3);
        "Either `label|` or the empty string."
        String labelString;
        if (exists label) {
            labelString = label + "|";
        } else {
            labelString = "";
        }
        String ceylonRef = "::".join(splitJavaRef(javaRef.replace("#", ".")));
        m.appendReplacement(sb, "[[``labelString + ceylonRef``]]");
    }
    m.appendTail(sb);
    return sb.string;
}

"""Converts
       bla {@code "foo bar".split()}
   into
       bla `"foo bar".split()`"""
String convertCode(String text) {
    Pattern p = compilePattern("\\{@code ([^}]*)}");
    Matcher m = p.matcher(JString(text)); // wrap the string because a Ceylon string is not a CharSequence
    StringBuffer sb = StringBuffer();
    while(m.find()) {
        String code = m.group(1);
        m.appendReplacement(sb, "```code```");
    }
    m.appendTail(sb);
    return sb.string;
}

String convertHtml(String text) {
    return text
        .replace("<tt>", "`").replace("</tt>", "`")
        .replace("<b>", "**").replace("</b>", "**")
        .replace("<i>", "*").replace("</i>", "*");
}

String convertParagraphs(String text) {
    Pattern p = compilePattern("\\n?</p>\\s*<p>\\n?");
    Matcher m = p.matcher(JString(text)); // wrap the string because a Ceylon string is not a CharSequence
    StringBuffer sb = StringBuffer();
    while(m.find()) {
        m.appendReplacement(sb, "</p>\n\n<p>");
    }
    m.appendTail(sb);
    return sb.string.replace("<p>", "").replace("</p>", "").trim('\n'.equals);
}

"Splits a String of the form
     foo.bar.package.Class.method
 into
     foo.bar.package, Class.method"
{String*} splitJavaRef(String javaRef) {
    "If the last character was a period ('.')"
    variable Boolean hadPeriod = false;
    "If a split location was already found
     (we only want to split once)"
    variable Boolean hasSplit = (javaRef.first else 'c').uppercase;
    return javaRef.split((Character c) {
        if (hasSplit) {
            return false;
        }
        if (hadPeriod) {
            if (c.uppercase) {
                hasSplit = true;
                return true;
            }
        } else if (c == '.') {
            hadPeriod = true;
        }
        return false;
    }).map((String s) => s.trimTrailing('.'.equals));
}
