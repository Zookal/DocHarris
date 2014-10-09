#!/bin/sh

varnishd -a $LISTEN_ADDR:$LISTEN_PORT -T $TELNET_ADDR:$TELNET_PORT -f $VCL_FILE -s file,/var/cache/varnish.cache,$CACHE_SIZE -F
