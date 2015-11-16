# `ebrc_httpd_setup`

## Overview

Manages the EuPathDB overlay to Apache HTTPD server per the
specifications described at
https://wiki.apidb.org/index.php/UGAWebserverConfiguration

## Module Description

This module should be suitable to prepare HTTPD server to support
virtual hosts configured from a fork of
`/etc/httpd/conf/lib/ApiDB.generic.conf.template`.

It does not manage any of the Tomcat connection pieces. Only Apache
modules required to start a `ApiDB.generic` virtual host are installed. 
Other Apache modules required for a fully functional EuPathDB website
(e.g. php)  may need to be installed elsewhere.

## Setup

### What `ebrc_httpd_setup` affects

* A list of files, packages, services, or operations that the module will alter,
  impact, or execute on the system it's installed on.
* This is a great place to stick any warnings.
* Can be in list or paragraph form.

### Setup Requirements **OPTIONAL**

This module depends on 

- [puppetlabs/apache](https://forge.puppetlabs.com/puppetlabs/apache)
- [puppetforge/stdlib](https://forge.puppetlabs.com/puppetlabs/stdlib)

### Beginning with `ebrc_httpd_setup`

    include ebrc_httpd_setup

## Usage

Put the classes, types, and resources for customizing, configuring, and doing
the fancy stuff with your module here.

## Reference

## Limitations

Assumes RHEL 7 or derivatives using systemd.

## Development

Since your module is awesome, other users will want to play with it. Let them
know what the ground rules for contributing are.

## Release Notes/Contributors/Etc **Optional**

If you aren't using changelog, put your release notes here (though you should
consider using changelog). You may also add any additional sections you feel are
necessary or important to include here. Please use the `## ` header.
