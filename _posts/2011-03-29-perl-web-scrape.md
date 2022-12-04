---
layout: post
title: Simple web scraping with perl
category: perl
published: yes
perex: >
  There is something on web that I would like to use. The following
  article goes on how to locate and get web-pages, parse and extract data from it.
tags:
   - perl
   - LWP::Simple
   - HTML::TreeBuilder
   - URI
   - Encoding
---

The code below is real-life problem I needed to solve. There was nice
web [kaloricketabulky.cz](http://www.kaloricketabulky.cz) (calorie tables in
english) that I used to find out what calorie consumption I had on various
activities like swimming.

Building blocks:

 - how to get a page from specific URL
 - how to parse HTML string and find specific contents
 - how to compose new URL from original and relative link

## Request data from web

We can use [LWP::Simple](https://metacpan.org/pod/LWP::Simple) library to get
a resource from specific url:

```perl
use LWP::Simple qw(get);
my $data = get('http://www.example.com');
```

## Parse contents of a web page

The [HTML::TreeBuilder](https://metacpan.org/pod/HTML::TreeBuilder) provides nice interface
for parsing of the HTML page and bunch of nice methods to extract items based on its attributes.

```perl
my $html = HTML::TreeBuilder->new_from_content($html_string);
for my $link ($html->look_down(id => 'katalog')->find('a')) {
  # do something with links in the "katalog" element
  print $link->attr('href');
}
```

## URL composition

Is easy with [URI](https://metacpan.org/pod/URI) module:

```perl
my $url = URI->new_abs($link, $base_link);    # link can be either absolute or relative
```

## Put together

```perl
use LWP::Simple qw(get);
use HTML::TreeBuilder;
use URI;

my $start_page
  = q{http://www.kaloricketabulky.cz/tabulka-aktivit.php?pismeno=A};

my $html = HTML::TreeBuilder->new_from_content(get($start_page));
my @list_page_urls
  = map { URI->new_abs($_->attr('href'),$start_page)->as_string }
        $html->look_down(id => 'katalog')->find('a');
$html->delete;

my @items = ();
for my $page_url (@list_page_urls) {
    my $html = HTML::TreeBuilder->new_from_content(get($page_url));
    my $item_table_html = $html->look_down(class => 'vypis');

    my @rows   = $item_table_html->find('tr');
    my $header = shift @rows;
    for my $row (@rows) {
        my @cols = map { $_->as_text } $row->find('td');
        push @items, [ @cols ];
    }

    $html->delete;
}

open(my $out,">:encoding(cp1250):utf8", "activities.txt");
for my $item (@items) {
     print {$out} join("\t",@$item), "\n";
}
```
