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
Recently I worked on a code to extract form fields from PDF files. Using [iText][1] library and C# it can be done quite easily.

First, let's create a small storage [record class]({% post_url 2023-02-03-records %}):

```c#
public record class FormField(string Name, string Value, string[] States);
```

Next, a static method to get all form fields, their values and if it is some kind of combobox, also all states available: 

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
