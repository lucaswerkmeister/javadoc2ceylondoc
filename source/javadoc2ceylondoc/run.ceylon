import ceylon.file { parsePath, Resource, File, Nil, Reader, Writer }
void run() {
	String inFileName = process.arguments[0] else "/dev/stdin";
	String outFileName = process.arguments[1] else process.arguments[0] else "/dev/stdout";
	Reader input;
	Resource inResource = parsePath(inFileName).resource;
	if (is File inResource) {
		input = inResource.Reader();
	} else {
		throw Exception("Invalid input!");
	}
	Writer output;
	Resource outResource = parsePath(outFileName).resource;
	if (is File outResource) {
		output = outResource.Overwriter();
	} else if (is Nil outResource) {
		output = outResource.createFile().Overwriter();
	} else {
		throw Exception("Invalid output!");
	}
	variable Boolean inComment = false;
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
