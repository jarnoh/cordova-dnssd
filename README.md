cordova-dnssd
-------------

Cordova plugin for running DNS-SD browsing and resolving on iOS devices.

Instructions
------------

Add *.h, *.m to Plugins/ directory and *.js to www/ directory.  

Add key to Cordova.plist:
 * fi.peekpoke.cordova.dnssd = CDVBonjour


Example
-------
There is a <a href="example/">simple DAAP browsing example</a> available,
it should list shared iTunes DAAP services and by tapping item, resolve the
actual IP address.


Legal
-----

**cordova-dnssd** is licensed with Apache License v2.0.
(same as Cordova, for license see http://www.apache.org/licenses/LICENSE-2.0)

Copyright (c) 2012-2013 Jarno Heikkinen <jarnoh@komplex.org>.

