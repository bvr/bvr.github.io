---
layout: post
title: Nagios NRPE SSL Fix
published: yes
tags:
  - Nagios
  - check_nrpe
  - SSL
  - NSClient++
  - NRPE
  - Agent
  - Plugin
  - Server
---
Recently I was working with my colleague on fixing our [Nagios][1] monitoring service. Corporate IT came with request to upgrade the Ubuntu installation with RedHat of newer version. And after they did the migration, parts of the service stopped working, namely the custom checks we use.

The setup was done by people that are already gone, so it required to dig into the system and learn how it works and how it is setup. This is far from complete, just notes from what we learned along the way.

## Acronyms and Abbreviations

Fortunately the Nagios has quite extensive [Knowledge base][2]. Along the learning, I picked up many of terms used in the documentation.

| Acronym | Description                                             |
| ------- | ------------------------------------------------------- |
| NRPE    | Nagios Remote Plugin Executor                           |
| Agent   | NRPE installed on remote host you want to monitor       |
| Server  | Nagios responsible to send requests to NRPE agent       |
| Plugin  | Binary program or script responsible to do actual check |

## Installation

The server part of the NRPE is located in `/usr/local/nagios/libexec`, so it is quite easy to run it and see what it does. In our case it reported following error.

```
/usr/local/nagios/libexec/check_nrpe: error while loading shared libraries: libssl.so.10: cannot open shared object file: No such file or directory
```

With help of [various forum threads][3] we were able to fix the OpenSSL problem. It required compiling both OpenSSL and [NRPE v4][5] from sources. And surely enough, we got another problem.

## SSL Connection error

```sh
$ /usr/local/nagios/libexec/check_nrpe -2 -P 8192 -H 10.156.32.137
CHECK_NRPE: (ssl_err != 5) Error - Could not complete SSL handshake with 10.156.32.137: 1
```

On the agent remote machine in the [NSClient++][4] log there was following error.

```
2025-03-12 16:16:58: error:c:\source\master\include\socket/connection.hpp:276: Failed to establish secure connection: sslv3 alert handshake failure: 1040
```

In this case the googling was longer to find functional solution, but [this one][6] eventually worked. It required just a few small modifications to adapt to our system. On the Server

```
openssl dhparam 2048
```

It took quite about half minute, but it produced following output

```
-----BEGIN DH PARAMETERS-----
MIIBCAKCAQEAvEjzXvqR2sNb3YtHpjd2yWPiKjERjHmoqMhBC47+V8KjFGi96wiV
t3+kjppfNmMEpbzVXq8fYhZT4tSmGaVvmTEdOQBw4h3bzMRf6Mn8LYw7NOOKFdgo
/ejbN2q/rKbf5RV1SOQl3eRK9t7BTw2JLISTZmxMiMlkigdpHrfrEuF67v6NX0aD
wYPH7Z+TZv1whu0t/kF/t89M0HPz9ik2asAR+uKabpNpVOIfmAd2smIYbagpgbin
sr6hsa6cy8R2LhWXcAPBp+U94oXlfcaE/6YenjJpvhpN9VkGn+650pZ3/oBqnFK3
vC7eMNYKnLBbqNQR4jrQG7uCrGKVWH0NhwIBAg==
-----END DH PARAMETERS-----
```

This needed to be placed into newly created file `c:\Program Files\NSClient++\security\nrpe_dh_2048.pem`, which needed to be referenced from `c:\Program Files\NSClient++\nsclient.ini` like this. Other settings in the section needed to be altered as well, namely the `payload length`.

```ini
[/settings/NRPE/server]
ssl options =
allow arguments = true
allow nasty characters = true
use ssl = 1
port = 5666
extended response = 1
verify mode = none
insecure = true
payload length = 8192
dh = ${certificate-path}/nrpe_dh_2048.pem
```

Once the ini file is modified, the NSClient++ service needs to be restarted. It can be done nicely from command line.

```
net stop nscp && net start nscp
```

Then the check worked nicely.

```sh
$ /usr/local/nagios/libexec/check_nrpe -2 -P 8192 -H 10.156.32.137
I (0.5.2.35 2018-01-28) seem to be doing fine...
```

Once this was working fine, only thing needed was to update the Nagios server configuration in `/usr/local/nagios/etc/objects/commands.cfg`.


[1]: https://www.nagios.com/products/nagios-xi/
[2]: https://support.nagios.com/kb/category.php?id=1
[3]: https://support.nagios.com/forum/viewtopic.php?t=53316
[4]: https://nsclient.org/
[5]: https://support.nagios.com/kb/article.php?id=515
[6]: https://hodza.net/2019/09/21/failed-to-establish-secure-connection-sslv3-alert-handshake-failure-1040/

*[NRPE]: Nagios Remote Plugin Executor