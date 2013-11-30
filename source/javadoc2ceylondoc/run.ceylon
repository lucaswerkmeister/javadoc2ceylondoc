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
	"When we’re in a comment, we parse the input lines – otherwise, we just pass them through."
	variable Boolean inComment = false;
	"When we’re already writing a comment, we need to terminate the previous line
	 and then write one space before our own line.
	 When we’re just at the start of a comment, we don’t need to terminate the previous line,
	 but we need to open the string quotes."
	variable Boolean writingComment = false;
	output.open();
	while (exists line = input.readLine()) {
		if (line == "/**") {
			inComment = true;
		} else {
			if (inComment) {
				if (line == " */") {
					output.writeLine("\"");
					writingComment = false;
					inComment = false;
				} else {
					if (writingComment) {
						output.writeLine();
						output.write(" ");
					} else {
						writingComment = true;
						output.write("\"");
					}
					output.write("``line.trimLeading((Character elem) => elem.whitespace || elem == '*')``");
				}
			} else {
				output.writeLine(line);
			}
		}
	}
	output.close(null);
}
