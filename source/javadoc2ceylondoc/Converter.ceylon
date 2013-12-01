"The converter takes javadoc-formatted lines and converts them to ceylon lines."
class Converter() {
    SequenceBuilder<String> linesBuilder = SequenceBuilder<String>();
    SequenceBuilder<String> authorsBuilder = SequenceBuilder<String>();
    SequenceBuilder<[String, SequenceBuilder<String>]> exceptionsBuilder = SequenceBuilder<[String, SequenceBuilder<String>]>();
    variable SequenceBuilder<String> current = linesBuilder;

    "Add a javadoc-formatted line."
    shared void addLine(variable String line) {
        if (line.startsWith("@author")) {
            current = authorsBuilder;
            line = line["@author".size...].trimmed;
        } else if (line.startsWith("@throws") || line.startsWith("@exception")) {
            SequenceBuilder<String> newBuilder = SequenceBuilder<String>();
            current = newBuilder;
            line = line[(line.indexes(Character.whitespace).first else 0)...].trimmed;
            Integer sep = line.indexes(Character.whitespace).first else 0;
            String exception = line[...sep-1];
            line = line[sep+1...].trimmed;
            exceptionsBuilder.append([exception, current]);
        }
        current.append(line);
    }

    "Returns all added lines, converted to ceylondoc format."
    shared String getCeylondoc() {
        String[] lines = linesBuilder.sequence.trimTrailing((String elem) => elem.empty || elem.every(Character.whitespace));
        String[] authors = authorsBuilder.sequence;
        [String, String[]][] exceptions = exceptionsBuilder.sequence.collect(([String, SequenceBuilder<String>] elem) => [elem[0], elem[1].sequence]);
        StringBuilder ret = StringBuilder();
        ret.append("\"");
        ret.append(lines.first else "");
        for (line in lines.rest) {
            ret.append("\n ");
            ret.append(line);
        }
        ret.append("\"");
        if (nonempty authors) {
            ret.append("\nby(\"");
            ret.append(authors.first);
            ret.append("\"");
            for (String author in authors.rest) {
                ret.append(", \"");
                ret.append(author);
                ret.append("\"");
            }
            ret.append(")");
        }
        for (exception in exceptions) {
            ret.append("\nthrows(`class ");
            ret.append(exception[0]);
            ret.append("`, \"");
            ret.append(exception[1].first else "");
            String indent = {" "}.repeat("throws(`class ".size + exception[0].size + "`, \"".size).fold("", uncurry(String.plus));
            for (line in exception[1].rest) {
                ret.append("\n");
                ret.append(indent);
                ret.append(line);
            }
            ret.append("\")");
        }
        return ret.string;
    }
}
