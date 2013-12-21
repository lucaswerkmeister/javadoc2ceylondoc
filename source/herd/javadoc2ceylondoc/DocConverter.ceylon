"The `DocConverter` converts a javadoc comment into Ceylon documentation."
class DocConverter() {
    SequenceBuilder<String> linesBuilder = SequenceBuilder<String>();
    SequenceBuilder<String> authorsBuilder = SequenceBuilder<String>();
    SequenceBuilder<String> seeBuilder = SequenceBuilder<String>();
    SequenceBuilder<[String, SequenceBuilder<String>]> exceptionsBuilder = SequenceBuilder<[String, SequenceBuilder<String>]>();
    variable SequenceBuilder<String> current = linesBuilder;

    "Add a javadoc-formatted line."
    shared void addLine(variable String line) {
        if (line.startsWith("@author")) {
            current = authorsBuilder;
            line = line["@author".size...].trimmed;
        } else if (line.startsWith("@see")) {
            current = seeBuilder;
            String? identifier = line["@see".size...].trimmed.split(' '.equals).first; // @see Class#method() description text – ditch the description text
            "Empty @see tags are not allowed"
            assert(exists identifier);
            line = identifier.trimmed;
        } else if (line.startsWith("@throws") || line.startsWith("@exception")) {
            SequenceBuilder<String> newBuilder = SequenceBuilder<String>();
            current = newBuilder;
            line = line[(line.indexes(Character.whitespace).first else 0)...].trimmed;
            Integer sep = line.indexes(Character.whitespace).first else 0;
            String exception = line[...sep-1];
            line = line[sep+1...].trimmed;
            exceptionsBuilder.append([exception, current]);
        }
        current.append(convertText(line));
    }

    "Returns all added lines, converted to ceylondoc format."
    shared String getCeylondoc() {
        String[] lines = linesBuilder.sequence.trimTrailing((String elem) => elem.empty || elem.every(Character.whitespace));
        String[] authors = authorsBuilder.sequence;
        String[] sees = seeBuilder.sequence;
        [String, String[]][] exceptions = exceptionsBuilder.sequence.collect(([String, SequenceBuilder<String>] elem) => [elem[0], elem[1].sequence]);
        
        StringBuilder ret = StringBuilder();
        ret.append("\"");
        ret.append(
            "\n ".join(
                convertParagraphs(
                    "\n".join(lines))
                        .split{'\n'.equals; groupSeparators = false;}));
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
        for (see in sees) {
            ret.append("\nsee(`");
            variable Boolean hadPeriod = true;
            "The *base name* of the identifier, without any package prefixes.
             
             Package names are assumed to begin with a lowercase letter, while
             class names are assumed to begin with an uppercase letter; for example,
             the identifier `java.lang.String#toString()` would be turned into
             `String.toString()`."
            String basename = see.replace("#", ".").trimLeading((Character c) {
                if (hadPeriod) {
                    hadPeriod = false;
                    if (c.uppercase) {
                        // beginning of a class name
                        return false;
                    }
                } else if (c == '.') {
                    hadPeriod = true;
                }
                return true;
            });
            "Trailing period is not allowed"
            assert (!basename.empty);
            if (exists parenIndex = basename.indexes('('.equals).first) {
                // it’s a function (or a constructor, but they can’t be helped)
                ret.append("function ");
                ret.append(basename[...parenIndex-1]); // strip the parentheses
            } else {
                // we have to look at the last part to determine if it’s a class or a value
                String lastPart;
                if (exists periodIndex = basename.indexes('.'.equals).last) {
                    // this happens for inner / nested classes
                    lastPart = basename[periodIndex+1...];
                } else {
                    lastPart = basename;
                }
                "Trailing period is not allowed"
                assert (exists firstChar = lastPart.first);
                if (firstChar.uppercase) {
                    // looks like a class
                    ret.append("class ");
                    ret.append(basename); // yes, basename, not lastPart.
                } else {
                    // looks like a value
                    ret.append("value ");
                    ret.append(basename);
                }
            }
            ret.append("`)");
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
