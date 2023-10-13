---
layout: post
title: Encode/decode url
published: yes
tags:
  - perl
  - Mojo::URL
  - Web
  - Mojolicious
---
Very short post - I recently needed to build an url with weird character `#` in authentication string. It was clear that the character needed to be somehow encoded. There is for sure many convertors on the net, but I reached for utility class from [Mojolicious][1] framework, the [Mojo::URL][2]. Following script would do

```perl
use Mojo::URL;

my $url = Mojo::URL->new('https://bitbucket/scm/repo/requirements.git')
            ->userinfo('account:pwd34#')
            ->query(a => 'b');
for my $method (qw(to_string to_unsafe_string scheme userinfo host port path query fragment)) {
    printf "%-20s: %s\n", $method, $url->$method();
}
```

I basically needed only the `to_unsafe_string` method to build the final url. The `to_string` omits user info from the url, so it is not usable here. As I played a bit more with this, I made it complete decomposition using all methods. The output is as follows

```
to_string           : https://bitbucket/scm/repo/requirements.git?a=b
to_unsafe_string    : https://account:pwd34%23@bitbucket/scm/repo/requirements.git?a=b
scheme              : https
userinfo            : account:pwd34#
host                : bitbucket
port                :
path                : /scm/repo/requirements.git
query               : a=b
fragment            :
```

Another useful operation supported by the class is to build relative url to some base, as demonstrated in [Scrape infinity]({% post_url 2023-03-11-scrape-infinity %}) post.

[1]: https://mojolicious.io/
[2]: https://docs.mojolicious.org/Mojo/URL
