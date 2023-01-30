---
layout: post
title: BenchmarkDotNet
published: yes
tags:
  - C#
  - BenchmarkDotNet
  - benchmark
  - Stopwatch
---
Sometimes you need to measure elapsed time of a process. Probably simplest approach is something like this

```c#
Stopwatch timer = new();
DoSomething();
Console.WriteLine(timer.Elapsed);
```

This gives some idea about the performance, but if you need something more complex, it is useful to write a benchmark. Here is small example written using [BenchmarkDotNet][1] to measure ways to put strings together. The class below initializes `N` string of length `20`, then compare three methods to put them together separated by space. 

```c#
public class StringBenchmark
{
    private const int N = 1000;
    private const int StringLength = 20;
    private readonly string[] data;

    public StringBenchmark() 
    { 
        data = new string[N];
        for(int i = 0; i < N; i++)
            data[i] = new string('*', StringLength);
    }

    [Benchmark]
    public string Join ()
    {
        return string.Join(" ", data);
    }

    [Benchmark]
    public string Additions()
    {
        string result = "";
        foreach(string one in data)
            result += one + " ";
        return result;
    }

    [Benchmark]
    public string StringBuilder() {
        StringBuilder sb = new();
        foreach(string one in data)
        {
            sb.Append(one);
            sb.Append(" ");
        }
        return sb.ToString();
    }
}
```

When you run it with 

```c#
var summary = BenchmarkRunner.Run<StringBenchmark>();
```

It provides lengthy output with many details, but quite handy summary like this:

```
// * Summary *

BenchmarkDotNet=v0.13.4, OS=Windows 10 (10.0.19042.2486/20H2/October2020Update)
Intel Core i5-8400H CPU 2.50GHz (Coffee Lake), 1 CPU, 8 logical and 4 physical cores
.NET SDK=7.0.102
  [Host]     : .NET 6.0.13 (6.0.1322.58009), X64 RyuJIT AVX2 [AttachedDebugger]
  DefaultJob : .NET 6.0.13 (6.0.1322.58009), X64 RyuJIT AVX2


|        Method |         Mean |      Error |     StdDev |
|-------------- |-------------:|-----------:|-----------:|
|          Join |     9.016 us |  0.1775 us |  0.2866 us |
|     Additions | 1,687.048 us | 32.5457 us | 34.8236 us |
| StringBuilder |    15.119 us |  0.3010 us |  0.5193 us |

// * Warnings *
Environment
  Summary -> Benchmark was executed with attached debugger

// * Hints *
Outliers
  StringBenchmark.Join: Default          -> 2 outliers were removed (9.99 us, 10.37 us)
  StringBenchmark.Additions: Default     -> 3 outliers were removed (1.83 ms..2.13 ms)
  StringBenchmark.StringBuilder: Default -> 1 outlier  was  removed (17.18 us)

// * Legends *
  Mean   : Arithmetic mean of all measurements
  Error  : Half of 99.9% confidence interval
  StdDev : Standard deviation of all measurements
  1 us   : 1 Microsecond (0.000001 sec)

// ***** BenchmarkRunner: End *****
Run time: 00:01:20 (80.14 sec), executed benchmarks: 3

Global total time: 00:01:28 (88.77 sec), executed benchmarks: 3
```

It also builds number of files in `BenchmarkDotNet.Artifacts` directory, including a markdown to include on your github

``` ini

BenchmarkDotNet=v0.13.4, OS=Windows 10 (10.0.19042.2486/20H2/October2020Update)
Intel Core i5-8400H CPU 2.50GHz (Coffee Lake), 1 CPU, 8 logical and 4 physical cores
.NET SDK=7.0.102
  [Host]     : .NET 6.0.13 (6.0.1322.58009), X64 RyuJIT AVX2 [AttachedDebugger]
  DefaultJob : .NET 6.0.13 (6.0.1322.58009), X64 RyuJIT AVX2


```

|        Method |         Mean |      Error |     StdDev |
|-------------- |-------------:|-----------:|-----------:|
|          Join |     9.016 μs |  0.1775 μs |  0.2866 μs |
|     Additions | 1,687.048 μs | 32.5457 μs | 34.8236 μs |
| StringBuilder |    15.119 μs |  0.3010 μs |  0.5193 μs |

From the output is clearly visible the performance of `String.Join` method and `StringBuilder`, where plain additions of strings that leads to many allocations and reallocations is very slow. The library also makes quite easy to parameterize the task, finding how those methods would perform with shorter or longer strings, more or less data, etc.


[1]: https://benchmarkdotnet.org/index.html
