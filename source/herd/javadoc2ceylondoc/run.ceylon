import ceylon.file { parsePath, Resource, Link, File, Nil, Reader, Writer }
"Run javadoc2ceylondoc.
 
 [[arguments|process.arguments]] should be:
 1. input file
 2. output file"
throws(`class Exception`, "If the input or output file are invalid,
                           i. e. can’t be read/written")
shared void run() {
    String inFileName = process.arguments[0] else "/dev/stdin";
    String outFileName = process.arguments[1] else process.arguments[0] else "/dev/stdout";
    Reader inputReader;
    variable Resource inResource = parsePath(inFileName).resource;
    if (is Link link = inResource) {
        inResource = link.linkedResource;
    }
    if (is File inFile = inResource) {
        inputReader = inFile.Reader();
    } else {
        throw Exception("Invalid input!");
    }
    StringBuilder inputBuilder = StringBuilder();
    while (exists line = inputReader.readLine()) {
        inputBuilder.append(line).appendNewline();
    }
    String input = inputBuilder.string;
    inputReader.close(null);
    Writer output;
    variable Resource outResource = parsePath(outFileName).resource;
    if (is Link link = outResource) {
        outResource = link.linkedResource;
    }
    if (is File outFile = outResource) {
        output = outFile.Overwriter();
    } else if (is Nil outFile = outResource) {
        output = outFile.createFile().Overwriter();
    } else {
        throw Exception("Invalid output!");
    }
    convert(input, output);
    output.close(null);
}
