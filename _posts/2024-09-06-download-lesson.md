---
layout: post  
title: Download Japanese Podcast  
published: yes  
tags:
  - perl
  - podcast
  - Mojo::UserAgent
  - Mojolicious
  - japanese
---
I was looking for some podcasts to improve my Japanese language learning. Based on recommendations from [Reddit][1], I found the [Nihongo Con Teppei][2] podcast. The idea is to listen to a native Japanese speaker discuss various topics, which helps in getting a feel for the language and eventually understanding it.

Since I often learn offline, I wanted to download the podcast episodes in `.mp3` format. Note that the pages are currently static, as the author has moved to Spotify for delivering newer episodes. Therefore, I don't need to worry too much about future changes. Upon analyzing the [web page][2], I noticed there are numbered `index.html` pages like:

- `index-70.html` - first batch of episodes
- `index-69.html` - second batch
- and so on

Each page contains `article` entries with links to a generic download page is lower part of the entry. The link includes a parameter `u` that points to the `.mp3` file that we want to download: 

```html
<article class="entry">
    <h2 class="entry__title">
        <a href="http://teppeisensei.com/article/458763341.html">#49友達について</a>
    </h2>
    <div class="meta">
        <div class="date">
            <span class="icn icn--calendar"></span><time datetime="2018年04月13日">2018年04月13日</time>
        </div>
    </div>
    <div class="article article--entry">
        <div class="audio-link">
            <audio style="max-width: 100%" controls="controls">
                このブラウザでは再生できません。
                <source src="https://blog.seesaa.jp/pages/tools/download/play?d=e7ba055eebd78bb90650b70a0679c452&u=https://teppeisensei.up.seesaa.net/image/Nihongo20con20Teppei2349.mp3">
            </audio>
            <br>
            再生できない場合、ダウンロードは&#x1F3B5;
            <a href="https://blog.seesaa.jp/pages/tools/download/index?d=e7ba055eebd78bb90650b70a0679c452&u=https://teppeisensei.up.seesaa.net/image/Nihongo20con20Teppei2349.mp3">
                こちら
            </a>
    </div>
    <a name="more"></a>
</article>
```

Using this, it’s relatively straightforward to build a simple script based on the [Mojolicious][3] framework and its web client, [Mojo::UserAgent][4].

```perl
use 5.16.3;
use Mojo::UserAgent;

my $ua  = Mojo::UserAgent->new;
my $page = 'http://teppeisensei.com/index-66.html';

my $dom = $ua->get($page)->result->dom;
my @download_urls = $dom->find('a')
    # find links with href attributes pointing to .mp3 files
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

Here are a few notes on the script above:

- [Mojolicious][3] provides well-structured objects, making it easy to manipulate data. For example, to obtain the `@download_urls` variable, you can turn the user agent result into a DOM parser, find all links using [Mojo::Collection][5], filter URLs containing `.mp3`, and extract the `u` parameter as a [Mojo::URL][6] object.
- The download section extracts the filename from the URL, fetches the `.mp3` file, and saves it locally. 

I can highly recommend the podcast and this quick script allowed me to enjoy it offline.

[1]: https://www.reddit.com/r/LearnJapanese/comments/119lzps/300_episodes_of_nihongo_con_teppei_z_700_episodes/  
[2]: http://teppeisensei.com/  
[3]: https://mojolicious.io/  
[4]: https://docs.mojolicious.org/Mojo/UserAgent  
[5]: https://docs.mojolicious.org/Mojo/Collection  
[6]: https://docs.mojolicious.org/Mojo/URL  
