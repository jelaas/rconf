#!/bin/bash

cp -pf configure /usr/bin/configure
mkdir /usr/libexec/rconf
for f in librconf.sh rconf-control rconf-control-interface rconf-control-interface-qdisc rconf-control-interface-qdisc-default rconf-control-interface-qdisc-ratelimit rconf-control-interface-qdisc-sfq rconf-control-routes rconf-control-routes-ipv4 rconf-drivers rconf-hostname rconf-interfaces rconf-interfaces-phys rconf-interfaces-script rconf-interfaces-virtual rconf-interfaces-virtual-bridge rconf-interfaces-virtual-dummy rconf-interfaces-virtual-gre rconf-interfaces-virtual-vlan rconf-interfaces-virtual-vrouter rconf-proto rconf-proto-dns rconf-proto-global rconf-proto-global-ipv4 rconf-proto-global-ipv6 rconf-proto-interface rconf-proto-interface-ipv4 rconf-proto-interface-ipv6 rconf-services rconf-services-core rconf-services-optional; do
    cp -pf rconf/$f /usr/libexec/rconf
done

for f in rc.ifcontrol-qdisc  rc.if-phys-phys  rc.ifproto-ipv4; do
    cp -pf rc.d/$f /etc/rc.d
done
