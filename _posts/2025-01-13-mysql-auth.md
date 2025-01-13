---
layout: post
title: Mysql authentication
published: yes
tags:
  - mysql
  - mysql_native_password
  - caching_sha2_password
  - authentication
---
Older versions of mysql had *mysql_native_password* as the default authentication plugin, but starting with the version 8.0 the default is *caching_sha2_password*. This is not supported by some connectors. Probably best course of action is to find updated connector and use the more secure method, but if you need to fall back to old method, you need to make your users like this:

```sql
CREATE USER 'username'@'host' IDENTIFIED WITH mysql_native_password BY 'password';
```

Existing users can be modified like this:

```sql
ALTER USER 'username'@'host' IDENTIFIED WITH mysql_native_password BY 'password';
```

Note the `mysql_native_password` plugin is deprecated and will be disabled with version 9.0. You can find more rationale for the step in [this article][1].

[1]: https://blogs.oracle.com/mysql/post/mysql-90-its-time-to-abandon-the-weak-authentication-method
