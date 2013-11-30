"The converter takes javadoc-formatted lines and converts them to ceylon lines."
class Converter() {
    SequenceBuilder<String> lines = SequenceBuilder<String>();

    "Add a javadoc-formatted line."
    shared void addLine(String line) {
        lines.append(line);
    }

    "Returns all added lines, converted to ceylondoc format."
    shared String getCeylondoc() {
        variable Boolean first = true;
        return "\"" + "\n".join(lines.sequence.map((String elem) {
            if (first) {
                first = false;
                return elem;
            }
            return " " + elem;
        })) + "\"";
    }
}
