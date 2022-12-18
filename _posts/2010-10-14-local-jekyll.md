---
layout: post
title:  Local jekyll
tags:
    - jekyll
    - ruby
    - python
    - install
---
**Update 2022-12-07:** Tried the steps and updated paths and versions where needed.

Since I started using jekyll for this site, I wanted to have local instance
of it installed on my Windows machine for testing. Finally I made it working,
here are steps I did.

### ruby part

This part is necessary to run [jekyll][2].  For the most part I just followed instructions on their page.

 - download [Ruby 3.1.3 (x64)][1] and install it, reboot will be probably need to get path updated everywhere
 - install [jekyll][2] with  
   `gem install jekyll bundler`

It takes some time finally it reported:

```
...
Successfully installed bundler-2.3.26
Parsing documentation for bundler-2.3.26
Installing ri documentation for bundler-2.3.26
Done installing documentation for bundler after 0 seconds
28 gems installed
```

 - install github-pages with
   `gem install github-pages`

### python part

If you don't need syntax highlighting, you can skip this part. 

 - download [python 2.7.5](http://www.python.org/download/) and install it. Use version 32/64-bit version as appropriate
 - install [setuptools](https://pypi.python.org/pypi/setuptools/1.1.6) by running downloading [ez_setup.py](https://bitbucket.org/pypa/setuptools/raw/bootstrap/ez_setup.py) and running it
 - add `C:\Python27\Scripts` to the `PATH` variable and make sure your shell gets it (reboot if you don't have an idea)
 - install [pygments](http://pygments.org/) with
    `easy_install Pygments`

I spent few hours figuring out why the combo of ruby and python does not work together. I found
number of articles pointing out to number of problems, finally I needed to downgrade from python
3.3.2 to 2.7.5, which finally made it working.

### Test it

Go into your site directory and run `jekyll serve`. It should tell something like this:

```
...
    Server address: http://127.0.0.1:4000
  Server running... press ctrl-c to stop.
```

By going to the address you can check your site.


[1]: https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-3.1.3-1/rubyinstaller-devkit-3.1.3-1-x64.exe
[2]: http://jekyllrb.com/
