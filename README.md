cordova-dnssd
-------------

Cordova plugin for running DNS-SD browsing and resolving on iOS and OSX.

Instructions
------------

#### Cordova 3.X (command line)

`cordova plugin add https://github.com/jarnoh/cordova-dnssd.git`

#### Cordova 2.9 and earlier

Add *.h, *.m to your project and *.js to www/ directory.  

Add node to config.xml:

    <feature name="fi.peekpoke.cordova.dnssd">
        <param name="ios-package" value="CDVBonjour"/>
    </feature>


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

