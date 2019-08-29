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
##    var f: PythonFile = open("my_file.txt", "r")        # f = open("my_file.txt", "r")
##    echo(f.readline())                                  # print(f.readline())
##    var s: string = f.read(10)                          # s = f.read(10)
##    f.close()                                           # f.close()
##
## .. code-block:: nimrod
##
##    # Open a file for writing, write "Hello World!", then write multiple lines at once.
##    var f: PythonFile = open("my_file.txt", "w")        # f = open("my_file.txt", "w")
##    f.write("Hello World!")                             # f.write("Hello World!")
##    f.writelines(["This", "is", "an", "example"])       # f.writelines(["This", "is", "an", "example"])
##    f.close()                                           # f.close()
##
## .. code-block:: nimrod
##
##    # Open a file for reading or writing, then read and write from multiple locations
##    # using seek() and tell().
##    var f: PythonFile = open("my_file.txt", "r+")       # f = open("my_file.txt", "r+")
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
    PythonFile* = ref object
        f*: File
        mode*: string
        closed*: bool
        name*: string
        softspace*: bool
        encoding*: string
        newlines*: string
        filename*: string


proc open*(filename: string, mode: string = "r", buffering: int = -1): PythonFile = 
    ## Opens the specified file.
    ##
    ## mode can be either ``r`` (reading), ``w`` (writing), ``a`` (appending), ``r+`` (read/write, only existing files), and ``w+``
    ## (read/write, file created if needed).
    ##
    ## ``buffering`` specifies the file’s desired buffer size: 0 means unbuffered, 1 means line buffered, any other positive value means
    ## use a buffer of (approximately) that size (in bytes). A negative buffering means to use the system default, which is usually
    ## line buffered for tty devices and fully buffered for other files.
    
    var f: PythonFile = PythonFile(f: nil, mode: mode, closed: false, softspace: false, encoding: "", newlines: "", filename: filename)
    var m: FileMode
    case mode:
        of "r", "rb":
            m = fmRead
        of "w", "wb":
            m = fmWrite
        of "a", "ab":
            m = fmAppend
        of "r+", "rb+":
            m = fmReadWriteExisting
        of "w+", "wb+":
            m = fmReadWrite
        else:
            m = fmRead
    f.f = open(filename, m, buffering)
    return f


proc close*(file: PythonFile): void =
    ## Closes the file.
      
    file.f.close()
    file.closed = true


proc tell*(file: PythonFile): int = 
    ## Returns the file's current position.
    
    return int(file.f.getFilePos())


proc seek*(file: PythonFile, offset: int): void = 
    ## Sets the file's current position to the specified value.
    
    file.f.setFilePos(offset)
        

proc seek*(file: PythonFile, offset: int, whence: int): void = 
    ## Sets the file's current position to the specified value. ``whence`` can be either 0 (absolute positioning),
    ## 1 (seek relative to current position), or 2 (seek relative to file's end).
    
    case whence:
        of 0:
            file.seek(offset)
        of 1:
            file.seek(file.tell() + offset)
        of 2:
            file.seek(int(file.f.getFileSize()) + offset)
        else:
            file.seek(offset)


proc write*(file: PythonFile, s: string): void =
    ## Writes ``s`` to the file.
    
    file.f.write(s)


proc write*(file: PythonFile, s: float32): void =
    ## Writes ``s`` to the file.
    
    file.f.write(s)


proc write*(file: PythonFile, s: int): void =
    ## Writes ``s`` to the file.
    
    file.f.write(s)


proc write*(file: PythonFile, s: BiggestInt): void =
    ## Writes ``s`` to the file.
    
    file.f.write(s)


proc write*(file: PythonFile, s: BiggestFloat): void =
    ## Writes ``s`` to the file.
    
    file.f.write(s)


proc write*(file: PythonFile, s: bool): void =
    ## Writes ``s`` to the file.
    
    file.f.write(s)


proc write*(file: PythonFile, s: char): void =
    ## Writes ``s`` to the file.
    
    file.f.write(s)


proc write*(file: PythonFile, s: cstring): void =
    ## Writes ``s`` to the file.
    
    file.f.write(s)


proc read*(file: PythonFile): string = 
    ## Reads all of the contents of the file.
    
    let pos = int(file.f.getFilePos())
    file.f.setFilePos(0)
    return file.f.readAll().substr(pos)


proc read*(file: PythonFile, count: int): string = 
    ## Reads the specified number of bytes from the file.
    
    var chars: seq[char] = newSeq[char](count)
    discard file.f.readChars(chars, 0, count)
    return chars.join()


proc readline*(file: PythonFile): string = 
    ## Reads a line from the file.
    
    let line: string = file.f.readLine()
    if file.f.endOfFile():
        return line
    else:
        return line & "\n"


proc readline*(file: PythonFile, count: int): string = 
    ## Reads a line from the file, up to a maximum of the specified number of bytes.
    
    let line: string = file.readLine()
    if len(line) <= count:
        return line
    else:
        file.seek(-1 * (len(line) - count), 1)
        return line.substr(0, count)


proc readlines*(file: PythonFile): seq[string] = 
    ## Reads all of the lines from the file.
    
    file.f.setFilePos(0)
    let contents: string = file.read()
    file.f.setFilePos(0)
    var lines: seq[string] = @[]
    for index in 0..countLines(contents):
        if file.f.endOfFile():
            break
        lines.add(file.readline())
    return lines


proc readlines*(file: PythonFile, count: int): seq[string] = 
    ## Reads all of the lines from the file, up to a maximum of the specified number of bytes.
    
    file.f.setFilePos(0)
    let contents: string = file.read()
    file.f.setFilePos(0)
    var lines: seq[string]= newSeq[string](countLines(contents))
    var charCount: int = 0
    for index in 0..countlines(contents):
        if file.f.endOfFile():
            break
        let line: string = file.readLine()
        charCount += len(line)
        if charCount < count:
            lines[index] = line
        elif charCount > count:
            var diff: int = len(line) - (charCount - count)
            lines[index] = line.substr(0, diff)
            file.seek(-1 * (charCount - count), 1)
            break
        else:
            lines[index] = line
            break
    return lines


proc flush*(file: PythonFile): void =
    ## Flushes the file's internal buffer.
    
    file.f.flushFile()


proc fileno*(file: PythonFile): FileHandle = 
    ## Returns the underlying file handle. Note that due to implementation details this is NOT the same in Nim as it
    ## is in Python and CANNOT be used the same way!
    
    return file.f.getfileHandle()


proc writelines*(file: PythonFile, lines: openarray[string]): void =
    ## Writes the lines to the file.
    
    for line in lines:
        file.write(line)


proc isatty*(file: PythonFile): bool =
    ## Returns true if the opened file is a tty device, else returns false

    when defined(unix):
        proc isattyUnix(desc: cint): cint {.importc: "isatty", header: "unistd.h".}
        return isattyUnix(file.fileno()) == 1
    elif defined(windows):
        proc isattyWin(desc: cint): cint {.importc: "_isatty", header: "io.h".}
        return isattyWin(file.fileno()) != 0
    else:
        return false