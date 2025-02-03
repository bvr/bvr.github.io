---
layout: post
title: Aggregated table
published: yes
tags:
  - C#
  - .NET
  - Table
  - LINQ
  - GroupBy
  - Aggregate
---
In [Generate table]({% post_url 2023-01-10-table-generation %}) post I presented a little abstraction to output tabular data from `IEnumerable` source. Here is a little demonstration how to use same idea to produce table that would aggregate data from larger source, so our output would not directly correspond to the source.

I was recently working a program that processes zip files that contain output of Test Coverage analysis tool. Each file contains HTML pages with summary table and my program was building summary of those summaries.

First a class to store the data was needed, completely straightforward one. Note I cannot use [records]({% post_url 2023-02-03-records %}) as this was part of older tool that does not use new .NET. So I just listed those properties and let the Visual Studio create a constructor for me.

```c#
public class TestCoverageEntry
{
    public TestCoverageEntry(string zipFilename, string reportName, string sourceName, string subprogram, string complexity, string statements, string branches, string pairs, string analysis)
    {
        ZipFilename = zipFilename;
        ReportName = reportName;
        SourceName = sourceName;
        Subprogram = subprogram;
        Complexity = complexity;
        Statements = statements;
        Branches = branches;
        Pairs = pairs;
        Analysis = analysis;
    }

    public string ZipFilename { get; }
    public string ReportName { get; }
    public string SourceName { get; }
    public string UnitSource { get; }
    public string Subprogram { get; }
    public string Complexity { get; }
    public string Statements { get; }
    public string Branches { get; }
    public string Pairs { get; }
    public string Analysis { get; }

    public bool IsCoverage100()
    {
        string[] metrics = new string[] { Statements, Branches, Pairs };
        return metrics.Where(m => m != "").All(m => m.Contains("100%"));
    }
}
```

The fields `Statements`, `Branches`, and `Pairs` contain information like `165 / 165 (100%)`. The report I need to produce is to group those entries for each report and produce total coverage for each field.

So I needed a way to parse such entries and build something that can be added up and build totals. Here is a class for those:

```c#
public class Coverage
{
    public int Covered { get; }
    public int Total { get; }

    // constructors
    public Coverage() { Covered = 0; Total = 0; }
    public Coverage(int covered, int total) { Covered = covered; Total = total; }

    private static Regex coverageFormat = new Regex(@"(\d+)\s*/\s*(\d+)");

    /// <summary>
    /// Factory to create Coverage from strings like "47 / 88 (52%)"
    /// </summary>
    /// <param name="input">String from Coverage report</param>
    /// <returns>Coverage object</returns>
    public static Coverage FromString(string input)
    {
        if (input == "")
            return new Coverage();

        Match m = coverageFormat.Match(input);
        return new Coverage(int.Parse(m.Groups[1].Value), int.Parse(m.Groups[2].Value));
    }

    public override string ToString()
    {
        try
        {
            return $"{Covered} / {Total} ({Covered * 100 / Total:0}%)";
        }
        catch 
        {
            return string.Empty; 
        }
    }

    public Coverage Add(Coverage c) => new Coverage(Covered + c.Covered, Total + c.Total);
}
```

The usage of the `Coverage` class is something along this lines

```c#
Coverage c = Coverage.FromString("46 / 88 (52%)");
Coverage c2 = new Coverage(1, 1);
Console.WriteLine(c.Add(c2));     // prints 47 / 89 (53%)
```

Now we will just group the test entries and output the aggregation

```c#
List<TestCoverageEntry> testCoverageEntries = GatherTestEntries("*.zip", inputDirectories);
var groupedReport = testCoverageEntries.GroupBy(e => (e.ZipFilename, e.ReportName));

workbook.Worksheets.Add("Summary").Write(new Column<IGrouping<(string, string), TestCoverageEntry>>[]
{
    new Column<IGrouping<(string,string),TestCoverageEntry>>("Unit", x => x.First().ReportName),
    new Column<IGrouping<(string,string),TestCoverageEntry>>("No. of Subprograms", x => x.Count()),
    new Column<IGrouping<(string,string),TestCoverageEntry>>("Statements", 
        x => x.Aggregate(seed: new Coverage(), func: (total, item) => total.Add(Coverage.FromString(item.Statements))).ToString()),
    new Column<IGrouping<(string,string),TestCoverageEntry>>("Branches", 
        x => x.Aggregate(seed: new Coverage(), func: (total, item) => total.Add(Coverage.FromString(item.Branches))).ToString()),
    new Column<IGrouping<(string,string),TestCoverageEntry>>("Pairs", 
        x => x.Aggregate(seed: new Coverage(), func: (total, item) => total.Add(Coverage.FromString(item.Pairs))).ToString()),
    new Column<IGrouping<(string,string),TestCoverageEntry>>("Coverage 100%", x => x.All(test => test.IsCoverage100()) ? "YES" : "NO"),
  },
groupedReport);
```

The aggregation in `Statements`, `Branches`, and `Pairs` uses LINQ `Aggregate` method that starts with the `seed` value and for each entry of the group call function that adds in all of them. Result is accumulated percentage of covered and total cases.