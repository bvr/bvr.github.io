---
layout: post
title: Real stemmers
published: yes
tags:
  - perl
  - Lingua::Stem::UniNE::CS
  - Snowball
  - regex
  - stemmer
---
The experimental code I created in [previous post][1] outlines approach used to create language stemmers that can be used to reduce index of full-text search on one hand and improve chance to match similar meanings on the other.

The code is rather slow and not suitable for real use. Original perl code created by Martin Porter is several times faster and if implemented in compiled language like C, the speed boost would be much more dramatic.

One popular approach used in real world is based on [Snowball language][3], also one of creations of Martin Porter. The introduction on the site has this to say:

> Snowball is a small string processing language for creating stemming algorithms for use in Information Retrieval, plus a collection of stemming algorithms implemented using it.
>
> It was originally designed and built by Martin Porter. Martin retired from development in 2014 and Snowball is now maintained as a community project. Martin originally chose the name Snowball as a tribute to SNOBOL, the excellent string handling language from the 1960s. It now also serves as a metaphor for how the project grows by gathering contributions over time.
>
> The Snowball compiler translates a Snowball program into source code in another language - currently Ada, ISO C, C#, Go, Java, Javascript, Object Pascal, Python and Rust are supported. 

There are many language stemmers implemented using this tool, then compiled into C and provided via modules to other programming languages, like perl. Here is an example using [Lingua::Stem::UniNE::CS][2] module for Czech language based on Snowball stemmer created at University of Neuchâtel. It tries to stem all words from czech annotation of **Taipan** book by James Clavell.

```perl
use v5.16;
use utf8;
use Lingua::Stem::UniNE::CS qw(stem_cs);

my $text = <<END;
Příběh první publikované části Clavellovy „asijské ságy“ se odehrává v polovině předminulého 
století, v době, kdy Velká Británie získala od Číny ostrov jménem Hongkong. Je to sice pusté a 
nehostinné místo, ale má strategickou pozici u čínských břehů a navíc jde o dokonale chráněný 
přístav. A právě tady se rozhoduje o dalším osudu obchodních a politických vztahů Británie s Čínou, 
které se točí kolem opia, čaje a stříbra. Velkou roli v nich hraje Dirk Struan, vlastník největší 
soukromé námořní flotily v Asii: bojuje se svými konkurenty o zisky z legálního i pokoutního 
obchodu, tahá za nitky i v nejvyšších kruzích a zároveň se snaží posílit dosud vratké a nejisté 
postavení vznikající hongkongské kolonie v Asii i ve vzdálené, ale mocné Anglii. Struan je jedním z 
těch, kdo nepovažují Číňany za nevzdělané barbary, ale jsou schopni ocenit a respektovat jejich 
kulturu a životní styl. V lecčem dokonce dává přednost Číně před Anglií, ale ani on si nemůže 
dovolit představit společnosti svou čínskou milenku Mej-Mej, chce-li si udržet výsadní postavení. 
Dirk Struan má syna a touží po tom, aby se Culum stal jeho nástupcem - tchaj-panem, nejvyšším 
vládcem firmy, a tím i nejbohatší a nejmocnější osobou v Hongkongu. Ale syna má i Struanův 
nejsilnější obchodní protivník a odvěký nepřítel Brock. Půjdou jejich děti ve šlépějích otců, nebo 
si najdou vlastní cestu?
END

binmode(STDOUT, ':utf8');
while($text =~ /(\w+)/gs) {
    say "$1 = " . stem_cs($1);
}
```

It produces list of words and their stems calculated. Note when `utf8` is enabled, all czech characters with accents also become word characters matched by `\w` regex pattern.

```
Příběh = příběh
první = prvn
publikované = publikovan
části = část
Clavellovy = clavell
asijské = asijsk
ságy = ság
se = se
odehrává = odehráv
v = v
polovině = polov
předminulého = předminul
století = stolet
v = v
době = dob
kdy = kdy
Velká = velk
Británie = británi
získala = získal
od = od
Číny = čín
ostrov = ostr
jménem = jmén
Hongkong = hongkong
...
```

[1]: {% post_url 2023-01-28-porter-stemmer %}
[2]: https://metacpan.org/pod/Lingua::Stem::UniNE::CS
[3]: https://snowballstem.org/
