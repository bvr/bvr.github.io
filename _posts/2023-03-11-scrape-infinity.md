---
layout: post
title: Scraping infinity scrolling
published: yes
tags:
  - perl
  - Scrape
  - Mojo::UserAgent
  - Mojo::URL
  - Web
  - Infinite scrolling
  - Wordpress
  - Eric Lippert
---
In [one of previous posts]({% post_url 2023-02-28-eric %}) I talked about scraping [Eric Lippert's web][1] to build a list of articles there. As I am reading through them, I noticed that some articles are missing from my list. Inspecting the network communication in developer tools revealed that only first ten entries is returned in the monthly archives page and following entries are loaded with javascript when user scrolls down to the end of the page.

Brief googling revealed that it is so called Infinity scrolling plugin for Wordpress. 

The request itself is HTTP POST like this

![](/img/infinity-request.gif)

Where most information is sent as a form data

![](/img/infinity-data.gif)

There is plenty of fields specified, but with quick experimentation it turned out that only handful is actually needed. So I came with this code to get HTML of all articles related to specific month

```perl
use Mojo::UserAgent;
use Mojo::URL;
use Mojo::DOM;

my $base_url = 'https://ericlippert.com';
my $yy = 2016;
my $mm = 2;

my $ua = Mojo::UserAgent->new(max_redirects => 5);
my $posts = $ua->post(Mojo::URL->new($base_url)->query(infinity => 'scrolling') => form => { 
    'action' => "infinite_scroll",
    'page' => 1,
    'order' => "DESC",
    'query_args[year]' => $yy,
    'query_args[monthnum]' => $mm,
    'query_args[posts_per_page]' => 50,
    'query_args[order]' => "DESC",
});
for my $article (Mojo::DOM->new($posts->res->json->{html})->find('article')->each) {
    my $title = $article->find('.entry-title > a:nth-child(1)')->first;
    printf "%s: %s\n", $title->text, href => $title->{href};
}
```

Testing was successful, this returned all the articles. On top of [Mojo::UserAgent][2] we have seen before, I am using [Mojo::URL][3] to add query fields into the base path and [Mojo::DOM][4] to parse the HTML which is provided in JSON field `html`.

Now we can just wrap the code into few classes to make the usage easier and nicely encapsulated. First, simple storage class for articles, each property only with a getter and constructor to init them

```perl
package Fabulous::Article;
use Moo;

has title => (is => 'ro');
has href  => (is => 'ro');
has tags  => (is => 'ro', default => sub { +[] });

1;
```

And class that can extract list of months and articles in them

```perl
package Fabulous;
use Moo;
use Function::Parameters;
use Mojo::UserAgent;
use Mojo::URL;

use Fabulous::Article;

has base_url => (is => 'ro', default => 'https://ericlippert.com');
has ua       => (is => 'lazy');

method _build_ua() { 
    return Mojo::UserAgent->new(max_redirects => 5);
}

method get_all_months() {
    return $self->ua->get($self->base_url)->res->dom->find('#archives-2 a')->each;
}

method get_articles_for_month($month) {
    my $month_url = $month->{href};
    my ($yy, $mm) = Mojo::URL->new($month_url)->path =~ /\d+/g;

    my $posts = $self->ua->post(Mojo::URL->new($self->base_url)->query(infinity => 'scrolling') => form => { 
        'action' => "infinite_scroll",
        'page' => "1",
        'order' => "DESC",
        'query_args[year]' => $yy,
        'query_args[monthnum]' => $mm,
        'query_args[posts_per_page]' => 50,
        'query_args[order]' => "DESC",
    });
    my @articles = ();
    for my $article (Mojo::DOM->new($posts->res->json->{html})->find('article')->each) {
        my $title = $article->find('.entry-title > a:nth-child(1)')->first;
        my @tags  = $article->find('span.tag-links > a')->each;
        push @articles, Fabulous::Article->new(
            title => $title->text, 
            href  => $title->{href}, 
            tags  => \@tags,
        );
    }
    return @articles;
}

1;
```

Main program is then just getting all available months, getting articles of them and output markdown as before

```perl
use lib 'lib';
use utf8::all;
use Fabulous;

my $fabulous = Fabulous->new(base_url => 'https://ericlippert.com');

for my $month ($fabulous->get_all_months()) {
    warn "Fetching ", $month->text, "\n";
    print "\n## [", $month->text, "](", $month->{href}, ")\n";
    for my $article ($fabulous->get_articles_for_month($month)) {
        print " - [ ] [", $article->title, "](", $article->href, ")\n";
    }
}
```

Running it added some more articles into my list.

[1]: https://ericlippert.com/
[2]: https://docs.mojolicious.org/Mojo/UserAgent
[3]: https://docs.mojolicious.org/Mojo::URL
[4]: https://docs.mojolicious.org/Mojo::DOM
