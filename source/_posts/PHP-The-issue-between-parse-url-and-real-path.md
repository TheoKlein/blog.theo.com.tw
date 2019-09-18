---
title: 'PHP: The issue between parse_url and real file path'
metaAlignment: center
coverMeta: out
thumbnailImagePosition: left
date: 2019-08-28 13:58:58
categories:
    - Research
thumbnailImage: cover.png
keywords:
    - PHP
    - parse_url
    - vulnerability
    - LFR
tags:
    - PHP
    - LFI
---
Use `parse_url($url)` to check `$url`'s scheme and pass `$url` to `file_get_contents()` will lead to LFR issue.
<!-- more --><!-- toc -->

## The story
Below is a snippet modified from [DEVCORE](https://devco.re) Wargame at HITCON CMT 2019:
```php
<?php
    $url = "http://localhost/";
    $parsed_url = parse_url($url);
    if ($parsed_url['scheme'] === 'http' || $parsed_url['scheme'] === 'https') {
        die(file_get_contents($url));
    }
?>
```

In the original challenge, it's a simple proxy service in blackbox. `$url` is get from `$_POST['url']`, only allow HTTP or HTTPS protocal by using `parse_url()` to check `$url`.

It's a classical SSRF challenge until we need to read the local file with only HTTP/HTTPS. The exploit is something like this:
```php
<?php
    $url = "http:\\localhost/../../../../../etc/passwd";
    $parsed_url = parse_url($url);
    if ($parsed_url['scheme'] === 'http' || $parsed_url['scheme'] === 'https') {
        die(file_get_contents($url));
    }
?>
```

Wait, what? `http:` with double backslashes `\\` ? How can this malformed url pass the `parse_url()` scheme check and lead to local file read problem?

## Interesting about parse_url()
Here is a normal url pass to `parse_url()`
```php
var_dump(parse_url("http://localhost/../../../../../etc/passwd"));
```

```php
array(3) {
  ["scheme"]=>
  string(4) "http"
  ["host"]=>
  string(9) "localhost"
  ["path"]=>
  string(26) "/../../../../../etc/passwd"
}
```
The scheme, host and path are all parsed correctly. How about malformed url with double backslashes?

```php
var_dump(parse_url("http:\\localhost/../../../../../etc/passwd"));
```

```php
array(2) {
  ["scheme"]=>
  string(4) "http"
  ["path"]=>
  string(36) "\localhost/../../../../../etc/passwd"
}
```
As you can see, scheme is still parsed as `http` but no host value parsed, the remaining string are all parsed as path.

Here comes a problem, `parse_url()` is successed without any error even warning, but apparently the parsed result is not what we expected. So it pass the sheme check and move on to `file_get_content()` function.

## Dig into PHP source code
Out of curiosity, I decided to dig into PHP's C source code to see how `file_get_contents()` work with this path `http:\\localhost/../../../../../etc/passwd`.

My environment is Ubuntu Desktop 18.04 with self-compiled PHP 7.3.8 for gdb debug.
```sh
$ git clone http://git.php.net/repository/php-src.git
$ cd php-src
$ git checkout php-7.3.8
$ ./buildconf

# In order to debug PHP source code
# --enable-debug must toggled
# --prefix modify to your custom install location
$ ./configure --disable-all --enable-debug --prefix=/home/theo/Desktop/php-7.3.8
$ make
$ make install
```

Test code: 
```php
<?php
    $url = "http:\\localhost/../../../../../etc/passwd";
    $parsed_url = parse_url($url);
    if ($parsed_url['scheme'] === 'http' || $parsed_url['scheme'] === 'https') {
        die(file_get_contents($url));
    }
?>
```

The problem is located at `Zend/zend_cirtual_ced.c tsrm_realpath_r()`. This is a recursive function that traversing the entire path string to see if it's containing `/.` or `/..` at the end and remove them. For example our malicious path `http:\\localhost/../../../../../etc/passwd` will expand to `/home/theo/Desktop/http:\\localhost/../../../../../etc/passwd` according to your php-cli's current working path before pass into `tsrm_realpath_r()`.

Snippet of `tsrm_realpath_r()`:
```c
...
    if (i == len ||
    	(i + 1 == len && path[i] == '.')) {
    	/* remove double slashes and '.' */
    	len = EXPECTED(i > 0) ? i - 1 : 0;
    	is_dir = 1;
    	continue;
    } else if (i + 2 == len && path[i] == '.' && path[i+1] == '.') {
    	/* remove '..' and previous directory */
    	is_dir = 1;
    	if (link_is_dir) {
    		*link_is_dir = 1;
    	}
    	if (i <= start + 1) {
    		return start ? start : len;
    	}
    	j = tsrm_realpath_r(path, start, i-1, ll, t, use_realpath, 1, NULL);
...
```

Because it only look for `/.` and `/..`, it will threat `http:\\localhost` as an unnecessary leading directory as well as `Desktop` , `theo`, and so on. Then remove these unnecessary leading directory  according to how many `/..` we have in path string. In this case we will get `/etc/passwd` as our final file real path, lead to a Local-File Read vulnerability.