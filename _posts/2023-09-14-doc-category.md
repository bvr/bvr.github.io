---
layout: post
title: Get document category
published: yes
tags:
  - C#
  - .NET
  - Word
  - xml
  - System.IO.Packaging
  - System.Xml.XDocument
  - EnumerateFiles
  - GetPart
  - Package
---
At work we use Word documents with some helpers to define requirements, so there are many such files. There are different kinds of the documents (high-level requirements, low-level, tests, etc). The kind is stored in the document properties, namely in the `category` field.

I needed to parse out the data for all documents, so I can do an analysis. I put together a simple .NET 7.0 project with following nuget packages:

 - `System.IO.Packaging`
 - `System.Xml.XDocument`

The code is then very straightforward, just enumerate all `*.docx` files in an input directory and from each extract the category property. First nuget `System.IO.Packaging` allows to easily reach into package and get its part. The part is then just a XML file, so XML parser helps to get to actual properties.

```c#
string inputDirectory = @".";
foreach (string file in Directory.EnumerateFiles(inputDirectory, "*.docx", SearchOption.AllDirectories))
{
    try
    {
        var package = Package.Open(file, FileMode.Open, FileAccess.ReadWrite);
        var corePart = package.GetPart(new Uri("/docProps/core.xml", UriKind.Relative));
        XDocument settings;
        using (TextReader tr = new StreamReader(corePart.GetStream()))
            settings = XDocument.Load(tr);

        XNamespace cp = "http://schemas.openxmlformats.org/package/2006/metadata/core-properties";
        string category = settings.Root.Element(cp + "category")?.Value ?? "<NONE>";
        Debug.WriteLine($"{file} - {category}");
    }
    catch (Exception e)
    {
        Debug.WriteLine($"Failed processing {file}: {e}");
    }
}
```
