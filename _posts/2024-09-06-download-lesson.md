---
layout: post
title: Download japanese podcast
published: yes
tags:
  - perl
  - podcast
  - Mojo::UserAgent
  - Mojolicious
  - japanese
---
I was looking for some podcasts to improve my japanese language learning. From recommendations on [Reddit][1] there was a reference to [Nihongo Con Teppei][2] podcast. The idea is to have japanese person talking all kinds of topics, listen to it and get the feeling and later also understanding of the language.

Since I am often learning offline I wanted to extract the .mp3 format of the podcast. Note the pages are currently static, as their author moved over and started using Spotify to deliver further episodes. Therefore I don't need to worry too much about changes. By the analysis of the [web page][2], there are numbered index.html pages like 

 - `index-70.html` - first episodes
 - `index-69.html` - second batch
 - etc

On each page there are links to generic download page. The link contains a parameter `u` with link to the `.mp3`. From that it is rather easy to build a simple script based on [Mojolicious][3] framework and its web client called [Mojo::UserAgent][4].

```perl
use 5.16.3;
use Mojo::UserAgent;

my $ua  = Mojo::UserAgent->new;
my $page = 'http://teppeisensei.com/index-66.html';

my $dom = $ua->get($page)->result->dom;
my @download_urls = $dom->find('a')
    # links with href and referring to .mp3
    ->grep(sub { defined $_->attr('href') && $_->attr('href') =~ /\.mp3/ })     
    ->map(sub { Mojo::URL->new($_->attr('href')) })
    ->map(sub { Mojo::URL->new($_->query->param('u')) })
    ->each;

for my $url (@download_urls) {
    my $filename = $url->path->parts->[-1];
    next if -e $filename;

    warn "$url -> $filename\n";
    my $tx = $ua->get($url);
    $tx->result->save_to($filename);
}
```

Few notes to the script above. Everything in [Mojolicious][3] returns nicely structured objects, so as you can see in obtaining the `@download_urls` variable, user agent result can be turned to DOM parser, find all links as [Mojo::Collection][5], filter out urls that contains a `.mp3`, and extract parameter `u` as [Mojo::URL][6] object.

The download part then decomposes filename from the URL, fetch the `.mp3` and save it as a file. This quick script gave me plenty of opportunity to listen to the podcast, which is really wonderful.

[1]: https://www.reddit.com/r/LearnJapanese/comments/119lzps/300_episodes_of_nihongo_con_teppei_z_700_episodes/
[2]: http://teppeisensei.com/
[3]: https://mojolicious.io/
[4]: https://docs.mojolicious.org/Mojo/UserAgent
[5]: https://docs.mojolicious.org/Mojo/Collection
[6]: https://docs.mojolicious.org/Mojo/URL
