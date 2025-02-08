---
layout: post
title: Generate table
published: yes
tags:
  - C#
  - .NET
  - Table
---
When building output tables from a data model, it usually require separation of layout generation (column headers, table dimensions) and getting the data. Say we have following class 

```c#
public class Person
{
    public string FirstName { get; }
    public string LastName { get; }
    public string Address { get; }
    public string City { get; }

    public Person(string firstName, string lastName, string address, string city)
    {
        FirstName = firstName;
        LastName = lastName;
        Address = address;
        City = city;
    }
}
```

and data of it

```c#
Person[] people = new Person[]
{
    new Person("Joe", "White", "123 Home", "New York"),
    new Person("John", "Yellow", "45 Drive", "Denver"),
    new Person("Jim", "Black", "72 Street", "Escalante"),
};
```

I created simple approach to put the table definition and data processing into same place, so I can do something like this:

```c#
TableGenerator table = new();
table.WriteWorksheet<Person>("People",
    new Column<Person>[]
    {
        new Column<Person>() { Header = "First Name", GetValue = p => p.FirstName },
        new Column<Person>() { Header = "Last Name", GetValue = p => p.LastName },
        new Column<Person>() { Header = "Address", GetValue = p => p.Address },
        new Column<Person>() { Header = "City", GetValue = p => p.City },
    },
    people
);
```

The call to `WriteWorksheet` method combines name of the table, definition of columns and means to get data from model items. It is also pretty easy to extend such definition with other properties, like formatting, colors, etc.

Definition of `Column` class is pretty simple

```c#
public class Column<T>
{
    public string Header { get; set; }
    public Func<T, object> GetValue { get; set; }
}
```

and here is sample implementation of the `TableGenerator` class that just output some kind of comma-separated list for simplicity

```c#
public class TableGenerator
{
    public void WriteWorksheet<T>(string name, IEnumerable<Column<T>> columns, IEnumerable<T> rows)
    {
        Console.WriteLine($"Sheet: {name}");
        Console.WriteLine(string.Join(",", columns.Select(c => c.Header)));

        Column<T>[] columnArray = columns.ToArray();
        foreach (T row in rows)
            Console.WriteLine(string.Join(",", 
                Enumerable.Range(0, columnArray.Count()).Select(c => columnArray[c].GetValue(row))));
    }
}
```

When run on sample data above, the output is as expected

```
Sheet: People
First Name,Last Name,Address,City
Joe,White,123 Home,New York
John,Yellow,45 Drive,Denver
Jim,Black,72 Street,Escalante
```

I used this approach to produce Excel spreadsheets using [EPPlus][1], build CSV/TSV tables as well as HTML output for web pages. It is easy to extend and the `GetValue` definition in combination with LINQ allow to easy summarize the data or calculate values from other properties in the model.

[1]: https://www.epplussoftware.com/
