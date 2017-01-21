---
layout: post
title:  Local jekyll
tags:
    - jekyll
    - ruby
    - python
    - install
---
''Update:'' I walked through list below for another installation on my new 
laptop, so bunch of versions had been updated. 

Since I started using jekyll for this site, I wanted to have local instance
of it installed on my Windows machine for testing. Finally I made it working,
here are steps I did.

### ruby part

This part is necessary to run [jekyll](http://jekyllrb.com/).  For the most part
I just followed steps [described here](http://jekyll-windows.juthilo.com/):

 - download [Ruby 2.0.0-p634 (x64)](http://dl.bintray.com/oneclick/rubyinstaller/rubyinstaller-2.0.0-p643-x64.exe?direct) and install it
 - download [DevKit-mingw64-64-4.7.2-20130224-1432-sfx.exe](http://cdn.rubyinstaller.org/archives/devkits/DevKit-mingw64-64-4.7.2-20130224-1432-sfx.exe) and install it:
   - by running executable extract file into a directory
   - run `ruby dk.rb init`
   - run `ruby dk.rb install`
 - install [jekyll](http://jekyllrb.com/) with  
   `gem install jekyll`
 - install [rdiscount](https://github.com/rtomayko/rdiscount/)  
   `gem install rdiscount`

To fix the certificate, this answer helped me:

http://stackoverflow.com/questions/19150017/ssl-error-when-installing-rubygems-unable-to-pull-data-from-https-rubygems-o/27298259#27298259

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

 - go into your site directory and run `jekyll serve`
 - point browser at [localhost:4000](http://localhost:4000) and check the site is working
