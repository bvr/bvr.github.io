---
layout: post
title: Title
published: yes
tags:
  - C#
  - MS Access
  - MDB
  - Database
---
Recently I worked on a tool that needs to get data from MS Access database in its old form, the `.mdb`. There is an ODBC driver installed in all Windows, including the version 11 - `Microsoft.Jet.OleDb.4.0`, even though it is only available in 32-bit version, so your application has to be set as such.

Lets build a class to load the data and provide it through it interface. My case was relatively small databases, so no special lazy loading was needed. 

First, we need a class for data storage, something like

```c#
public class Person
{
    public string Name { get; init; } = "";
    public string Street { get; init; } = "";
    public string City { get; init; } = "";
}
```

Usage will be something like this

```c#
PeopleDatabase db = PeopleDatabase.Load(filePath);
List<Person> people = db.People;
```

The database class can only be initialized by static method `Load` as its constructor is private. During the load it builds the connection and query the data and type them into proper class, so we can work with them nicely and add some functionality inherent to the `Person` class. The two private methods `ExecuteReader` and `ExecuteCommand` are simple helpers build on top of `OleDbCommand`, making it easier to query/command the data.

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

The approach works nicely and it also allows to build simple mocking class to test the functionality without dealing with actual `.mdb` files and the drivers. 
