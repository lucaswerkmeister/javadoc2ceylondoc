import herd.javadoc2ceylondoc { convert }
import ceylon.test { assertEquals, test }
import ceylon.file { Directory, File, parsePath, Reader, Writer }

test
shared void testFiles() {
    assert (is Directory dir = parsePath("test-samples").resource);
    for (file in dir.files().filter((File file) => !file.name.endsWith("expected"))) {
        testFile(file);
    }
}

void testFile(File inFile) {
    try {
        Reader input = inFile.Reader();
        assert (is File expectedFile = inFile.path.parent.childPath(inFile.name + ".expected").resource);
        Reader expected = expectedFile.Reader();
        
        object output satisfies Writer {
            
            shared actual void destroy() {}
            
            shared actual void flush() {}
            
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
            
        }
        
        convert(input, output);
        
        assertEquals(expected.readLine(), null);
    } catch (AssertionException e) {
        process.writeErrorLine("Test for file ``inFile`` FAILED: ``e.message``");
    }
}
