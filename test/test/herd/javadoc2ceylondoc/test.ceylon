import herd.javadoc2ceylondoc { convert }
import ceylon.test { assertEquals, test }
import ceylon.file { Directory, File, parsePath, Reader, Writer }

test
shared void testFiles() {
    assert (is Directory dir = parsePath("test-samples").resource);
    variable Boolean success = true;
    for (file in dir.files().filter((File file) => !file.name.endsWith("expected"))) {
        success = testFile(file) && success;
    }
    if (!success) {
        throw AssertionException("At least one test failed!");
    }
}

Boolean testFile(File inFile) {
    try {
        Reader input = inFile.Reader();
        assert (is File expectedFile = inFile.path.parent.childPath(inFile.name + ".expected").resource);
        Reader expected = expectedFile.Reader();
        
        object output satisfies Writer {
            
            variable String currentLine = "";
            
            shared actual void write(String string) {
                currentLine += string;
            }
            
            shared actual void writeLine(String line) {
                currentLine += line;
                for (actualLine in line.split((Character c) => c == '\n')) {
                    String? expectedLine = expected.readLine();
                    assertEquals(actualLine, expectedLine);
                }
                currentLine = "";
            }
            
            shared actual void flush() => writeLine("");
            
            shared actual void destroy() => flush();            
        }
        
        StringBuilder inStringBuilder = StringBuilder();
        while (exists line = input.readLine()) {
            inStringBuilder.append(line).appendNewline();
        }
        convert(inStringBuilder.string.trimTrailing('\n'.equals), output);
        
        assertEquals(expected.readLine(), null);
        return true;
    } catch (AssertionException e) {
        process.writeErrorLine("Test for file ``inFile`` FAILED: ``e.message``");
        return false;
    }
}
