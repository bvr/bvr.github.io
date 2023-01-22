---
layout: post
title: Porter's stemmer
published: no
tags:
  - stemmer
  - Martin Porter
---
The [Porter Stemming Algorithm][1] tries to reduce words into their stems. For typical full-text search, each document is described by vector of words (this can come from title, abstract, text of the document, keywords, etc). Term with same stem usually have similar meaning like in:

 - connect
 - connects
 - connected
 - connecting
 - connection
 - connections

The reduction into the stem is usually done by removing of various suffixes. The Porter algorithm does it for english source.

Terminology



https://tartarus.org/martin/PorterStemmer/

[1]: https://tartarus.org/martin/PorterStemmer/def.txt