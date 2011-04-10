---
layout: post
title: Simple web scraping with perl
category: perl
published: no
perex: >
   ??
tags:
   - perl
   - LWP::Simple
   - HTML::TreeBuilder
   - URI
   - Encoding
---
Something there is something on web that I would like to use. The following article goes how to locate and get web-pages, parse and extract data from them.

The code below is real-life problem I needed to solve. There was nice web [kaloricketabulky.cz](http://www.kaloricketabulky.cz) (calorie tables in english) that I used to find out what calorie consumption I had on various activities like swimming. 

First, we need an URL (uniform resource locator) address of page we want. 



Building blocks:

 - how to get a page from specific URL
 - how to parse HTML string and find specific contents
 - how to compose new URL from original and relative link


## The script

{% highlight perl %}
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
{% endhighlight %}
