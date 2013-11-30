"The converter takes javadoc-formatted lines and converts them to ceylon lines."
class Converter() {
    SequenceBuilder<String> lines = SequenceBuilder<String>();
    SequenceBuilder<String> authors = SequenceBuilder<String>();
    variable SequenceBuilder<String> current = lines;

    "Add a javadoc-formatted line."
    shared void addLine(variable String line) {
        if (line.startsWith("@author")) {
            current = authors;
            line = line["@author".size...].trimmed;
        }
        current.append(line);
    }

    "Returns all added lines, converted to ceylondoc format."
    shared String getCeylondoc() {
        String[] allLines = lines.sequence.trimTrailing((String elem) => elem.empty || elem.every(Character.whitespace));
        String[] allAuthors = authors.sequence;
        StringBuilder ret = StringBuilder();
        ret.append("\"");
        ret.append(allLines.first else "");
        for (line in allLines.rest) {
            ret.append("\n ");
            ret.append(line);
        }
        ret.append("\"");
        if (nonempty allAuthors) {
            ret.append("\nby(\"");
            ret.append(allAuthors.first);
            ret.append("\"");
            for (String author in allAuthors.rest) {
                ret.append(", \"");
                ret.append(author);
                ret.append("\"");
            }
            ret.append(")");
        }
        return ret.string;
    }
}
