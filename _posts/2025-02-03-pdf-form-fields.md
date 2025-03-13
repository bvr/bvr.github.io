---
layout: post
title: PDF Form fields
published: yes
tags:
  - C#
  - .NET
  - iText
  - PDF
  - AcroForm
  - Form
  - Field
---
Recently I worked on a code to extract form fields from PDF files. These fields are fillable and have options for validation to help users to provide valid data. The data are stored within the PDF file and can be extracted from them using various libraries. I selected [iText][1] library because I used it before in [comments extraction]({% post_url 2023-08-04-pdf-extract-comments %}) and it worked nicely. It turned out to be quite easy.

Let's create a small [record class]({% post_url 2023-02-03-records %}) to store the fields and related data.

```c#
public record class FormField(string Name, string Value, string[] States);
```

Following class container has a static method to get all form fields from supplied PDF, their values and if it is some kind of combobox, also all states available.

```c#
using iText.Kernel.Pdf;
using iText.Kernel.Pdf.Annot;
using iText.Forms;
using iText.Forms.Fields;

public class PDF 
{
    public static IEnumerable<FormField> GetFormFields(string pdfFilePath)
    {
        using (var fileStream = new FileStream(pdfFilePath, FileMode.Open))
        using (var pdfReader = new PdfReader(fileStream))
        using (var pdfDocument = new PdfDocument(pdfReader))
        {
            PdfAcroForm pdfAcroForm = PdfAcroForm.GetAcroForm(pdfDocument, true);
            foreach (var f in pdfAcroForm.GetAllFormFields())
                yield return new FormField(f.Key, f.Value.GetDisplayValue(), f.Value.GetAppearanceStates());
        }
    }
}
```

It can be used like this:

```c#
foreach(FormField ff in PDF.GetFormFields("file.pdf")) 
    Console.WriteLine(ff);
```

[1]: https://itextpdf.com/
