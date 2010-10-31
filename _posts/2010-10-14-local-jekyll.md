---
layout: post
title:  Local jekyll
perex: >
    Since I started using jekyll for this site, I wanted to have local instance
    of it installed on my Windows machine for testing. Finally I made it working,
    here are steps I did.
category: jekyll
tags: 
    - jekyll
    - ruby
    - python
    - install
---

### Install ruby

 - download [ruby 1.9.2 installer for Windows](http://rubyforge.org/frs/download.php/72170/rubyinstaller-1.9.2-p0.exe) and install it
 - download [DevKit-4.5.0](http://github.com/downloads/oneclick/rubyinstaller/DevKit-4.5.0-20100819-1536-sfx.exe) and install it
 - install [jekyll](http://jekyllrb.com/) with  
   `gem install jekyll`

### Install python

 - download [python 2.7](http://python.org/ftp/python/2.7/python-2.7.msi) and install it
 - download [setuptools for python 2.7](http://pypi.python.org/packages/2.7/s/setuptools/setuptools-0.6c11.win32-py2.7.exe#md5=57e1e64f6b7c7f1d2eddfc9746bbaf20) and install it
 - install [pygments](http://pygments.org/) with  
    `easy_install Pygments`
 - add `C:\Python27\Scripts` to the `PATH` variable

### Test it

 - go into your site directory and run `jekyll --server --auto`
 - point browser at [localhost:4000](http://localhost:4000) and check the site is working
