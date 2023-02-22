---
layout: post
title: Dictionary initialization
published: yes
tags:
  - C#
  - Dictionary
  - Init
---
Suppose we have a class to store a student

```c#
record class Student
{
    public int ID { get; init; }
    public string FirstName { get; init; }
    public string LastName { get; init; }
    public bool IsValid { get; init; }
}
```

If we want to create a dictionary indexed by the `ID` property and populate it with items hardcoded in the program, we have following options to use:

 1. Use some kind of `IEnumerable<Student>` with `ToDictionary` LINQ method
 2. Use pairs initializer
 3. Use public indexer

First options is quite convenient, we don't need to repeat the `ID` definition and same approach can be easily used when items are loaded from an external source like database

```c#
List<Student> students = new()
{
    new Student { ID = 1, FirstName = "Joe", LastName = "White", IsValid = true },
    new Student { ID = 2, FirstName = "Bill", LastName = "Red", IsValid = true },
    new Student { ID = 3, FirstName = "James", LastName = "Purple", IsValid = false },
    new Student { ID = 4, FirstName = "Tim", LastName = "Yellow", IsValid = true },
};

Dictionary<int, Student> studentsById = students.ToDictionary(s => s.ID);
```

Second approach looks like this

```c#
Dictionary<int, Student> studentsById = new()
{
    { 1, new Student { ID = 1, FirstName = "Joe", LastName = "White", IsValid = true } },
    { 2, new Student { ID = 2, FirstName = "Bill", LastName = "Red", IsValid = true } },
    { 3, new Student { ID = 3, FirstName = "James", LastName = "Purple", IsValid = false } },
    { 4, new Student { ID = 4, FirstName = "Tim", LastName = "Yellow", IsValid = true } },
};
```

Last approach is similar, but a little more emphasizes the key and reduces clutter with curly brackets

```c#
Dictionary<int, Student> studentsById = new()
{
    [1] = new Student { ID = 1, FirstName = "Joe", LastName = "White", IsValid = true },
    [2] = new Student { ID = 2, FirstName = "Bill", LastName = "Red", IsValid = true },
    [3] = new Student { ID = 3, FirstName = "James", LastName = "Purple", IsValid = false },
    [4] = new Student { ID = 4, FirstName = "Tim", LastName = "Yellow", IsValid = true },
};
```
