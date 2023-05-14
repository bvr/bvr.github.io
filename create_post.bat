set mydate=%date:~6,4%-%date:~3,2%-%date:~0,2%
echo _posts\%mydate%-%1.md
copy .post-template _posts\%mydate%-%1.md
code _posts\%mydate%-%1.md
