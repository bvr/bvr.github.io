---
layout: post
title: Email with attachment
published: yes
tags:
  - C#
  - System.Net.Mail
  - MailMessage
  - SmtpClient
  - Attachments
---
Sending an email from .NET application is fairly easy. There is `System.Net.Mail` namespace that provides all necessary tools. Here is an example how to send complete HTML formatted email with an attachment to number of people and also carbon-copy (cc) some others.

```c#
using System.Net.Mail;
```

First, we need a `SmtpClient` and give it address of actual server. If there is more authentication, there will be more work, but at my work you can just point it to the address.

```c#
string smtpAddress = "smtp.work.com";
SmtpClient smtpClient = new(smtpAddress);
```

Then we need to put together a `MailMessage`. Here I am using the constructor with parameters `from`, `to`, `subject`, and `body`. Note the `to` can contain multiple people separated with comma. Same thing also applies to `CC.Add` method. Adding attachment is as easy.

```c#
MailMessage msg = new("one@work.com", "two@work.com, three@work.com", "Subject line", 
    "Mail message - this is <b>beautiful</b> email.");
msg.IsBodyHtml = true;
msg.CC.Add("four@work.com, five@work.com");
string attachmentPath = "some_important.data";
msg.Attachments.Add(new(attachmentPath, MediaTypeNames.Application.Octet));
```

Last thing, we can send it and handle potential exceptions.

```c#
try
{
    smtpClient.Send(msg);
}
catch (SmtpException ex)
{
    // There is a problem, log it or handle it somehow
}
```
