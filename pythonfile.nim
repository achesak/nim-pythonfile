# Nim module to wrap the file functions and provide an interface
# as similar as possible to that of Python.

# Written by Adam Chesak.
# Released under the MIT open source license.


## pythonfile is a Nim module to wrap the file functions and provide an interface as similar as possible to that of Python.
##
## Examples:
## 
## .. code-block:: nimrod
##
##    # Open a file for reading, read and print one line, then read and store the next ten bytes.
##    var f : PythonFile = open("my_file.txt", "r")       # f = open("my_file.txt", "r")
##    echo(f.readline())                                  # print(f.readline())
##    var s : string = f.read(10)                         # s = f.read(10)
##    f.close()                                           # f.close()
##
## .. code-block:: nimrod
##
##    # Open a file for writing, write "Hello World!", then write multiple lines at once.
##    var f : PythonFile = open("my_file.txt", "w")       # f = open("my_file.txt", "w")
##    f.write("Hello World!")                             # f.write("Hello World!")
##    f.writelines(["This", "is", "an", "example"])       # f.writelines(["This", "is", "an", "example"])
##    f.close()                                           # f.close()
##
## .. code-block:: nimrod
##
##    # Open a file for reading or writing, then read and write from multiple locations
##    # using seek() and tell().
##    var f : PythonFile = open("my_file.txt", "r+")      # f = open("my_file.txt", "r+")
##    f.seek(10)                                          # f.seek(10)
##    echo(f.read())                                      # print(f.read())
##    echo(f.tell())                                      # print(f.tell())
##    f.seek(0)                                           # f.seek(0)
##    f.seek(-50, 2)                                      # f.seek(-50, 2)
##    f.write("Inserted at pos 50 from end")              # f.write("Inserted at pos 50 from end")
##    f.close()                                           # f.close()
##
## Note that due to some inherent differences between how Nim and Python handle files, a complete
## 1 to 1 wrapper is not possible. Notably, Nim has no equivalent to the ``newlines`` and ``encoding``
## properties, and while they are present in this implementation they are always set to ``nil``. In
## addition, the ``fileno()`` procedure functions differently from how it does in Python, yet it has the
## same basic functionality. Finally, the ``itatty()`` procedure will always return ``false``.
##
## For general use, however, this wrapper provides all of the common Python file methods.


import strutils


type
    PythonFile* = ref PythonFileInternal
    
    PythonFileInternal* = object
        f* : File
        mode* : string
        closed* : bool
        name* : string
        softspace* : bool
        encoding* : string
        newlines* : string


proc open*(filename : string, mode : string = "r", buffering : int = -1): PythonFile = 
    ## Opens the specified file.
    ##
    ## mode can be either ``r`` (reading), ``w`` (writing), ``a`` (appending), ``r+`` (read/write, only existing files), and ``w+``
    ## (read/write, file created if needed).
    ##
    ## ``buffering`` specifies the file’s desired buffer size: 0 means unbuffered, 1 means line buffered, any other positive value means
    ## use a buffer of (approximately) that size (in bytes). A negative buffering means to use the system default, which is usually
    ## line buffered for tty devices and fully buffered for other files.
    
    var f : PythonFile = PythonFile(f: nil, mode: "w", closed: false, softspace: false, encoding: nil, newlines : nil)
    var m : FileMode = fmRead
    if mode == "r" or mode == "rb":
        m = fmRead
    elif mode == "w" or mode == "wb":
        m = fmWrite
    elif mode == "a" or mode == "ab":
        m = fmAppend
    elif mode == "r+" or mode == "rb+":
        m = fmReadWriteExisting
    elif mode == "w+" or mode == "wb+":
        m = fmReadWrite
    f.f = open(filename, m, buffering)
    f.mode = mode
    f.name = filename
    return f


proc close*(file : PythonFile) {.noreturn.} = 
    ## Closes the file.
      
    file.f.close()
    file.closed = true


proc write*(file : PythonFile, s : string) {.noreturn.} = 
    ## Writes ``s`` to the file.
    
    file.f.write(s)


proc write*(file : PythonFile, s : float32) {.noreturn.} = 
    ## Writes ``s`` to the file.
    
    file.f.write(s)


proc write*(file : PythonFile, s : int) {.noreturn.} = 
    ## Writes ``s`` to the file.
    
    file.f.write(s)


