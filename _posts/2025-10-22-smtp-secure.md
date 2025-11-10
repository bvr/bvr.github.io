---
layout: post
title: Secure SMTP
published: yes
tags:
  - C#
  - .NET
  - System.Net.Mail
  - MailMessage
  - SmtpClient
  - SMTP
  - Secure
  - SSL
---
Some time ago I posted a post about [sending an email using SMTP protocol with C#][1]. Recently I learned that our security department has new thoughts about sending an email. It requires us to use secure SMTP.

There are few things required:

- use of port 587
- use of your email address and password
- use of secure transfer layer

Especially the storing of the password on a server is rather cumbersome. Fortunately there an option to request special account for this operation.

Here is the code:

```c#
using System.Net.Mail;

string userEmail   = "me@work.com";
string password    = "very secure";
string smtpAddress = "smtp.work.com";

NetworkCredential credentials = new(userEmail, password);
using(smtpClient smtpClient = new(SmtpAddress, 587)) 
{
    smtpClient.EnableSsl = true;
    smtpClient.UseDefaultCredentials = false;       // need to be set before Credentials, as it sets it to null
    smtpClient.Credentials = credentials;

    MailMessage msg = new();
    msg.From = new MailAddress(userEmail);
    msg.To.Add("one@work.com");
    msg.To.Add("two@work.com, three@work.com");
    msg.CC.Add("four@work.com, five@work.com");
    string attachmentPath = "some_important.data";
    msg.Attachments.Add(new(attachmentPath, MediaTypeNames.Application.Octet));

    try
    {
        smtpClient.Send(msg);
    }
    catch (SmtpException ex)
    {
        // There is a problem, log it or handle it somehow
    }
}
```

Altogether it is rather simple to send the email like this with .NET libraries.

[1]: {% post_url 2023-10-13-email-with-attachment %}