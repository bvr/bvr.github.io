---
layout: post
title: Send email with Outlook
published: yes
tags:
  - C#
  - Outlook
  - Attachment
  - Email
---
I wrote few days ago about [stricter rules for using our company SMTP server][1]. Making it more secure is an option, unfortunately they shortly pushed another condition to the mix - the sender must have a static IP address. 

While this is not a problem for servers, for normal users it is not achievable. So I kept looking for further options how to send an email from user machine. Fortunately, all users have Outlook installed, so I could use that.

First, in C# project, select `Dependencies`/`Add COM Reference ...`, check `Microsoft Outlook 16.0 Object Library` and click `OK`. An entry `Interop.Microsoft.Office.Interop.Outlook` should be added in the list.

Then we just need to use it:

```c#
using Outlook = Microsoft.Office.Interop.Outlook;
```

The using command above creates alias for the specified namespace, so further calls have reasonable naming:

```c#
Outlook.Application outlook = new();
var mail = outlook.CreateItem(Outlook.OlItemType.olMailItem);
mail.To = "one@work.com";
mail.Cc = "two@work.com";
mail.BodyFormat = Outlook.OlBodyFormat.olFormatPlain;
mail.Subject = "Some subject";
mail.Body = "Text of the email";
mail.Attachments.Add(Path.GetFullPath("some_file.xlsx");
mail.Send();
```

This code composes a mail and sends it. Another option is to show the email and let user to check it and send themselves. Just add

```c#
mail.Display();
```

and omit last `Send` method call.

[1]: {% post_url 2025-10-22-smtp-secure %}