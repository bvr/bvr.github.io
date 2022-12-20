---
layout: post
title: Using CommandLineParser to handle C# program parameters
published: yes
tags:
  - C#
  - CommandLineParser
  - .net
---
As I was spoiled by various nice command-line (CLI) arguments parsing solutions
from other languages, when using C# at work I was looking for some convenient
solution for the problem. 

My requirements were:

 - declarative interface for all options, ideally used as storage and definition at the same time
 - support of various types (bool, number, string, array)
 - default values and required options
 - automatic generation of help message

What covered all items above was [CommandLineParser][1] nuget package. 

The definition of options is a C# class decorated with `Option` attributes that cover 
command-line switches, defaults, help and other attributes needed to setup your CLI.

```c#
class ConsoleOptions
{
    [Option('l', "legacy", Default = false, HelpText = "Generate also legacy .cpp and .h files")]
    public bool GenerateLegacyFiles { get; set; }

    [Option('o', "output", Default = "output.bin", HelpText = "Name of generated binary file")]
    public string BinaryOutputFilename { get; set; }

    [Option('m', "map", HelpText = "Generate map of the binary file")]
    public string GenerateBinaryFileMap { get; set; }

    [Option('e', "use-big-endian", Default = false, HelpText = "Use big endian encoding for binary file")]
    public bool BigEndian { get; set; }

    [Value(0, HelpText = "List of input XML files")]
    public IEnumerable<string> InputXMLFiles { get; set; }

    [Usage(ApplicationAlias = "Generator.exe")]
    public static IEnumerable<Example> Examples
    {
        get
        {
            return new List<Example>
            {
                new Example("Generate empty file", new ConsoleOptions() { BinaryOutputFilename = "EMPTY.BIN" }),
                new Example("Generate binary file from specified files", new ConsoleOptions() { InputXMLFiles = new List<string>() { "file1.xml", "file2.xml" } }),
                new Example("Generate binary and legacy files for specified file", new ConsoleOptions() { GenerateLegacyFiles = true, InputXMLFiles = new List<string>() { "file1.xml" } }),
                new Example("Generate binary and map file for specified file", new ConsoleOptions() { GenerateBinaryFileMap = "output.map", InputXMLFiles = new List<string>() { "file2.xml" } }),
            };
        }
    }
}
```

Nice touch is method `Examples` that demonstrate the nuget's ability to construct command-line examples 
from the structure.

Usage is pretty simple, something like this:

```c#
class Program
{
    static void Main(string[] args)
    {
        Program app = new Program();
        var result = Parser.Default.ParseArguments(() => new ConsoleOptions(), args);
        result.WithParsed(options => app.Run(options));
    }

    private void Run(ConsoleOptions options)
    {
        Console.WriteLine($"{HeadingInfo.Default} w/params:\n"
            + $"  Input XML Files:        {string.Join(", ", options.InputXMLFiles)}\n"
            + $"  Binary File:            {options.BinaryOutputFilename}\n"
            + $"  Binary File Big-Endian: {options.BigEndian}\n"
            + $"  Map of binary file:     {options.GenerateBinaryFileMap}\n"
            + $"  Also generate legacy:   {options.GenerateLegacyFiles}"
        );
    }
}
```

When called with `--help` option or when there is a problem with the input, it produces 
nice error message like this:

```
Generator 1.0.0
Copyright (C) 2022 bvr
USAGE:
Generate empty file:
  Generator.exe --output EMPTY.BIN
Generate binary file from specified files:
  Generator.exe file1.xml file2.xml
Generate binary and legacy files for specified file:
  Generator.exe --legacy file1.xml
Generate binary and map file for specified file:
  Generator.exe --map output.map file2.xml

  -l, --legacy            (Default: false) Generate also legacy .cpp and .h files

  -o, --output            (Default: output.bin) Name of generated binary file

  -m, --map               Generate map of the binary file

  -e, --use-big-endian    (Default: false) Use big endian encoding for binary file

  --help                  Display this help screen.

  --version               Display version information.

  value pos. 0            List of input XML files
```

When called with valid arguments, it executes the `Run` method:

```sh
Generator.exe --output out.bin --map out.map a.xml b.xml
```

produces

```
Generator 1.0.0 w/params:
  Input XML Files:        a.xml, b.xml
  Binary File:            out.bin
  Binary File Big-Endian: False
  Map of binary file:     out.map
  Also generate legacy:   False
```

Overall I am pretty happy with the library.

[1]: https://github.com/commandlineparser/commandline