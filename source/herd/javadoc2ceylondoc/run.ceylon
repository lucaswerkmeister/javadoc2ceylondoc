import ceylon.file { parsePath, Resource, Link, File, Nil, Reader, Writer }
void run() {
    String inFileName = process.arguments[0] else "/dev/stdin";
    String outFileName = process.arguments[1] else process.arguments[0] else "/dev/stdout";
    Reader input;
    variable Resource inResource = parsePath(inFileName).resource;
    if (is Link link = inResource) {
        inResource = link.linkedResource;
    }
    if (is File inFile = inResource) {
        input = inFile.Reader();
    } else {
        throw Exception("Invalid input!");
    }
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
