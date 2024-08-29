---
layout: post
title: Encode special chars in URL
published: yes  
tags:
  - perl
  - Mojo::URL
  - Web
  - Mojolicious
---
I recently needed to build an URL with the weird character # in an authentication string. It was clear that the character needed to be properly encoded. There are for sure many online convertors, but I reached for a utility class from the [Mojolicious][1] framework, called [Mojo::URL][2]. The following script demonstrates how to handle this:

```perl
use Mojo::URL;

my $url = Mojo::URL->new('https://bitbucket/scm/repo/requirements.git')
            ->userinfo('account:pwd34#')
            ->query(a => 'b');
for my $method (qw(to_string to_unsafe_string scheme userinfo host port path query fragment)) {
    printf "%-20s: %s\n", $method, $url->$method();
}
```

In this case, I primarily needed the `to_unsafe_string` method to build the final URL. The `to_string` method omits the user info from the URL, so it wasn't usable here. As I explored further, I tried all available methods to completely decompose the URL, resulting in the following output:

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

Another handy feature provided by this class is the ability to build a relative URL based on a given base URL, as I discussed in the [Scrape Infinity]({% post_url 2023-03-11-scrape-infinity %}) post.

[1]: https://mojolicious.io/
[2]: https://docs.mojolicious.org/Mojo/URL