proc write*(file : PythonFile, s : BiggestInt) {.noreturn.} = 
    ## Writes ``s`` to the file.
    
    file.f.write(s)


proc write*(file : PythonFile, s : BiggestFloat) {.noreturn.} = 
    ## Writes ``s`` to the file.
    
    file.f.write(s)


proc write*(file : PythonFile, s : bool) {.noreturn.} = 
    ## Writes ``s`` to the file.
    
    file.f.write(s)


proc write*(file : PythonFile, s : char) {.noreturn.} = 
    ## Writes ``s`` to the file.
    
    file.f.write(s)


proc write*(file : PythonFile, s : cstring) {.noreturn.} = 
    ## Writes ``s`` to the file.
    
    file.f.write(s)


proc read*(file : PythonFile): string = 
    ## Reads all of the contents of the file.
    
    var i = int(file.f.getFilePos())
    file.f.setFilePos(0)
    var s : string = file.f.readAll()
    return s.substr(i)


proc read*(file : PythonFile, count : int): string = 
    ## Reads the specified number of bytes from the file.
    
    var s = newSeq[char](count)
    var r : string = ""
    discard file.f.readChars(s, 0, count)
    for i in s:
        r &= $i
    return r


proc readline*(file : PythonFile): string = 
    ## Reads a line from the file.
    
    var s : string = file.f.readLine()
    if file.f.endOfFile():
        return s
    else:
        return s & "\n"


proc readline*(file : PythonFile, count : int): string = 
    ## Reads a line from the file, up to a maximum of the specified number of bytes.
    
    var s : string = file.readLine()
    if len(s) <= count:
        return s
    else:
        return s.substr(0, count)


proc readlines*(file : PythonFile): seq[string] = 
    ## Reads all of the lines from the file.
    
    file.f.setFilePos(0)
    var a : string = file.read()
    file.f.setFilePos(0)
    var s = newSeq[string](countLines(a))
    for i in 0..countLines(a):
        if file.f.endOfFile():
            break
        s[i] = file.readline()
    return s


proc readlines*(file : PythonFile, count : int): seq[string] = 
    ## Reads all of the lines from the file, up to a maximum of the specified number of bytes.
    
    file.f.setFilePos(0)
    var a : string = file.read()
    file.f.setFilePos(0)
    var s = newSeq[string](countLines(a))
    var c : int = 0
    for i in 0..countlines(a):
        if file.f.endOfFile():
            break
        var n : string = file.readLine()
        c += len(n)
        if c < count:
            s[i] = n
        elif c > count:
            var diff : int = len(n) - (c - count)
            s[i] = n.substr(0, diff)
            break
        else:
            s[i] = n
            break
    return s


proc flush*(file : PythonFile) {.noreturn.} = 
    ## Flushes the file's internal buffer.
    
    file.f.flushFile()


proc fileno*(file : PythonFile): FileHandle = 
    ## Returns the underlying file handle. Note that due to implementation details this is NOT the same in Nimrod as it
    ## is in Python and CANNOT be used the same way!
    
    return file.f.getfileHandle()


proc tell*(file : PythonFile): int = 
    ## Returns the file's current position.
    
    return int(file.f.getFilePos())


proc seek*(file : PythonFile, offset : int) {.noreturn.} = 
    ## Sets the file's current position to the specified value.
    
    file.f.setFilePos(offset)
        

proc seek*(file : PythonFile, offset : int, whence : int) {.noreturn.} = 
    ## Sets the file's current position to the specified value. ``whence`` can be either 0 (absolute positioning),
    ## 1 (seek relative to current position), or 2 (seek relative to file's end).
    
    if whence == 1:
        file.seek(file.tell() + offset)
    elif whence == 2:
        file.seek(int(file.f.getFileSize()) + offset)
    elif whence == 0:
        file.seek(offset)


proc writelines*(file : PythonFile, lines : openarray[string]) {.noreturn.} = 
    ## Writes the lines to the file.
    
    for i in lines:
        file.write(i)


proc isatty*(file : PythonFile): bool = 
    ## Returns ``false``. In Python, this returns whether the file is connected to a tty(-like) device. However,
    ## there is no comparable proc in Nimrod.
    
    return false
