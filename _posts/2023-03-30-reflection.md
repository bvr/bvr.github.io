---
layout: post
title: Reflection
published: yes
tags:
  - C#
  - Reflection
  - SQL
  - GetType
  - GetValue
---
C# provides nice interface to introspect classes and inspect its properties. It is called **Reflection**. Lets consider simplified example where we would try to generate SQL insert statement from any class supplied.

First lets build plain class for a person

```c#
public class Person
{
    public string FirstName { get; set; }
    public string LastName { get; set; }
    public string Street { get; set; }
    public string City { get; set; }
}
```

Say we would like to use it like this

```c#
var guy = new Person
{
    FirstName = "Jim",
    LastName = "Black",
    Street = "123 Elm Street",
    City = "Boston",
};
string sql = BuildInsertQuery(guy);   
// INSERT INTO Person (FirstName, LastName, Street, City) VALUES ("Jim", "Black", "123 Elm Street", "Boston")
```

The method for building the query first uses `object` classes method `GetType` to extract the meta-class. It provides means to get name of the class via `Name` property and provides handy `GetProperties` method.

We will first locate all string properties, then put their names into first list and data extracted with `GetValue` method

```c#
public static string BuildInsertQuery(object data)
{
    // get properties of the model
    Type type = data.GetType();
    PropertyInfo[] props = type.GetProperties().Where(pi => pi.PropertyType == typeof(string)).ToArray();

    // build the query
    return $"INSERT INTO {type.Name} " 
         + $"({string.Join(", ", props.Select((x) => x.Name))}) VALUES " 
         + $"({string.Join(", ", props.Select((x) => "\"" + MySqlHelper.EscapeString(x.GetValue(data, null) as string) + "\""))})";
}
```

The example is deliberately simple, but shows how to build data-driven interfaces. In combination with [attributes]({% post_url 2023-03-16-enum %} ) it can be powerful tool.
