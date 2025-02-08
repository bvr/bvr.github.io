---
layout: post
title: Read MS Access MDB
published: yes
tags:
  - C#
  - .NET
  - MS Access
  - MDB
  - Database
---
Recently, I worked on a tool that needed to fetch data from an old MS Access `.mdb` database. Fortunately, Microsoft still includes an ODBC driver, `Microsoft.Jet.OleDb.4.0`, even in Windows 11. However, note that this driver is only available as a 32-bit version, so any application interacting with it must also run as a 32-bit process.

Lets build a class to load the data and provide it through it interface. My case was relatively small databases, so no special lazy loading was needed. 

First, we need a class for data storage, something like below or built as a [C# record]({% post_url 2023-02-03-records %})

```c#
public class Person
{
    public string Name { get; init; } = "";
    public string Street { get; init; } = "";
    public string City { get; init; } = "";
}
```

The database class will be used like this:

```c#
PeopleDatabase db = PeopleDatabase.Load(filePath);
List<Person> people = db.People;
```

The `PeopleDatabase` class is initialized using the static `Load` method, as its constructor is private. During loading, the connection is established, and data is queried and mapped into the `Person` class, allowing us to work with typed data and add any necessary functionality directly to that class.

The database class makes use of two private helper methods, `ExecuteReader` and `ExecuteCommand`, built on top of `OleDbCommand`. These methods simplify the process of querying and executing commands on the database.

Here's the full implementation:

```c#
public class PeopleDatabase
{
    public string FilePath { get; private set; }
    public List<Person> People { get; private set; } = new();

    private PeopleDatabase(string filePath) 
    {
        FilePath = filePath;
    }

    public static PeopleDatabase Load(string filePath)
    {
        PeopleDatabase db = new(filePath);

        using (OleDbConnection connection = new($@"Provider=Microsoft.Jet.OleDb.4.0;Data Source={filePath}"))
        {
            connection.Open();

            db.People = ReadPeople(connection);
        }

        return db;
    }

    private static List<Person> ReadPeople(OleDbConnection connection)
    {
        DataSet people = ExecuteReader(@"SELECT Name, Street, City FROM People ORDER BY Name", connection);

        return people.Tables[0].Rows.Cast<DataRow>().Select(x => new Person()
        {
            Name = (string)x["Name"],
            Street = (string)x["Street"],
            City = (string)x["City"],
        }).ToList();
    }

    private static DataSet ExecuteReader(string commandText, OleDbConnection connection)
    {
        OleDbCommand command = new OleDbCommand(commandText, connection);
        OleDbDataAdapter da = new OleDbDataAdapter(command);

        DataSet dset = new DataSet();
        da.Fill(dset);

        return dset;
    }

    private static void ExecuteCommand(string commandText, OleDbConnection connection)
    {
        OleDbCommand command = new OleDbCommand(commandText, connection);
        command.ExecuteNonQuery();
    }
}
```

This approach works well for small datasets and also makes it easy to create a mock class for testing without needing actual `.mdb` files or drivers.
