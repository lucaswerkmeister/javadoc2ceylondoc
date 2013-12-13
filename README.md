javadoc2ceylondoc
=================

This tool converts javadoc-style comments into ceylondoc-style comments. Example:

Input:
```ceylon
/**
 * The best program ever
 *
 * well, if you’re a fan of programs that are too lazy for even a proper hello world, that is.
 */
shared void run() {
    print("hi");
}
```
Output:
```ceylon
"The best program ever
 
 well, if you’re a fan of programs that are too lazy for even a proper hello world, that is."
shared void run() {
    print("hi");
}
```

Processed elements
------------------

* `@author` → `by`
* `@throws` → `throws`
* `@see` → `see`
* `{@link}` → `[[]]`

Usage
-----

`ceylon run herd.javadoc2ceylondoc inputFileName outputFileName`

If inputFileName and/or outputFileName are missing, `/dev/stdin` and `/dev/stdout` are used instead, but special files aren’t (yet) supported by the Ceylon SDK (see [ceylon/ceylon-sdk#121](https://github.com/ceylon/ceylon-sdk/issues/121)), so at the moment you can’t pipe code into javadoc2ceylondoc.

TODO
----

* `@param` → parameter doc
* `@code` → \`\`
* possibly: some HTML processing. Markdown can contain HTML, but for basic elements like `<b>`, `<i>`, `<code>` or `<tt>` it might make the comment more readable.
