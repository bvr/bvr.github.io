---
layout: post
title: RSS Validation
published: yes
tags:
  - RSS
  - XML
  - XML::LibXML
  - XSD
  - Schema
---
My wife was trying to setup [RSS][1] for her web - [poplety.cz](https://poplety.cz/). In case you don't know, the [RSS][1] stands for *RDF Site Summary* or *Really Simple Syndication*. It is basically XML-based format that provides overview of recent changes on your web-site.

There is many tools to work with the format. I am using [feedly][2] to follow updates on my favorite pages. This is how it shows last updates on this web:

![Feedly](/img/feedly.png)

There is [a specification][3] for the format. Unfortunately there is no official XML schema to easily validate the files. Googling a bit, I found some schemas of varying quality. After some testing, I selected [this one][4], quite detailed version that also include checking of included emails and dates.

I covered checking a XML file against a schema in [one of previous posts]({% post_url 2023-06-30-xsd-validate %}), the code is rather simple utilization of [XML::LibXML][5] library in for perl:

```perl
use XML::LibXML;
use Try::Tiny;

my $filename = shift;
my $dom    = XML::LibXML->load_xml(   location => $filename);
my $schema = XML::LibXML::Schema->new(location => 'rss-2_0_1-rev9.xsd');
try { 
    $schema->validate($dom) 
}
catch {
    die "There is a problem with the configuration: $_";
};
print "The $filename is valid\n";
```

Using this tool, I was able to quickly find problems with her file - there was one mismatched tag and one invalid date format.

[1]: https://en.wikipedia.org/wiki/RSS
[2]: https://feedly.com
[3]: https://www.rssboard.org/rss-specification
[4]: https://schemas.liquid-technologies.com/w3c/rss/2.0.1.9/?page=rss-2_0_1-rev9_xsd.html
[5]: https://metacpan.org/pod/XML::LibXML
