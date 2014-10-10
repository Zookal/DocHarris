#!/bin/sh
varnishd -a $LISTEN_ADDR:$LISTEN_PORT -T $TELNET_ADDR:$TELNET_PORT -s file,/var/cache/varnish/varnish.cache,$CACHE_SIZE -F
