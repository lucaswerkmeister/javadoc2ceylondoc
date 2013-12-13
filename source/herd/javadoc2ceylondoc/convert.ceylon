import ceylon.file { Reader, Writer }

shared void convert(Reader input, Writer output) {
    "When we’re in a comment, we parse the input lines – otherwise, we just pass them through."
    variable Boolean inComment = false;
    "When we’re already writing a comment, we need to terminate the previous line
     and then write one space before our own line.
     When we’re just at the start of a comment, we don’t need to terminate the previous line,
     but we need to open the string quotes."
    variable Boolean writingComment = false;
    variable String indent = "";
    variable DocConverter docConverter = DocConverter();
    output.open();
    while (exists line = input.readLine()) {
        String trimmedLine = line.trimmed;
        if (trimmedLine.startsWith("/**")) {
            inComment = true;
            indent = line[...(line.indexes((Character c) => !c.whitespace).first else 0)-1];
            docConverter = DocConverter();
            if (trimmedLine.longerThan(3)) {
                // there’s something behind the /** like this
                if (trimmedLine.endsWith("*/")) {
                    // it’s a one-line comment /** like this */
                    docConverter.addLine(trimmedLine[3..trimmedLine.size-3].trimmed);
                    output.writeLine(docConverter.getCeylondoc());
                    inComment = false;
                } else {
                    writingComment = true;
                    docConverter.addLine(trimmedLine[3...].trimLeading(Character.whitespace));
                }
            }
        } else {
            if (inComment) {
                if (trimmedLine.endsWith("*/")) {
                    if (trimmedLine.longerThan(2)) {
                        // there’s something before the */
                        docConverter.addLine(trimmedLine[...trimmedLine.size-3]
                                .trimLeading((Character elem) => elem.whitespace || elem == '*')
                                .trimTrailing(Character.whitespace));
                    }
                    String ceylondoc = docConverter.getCeylondoc();
                    // prepend indent to each line
                    String indentedCeylondoc = "\n".join(ceylondoc.split(Character.equals('\n')).map(String.plus(indent)));
                    output.writeLine(indentedCeylondoc);
                    writingComment = false;
                    inComment = false;
                } else {
                    docConverter.addLine(line.trimLeading((Character elem) => elem.whitespace || elem == '*'));
                }
            } else {
                output.writeLine(line);
            }
        }
    }
}