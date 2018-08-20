About
=====

nim-pythonfile is a Nim module to wrap the file functions and provide an interface as similar as possible to that of Python.

Examples:

    # Open a file for reading, read and print one line, then read and store the next ten bytes.
    var f: PythonFile = open("my_file.txt", "r")        # f = open("my_file.txt", "r")
    echo(f.readline())                                  # print(f.readline())
    var s: string = f.read(10)                          # s = f.read(10)
    f.close()                                           # f.close()

    # Open a file for writing, write "Hello World!", then write multiple lines at once.
    var f: PythonFile = open("my_file.txt", "w")        # f = open("my_file.txt", "w")
    f.write("Hello World!")                             # f.write("Hello World!")
    f.writelines(["This", "is", "an", "example"])       # f.writelines(["This", "is", "an", "example"])
    f.close()                                           # f.close()

    # Open a file for reading or writing, then read and write from multiple locations
    # using seek() and tell().
    var f: PythonFile = open("my_file.txt", "r+")       # f = open("my_file.txt", "r+")
    f.seek(10)                                          # f.seek(10)
    echo(f.read())                                      # print(f.read())
    echo(f.tell())                                      # print(f.tell())
    f.seek(0)                                           # f.seek(0)
    f.seek(-50, 2)                                      # f.seek(-50, 2)
    f.write("Inserted at pos 50 from end")              # f.write("Inserted at pos 50 from end")
    f.close()                                           # f.close()
    

Note that due to some inherent differences between how Nim and Python handle files, a complete
1 to 1 wrapper is not possible. Notably, Nim has no equivalent to the `newlines` and `encoding`
properties, and while they are present in this implementation they are always set to `nil`. In
addition, the `fileno()` procedure functions differently from how it does in Python, yet it has the
same basic functionality. Finally, the `itatty()` procedure will always return `false`.

For general use, however, this wrapper provides all of the common Python file methods.

License
=======

nim-pythonfile is released under the MIT open source license.
