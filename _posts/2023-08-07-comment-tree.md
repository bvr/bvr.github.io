---
layout: post
title: Tree of comments
published: yes
tags:
  - C#
  - .NET
  - record
  - Dictionary
  - tree
  - PDF
---
In [previous article]({% post_url 2023-08-04-pdf-extract-comments %}) I was extracting attached comments from a PDF file. We receive enumeration of `Comment` objects, so we can build a simple method to build the tree of those objects. 

First, we will need list of children (`Replies`) and improve stringification of the Comment. It will first print out its own properties and then indented all replies

```c#
public record class Comment(string? Title, string? Contents, string Date, int PageNumber, double OnPageY, string? InReplyTo)
{
    public string Id { get; } = ComputeIdForComment(Title, Contents, Date, PageNumber);
    public List<Comment> Replies { get; } = new();

    public static string ComputeIdForComment(string? title, string? contents, string? date, int pageNumber)
    {
        using (SHA1 sha = SHA1.Create())
            return System.Convert.ToBase64String(sha.ComputeHash(Encoding.UTF8.GetBytes(string.Join("-", title, contents, date, pageNumber))));
    }

    public override string? ToString()
    {
        return $"{Title} on {Date}: {Contents} (page {PageNumber})"
            + "\n" + string.Join("\n", Replies.Select(c => "\t" + c.ToString()));
    }
}
```

Now a method that will keep track of all `Id` entries and comments that have set the `InReplyTo` property add under their parents. Remaining comments will go into root comments and will be returned as another enumerable

```c#
private static IEnumerable<Comment> BuildCommentTree(IEnumerable<Comment> comments)
{
    IDictionary<string, Comment> commentById = comments.ToDictionary(c => c.Id);
    List<Comment> rootComments = new();

    foreach(Comment c in commentById.Values.OrderBy(c => c.PageNumber).ThenBy(c => c.OnPageY).ThenBy(c => c.Date)) 
    { 
        if(c.InReplyTo != null && commentById.ContainsKey(c.InReplyTo))
            commentById[c.InReplyTo].Replies.Add(c);
        else
            rootComments.Add(c);
    }

    return rootComments;
}
```

Usage is very similar to last time, we can just chain in the `BuildCommentTree` method

```c#
foreach (Comment cm in BuildCommentTree(ExtractComments(inputPdf))) 
    Console.WriteLine(cm);
```
