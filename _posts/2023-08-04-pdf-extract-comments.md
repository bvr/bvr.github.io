---
layout: post
title: Extract PDF comments
published: yes
tags:
  - C#
  - record
  - iText7
  - PDF
---
For one recent project I needed to extract comments and annotations from PDF files. They are used at work for document reviews and having them listed outside of Adobe environment allows to track them and make sure they are properly addressed.

Quick search over internet got me to [iText7][1] C# nuget. Starting with a storage for the comments, I reached for [C# records]({% post_url 2023-02-03-records %}) to build a small model

```c#
public record class Comment(string? Title, string? Contents, string Date, int PageNumber, double OnPageY, string? InReplyTo)
{
    public string Id { get; } = ComputeIdForComment(Title, Contents, Date, PageNumber);

    public static string ComputeIdForComment(string? title, string? contents, string? date, int pageNumber)
    {
        using (SHA1 sha = SHA1.Create())
            return System.Convert.ToBase64String(sha.ComputeHash(Encoding.UTF8.GetBytes(string.Join("-", title, contents, date, pageNumber))));
    }
}
```

All regular stuff. The nullable items are there because the library returns everything in a PdfString type and it can easily be null if the property is not available.

The extractor is then opening the PDF, traversing all pages and annotations on them and yields annotations of appropriate types

```c#
public static IEnumerable<Comment> ExtractComments(string pdfFilePath)
{
    using (var fileStream = new FileStream(pdfFilePath, FileMode.Open))
    using (var pdfReader = new PdfReader(fileStream))
    using (var pdfDocument = new PdfDocument(pdfReader))
    {
        int pages = pdfDocument.GetNumberOfPages();
        for (int pageNumber = 1; pageNumber <= pages; pageNumber++)
        {
            foreach (var annot in pdfDocument.GetPage(pageNumber).GetAnnotations())
            {
                Type annotType = annot.GetType();

                // PdfTextAnnotation - Comment, PdfStampAnnotation - Applied Stamp, PdfTextMarkupAnnotation - Highlighted Text
                if (annotType == typeof(PdfTextAnnotation) || annotType == typeof(PdfStampAnnotation) || annotType == typeof(PdfTextMarkupAnnotation))
                {
                    // Skip hidden annotations
                    if ((annot.GetFlags() & 0x02) != 0)
                        continue;

                    // Extract position on page and replies
                    var posOnPage = double.Parse(annot.GetRectangle().Get(1)?.ToString() ?? "0");
                    PdfMarkupAnnotation markupAnnot = annot as PdfMarkupAnnotation;
                    string? inReplyId = null;
                    if (markupAnnot?.GetInReplyToObject() != null)
                    {
                        var inReplyTo = markupAnnot.GetInReplyTo();
                        inReplyId = Comment.ComputeIdForComment(inReplyTo.GetTitle()?.ToString(), inReplyTo.GetContents()?.ToString(), inReplyTo.GetDate().ToString(), pageNumber);
                    }

                    yield return new Comment(annot.GetTitle()?.ToString(), annot.GetContents()?.ToString(), annot.GetDate().ToString(), pageNumber, posOnPage, inReplyId);
                }
            }
        }
    }
}
```

So we can now iterate over all comments and using the `InReplyTo` property we can build the comment tree.

```c#
foreach (Comment cm in ExtractComments(inputPdf)) 
    Console.WriteLine(cm);
```

Next time we can look on how to build the tree of comments and present them in order.

[1]: https://itextpdf.com