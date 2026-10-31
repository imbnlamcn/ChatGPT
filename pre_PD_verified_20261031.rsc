# 2026-10-31 11:57:59 by RouterOS 7.25
# software id = Y15Q-D0X4
#
# model = RB750Gr3
# serial number = 6F3906C09C6A
/interface list
add name=WAN
add name=LAN
/ip neighbor discovery-settings
set discover-interface-list=LAN
/ip settings
set ipv4-multipath-hash-policy=l4 secure-redirects=no send-redirects=no \
    tcp-timestamps=enabled
/ipv6 settings
set accept-redirects=no accept-router-advertisements-on=WAN \
    multipath-hash-policy=l4
/ip cloud
set update-time=no
/ip dhcp-server network
add address=192.168.88.0/24 dns-server=192.168.88.1 gateway=192.168.88.1
/ip pool
add name=POOL_LAN ranges=192.168.88.10-192.168.88.200
/ip service
set ftp disabled=yes
set ssh disabled=yes
set telnet disabled=yes
set www disabled=yes
set reverse-proxy disabled=yes
set winbox available-from=192.168.88.0/24
set api disabled=yes
set api-ssl disabled=yes
/interface bridge
add comment="LAN bridge" name=bridge_LAN
/interface list member
add interface=ether1 list=WAN
add interface=ether2 list=WAN
add interface=ether3 list=WAN
add interface=bridge_LAN list=LAN
/ip address
add address=192.168.88.1/24 comment="LAN management" interface=bridge_LAN \
    network=192.168.88.0
/ip dhcp-server
add address-pool=POOL_LAN interface=bridge_LAN lease-time=12h name=DHCP_LAN
/ip dns
set allow-remote-requests=yes servers=1.1.1.1,8.8.8.8
/ipv6 address
add address=fd7c:3a91:6d20:1::1 comment=LAN_ULA_NAT66 interface=bridge_LAN
/ipv6 nd
set [ find default=yes ] advertise-dns=yes dns=\
    2001:4860:4860::8888,2606:4700:4700::1111 interface=bridge_LAN ra-delay=\
    1s ra-interval=20s-1m
/routing table
add fib name=to_WAN1
add fib name=to_WAN2
add fib name=to_WAN3
/ip dhcp-client
add add-default-route=no comment="WAN1 DHCP from ZTE" interface=ether1 name=\
    client1 use-peer-dns=no use-peer-ntp=no
add add-default-route=no comment="WAN2 DHCP from ZTE" interface=ether2 name=\
    client2 use-peer-dns=no use-peer-ntp=no
add add-default-route=no comment="WAN3 DHCP from ZTE" interface=ether3 name=\
    client3 use-peer-dns=no use-peer-ntp=no
/ip firewall filter
add action=accept chain=input comment="IN established related untracked" \
    connection-state=established,related,untracked
add action=drop chain=input comment="IN drop invalid" connection-state=\
    invalid
add action=accept chain=input comment="IN DHCP client replies" dst-port=68 \
    in-interface-list=WAN protocol=udp src-port=67
add action=accept chain=input comment="IN allow LAN management" \
    in-interface-list=LAN
add action=drop chain=input comment="IN block WAN" in-interface-list=WAN
add action=drop chain=input comment="IN drop other"
add action=accept chain=forward comment="FWD established related untracked" \
    connection-state=established,related,untracked
add action=drop chain=forward comment="FWD drop invalid" connection-state=\
    invalid
add action=accept chain=forward comment="FWD LAN to WAN" in-interface-list=\
    LAN out-interface-list=WAN
add action=drop chain=forward comment="FWD drop unsolicited WAN" \
    in-interface-list=WAN
add action=drop chain=forward comment="FWD drop other"
/ip firewall mangle
add action=accept chain=prerouting comment=PCC_BYPASS_LAN dst-address=\
    192.168.88.0/24 in-interface=bridge_LAN
add action=accept chain=prerouting comment=PCC_BYPASS_ZTE dst-address=\
    192.168.1.0/24 in-interface=bridge_LAN
add action=mark-connection chain=prerouting comment=PCC_WAN1 connection-mark=\
    no-mark connection-state=new dst-address-type=unicast in-interface=\
    bridge_LAN new-connection-mark=WAN1_conn per-connection-classifier=\
    both-addresses-and-ports:3/0
add action=mark-connection chain=prerouting comment=PCC_WAN2 connection-mark=\
    no-mark connection-state=new dst-address-type=unicast in-interface=\
    bridge_LAN new-connection-mark=WAN2_conn per-connection-classifier=\
    both-addresses-and-ports:3/1
add action=mark-connection chain=prerouting comment=PCC_WAN3 connection-mark=\
    no-mark connection-state=new dst-address-type=unicast in-interface=\
    bridge_LAN new-connection-mark=WAN3_conn per-connection-classifier=\
    both-addresses-and-ports:3/2
add action=mark-routing chain=prerouting comment=PCC_ROUTE_MARK_WAN1 \
    connection-mark=WAN1_conn in-interface=bridge_LAN new-routing-mark=\
    to_WAN1 passthrough=no
add action=mark-routing chain=prerouting comment=PCC_ROUTE_MARK_WAN2 \
    connection-mark=WAN2_conn in-interface=bridge_LAN new-routing-mark=\
    to_WAN2 passthrough=no
add action=mark-routing chain=prerouting comment=PCC_ROUTE_MARK_WAN3 \
    connection-mark=WAN3_conn in-interface=bridge_LAN new-routing-mark=\
    to_WAN3 passthrough=no
/ip firewall nat
add action=masquerade chain=srcnat comment=NAT_LAN_TO_WAN out-interface-list=\
    WAN
/ip route
add comment=PROBE_WAN1_MAIN dst-address=1.1.1.1/32 gateway=192.168.1.1%ether1 \
    routing-table=main scope=10 target-scope=10
add comment=PROBE_WAN2_MAIN dst-address=8.8.8.8/32 gateway=192.168.1.1%ether2 \
    routing-table=main scope=10 target-scope=10
add comment=PROBE_WAN3_MAIN dst-address=9.9.9.9/32 gateway=192.168.1.1%ether3 \
    routing-table=main scope=10 target-scope=10
add comment=PROBE_WAN1_T1 dst-address=1.1.1.1/32 gateway=192.168.1.1%ether1 \
    routing-table=to_WAN1 scope=10 target-scope=10
add comment=PROBE_WAN2_T1 dst-address=8.8.8.8/32 gateway=192.168.1.1%ether2 \
    routing-table=to_WAN1 scope=10 target-scope=10
add comment=PROBE_WAN3_T1 dst-address=9.9.9.9/32 gateway=192.168.1.1%ether3 \
    routing-table=to_WAN1 scope=10 target-scope=10
add comment=PROBE_WAN1_T2 dst-address=1.1.1.1/32 gateway=192.168.1.1%ether1 \
    routing-table=to_WAN2 scope=10 target-scope=10
add comment=PROBE_WAN2_T2 dst-address=8.8.8.8/32 gateway=192.168.1.1%ether2 \
    routing-table=to_WAN2 scope=10 target-scope=10
add comment=PROBE_WAN3_T2 dst-address=9.9.9.9/32 gateway=192.168.1.1%ether3 \
    routing-table=to_WAN2 scope=10 target-scope=10
add comment=PROBE_WAN1_T3 dst-address=1.1.1.1/32 gateway=192.168.1.1%ether1 \
    routing-table=to_WAN3 scope=10 target-scope=10
add comment=PROBE_WAN2_T3 dst-address=8.8.8.8/32 gateway=192.168.1.1%ether2 \
    routing-table=to_WAN3 scope=10 target-scope=10
add comment=PROBE_WAN3_T3 dst-address=9.9.9.9/32 gateway=192.168.1.1%ether3 \
    routing-table=to_WAN3 scope=10 target-scope=10
add check-gateway=ping comment=DEF_WAN1_MAIN distance=1 dst-address=0.0.0.0/0 \
    gateway=1.1.1.1 routing-table=main scope=30 target-scope=11
add check-gateway=ping comment=REC_MAIN_WAN2 distance=3 dst-address=0.0.0.0/0 \
    gateway=8.8.8.8 routing-table=main scope=30 target-scope=11
add check-gateway=ping comment=REC_MAIN_WAN3 distance=4 dst-address=0.0.0.0/0 \
    gateway=9.9.9.9 routing-table=main scope=30 target-scope=11
add check-gateway=ping comment=PCC_ROUTE_WAN1 disabled=no distance=1 \
    dst-address=0.0.0.0/0 gateway=1.1.1.1 routing-table=to_WAN1 scope=30 \
    target-scope=11
add check-gateway=ping comment=FAILOVER_WAN2_T1 distance=2 dst-address=\
    0.0.0.0/0 gateway=8.8.8.8 routing-table=to_WAN1 scope=30 target-scope=11
add check-gateway=ping comment=FAILOVER_WAN3_T1 distance=3 dst-address=\
    0.0.0.0/0 gateway=9.9.9.9 routing-table=to_WAN1 scope=30 target-scope=11
add check-gateway=ping comment=PCC_ROUTE_WAN2 distance=1 dst-address=\
    0.0.0.0/0 gateway=8.8.8.8 routing-table=to_WAN2 scope=30 target-scope=11
add check-gateway=ping comment=FAILOVER_WAN1_T2 distance=2 dst-address=\
    0.0.0.0/0 gateway=1.1.1.1 routing-table=to_WAN2 scope=30 target-scope=11
add check-gateway=ping comment=FAILOVER_WAN3_T2 distance=3 dst-address=\
    0.0.0.0/0 gateway=9.9.9.9 routing-table=to_WAN2 scope=30 target-scope=11
add check-gateway=ping comment=PCC_ROUTE_WAN3 distance=1 dst-address=\
    0.0.0.0/0 gateway=9.9.9.9 routing-table=to_WAN3 scope=30 target-scope=11
add check-gateway=ping comment=FAILOVER_WAN1_T3 distance=2 dst-address=\
    0.0.0.0/0 gateway=1.1.1.1 routing-table=to_WAN3 scope=30 target-scope=11
add check-gateway=ping comment=FAILOVER_WAN2_T3 distance=3 dst-address=\
    0.0.0.0/0 gateway=8.8.8.8 routing-table=to_WAN3 scope=30 target-scope=11
/ipv6 route
add comment=V6_PROBE_WAN1_MAIN dst-address=2606:4700:4700::1111/128 gateway=\
    fe80::1%ether1 routing-table=main scope=10 target-scope=10
add comment=V6_PROBE_WAN2_MAIN dst-address=2001:4860:4860::8888/128 gateway=\
    fe80::1%ether2 routing-table=main scope=10 target-scope=10
add comment=V6_PROBE_WAN3_MAIN dst-address=2620:fe::fe/128 gateway=\
    fe80::1%ether3 routing-table=main scope=10 target-scope=10
add comment=V6_PROBE_WAN1_T1 dst-address=2606:4700:4700::1111/128 gateway=\
    fe80::1%ether1 routing-table=to_WAN1 scope=10 target-scope=10
add comment=V6_PROBE_WAN2_T1 dst-address=2001:4860:4860::8888/128 gateway=\
    fe80::1%ether2 routing-table=to_WAN1 scope=10 target-scope=10
add comment=V6_PROBE_WAN3_T1 dst-address=2620:fe::fe/128 gateway=\
    fe80::1%ether3 routing-table=to_WAN1 scope=10 target-scope=10
add comment=V6_PROBE_WAN1_T2 dst-address=2606:4700:4700::1111/128 gateway=\
    fe80::1%ether1 routing-table=to_WAN2 scope=10 target-scope=10
add comment=V6_PROBE_WAN2_T2 dst-address=2001:4860:4860::8888/128 gateway=\
    fe80::1%ether2 routing-table=to_WAN2 scope=10 target-scope=10
add comment=V6_PROBE_WAN3_T2 dst-address=2620:fe::fe/128 gateway=\
    fe80::1%ether3 routing-table=to_WAN2 scope=10 target-scope=10
add comment=V6_PROBE_WAN1_T3 dst-address=2606:4700:4700::1111/128 gateway=\
    fe80::1%ether1 routing-table=to_WAN3 scope=10 target-scope=10
add comment=V6_PROBE_WAN2_T3 dst-address=2001:4860:4860::8888/128 gateway=\
    fe80::1%ether2 routing-table=to_WAN3 scope=10 target-scope=10
add comment=V6_PROBE_WAN3_T3 dst-address=2620:fe::fe/128 gateway=\
    fe80::1%ether3 routing-table=to_WAN3 scope=10 target-scope=10
add check-gateway=ping comment=V6_DEF_WAN1_MAIN distance=1 dst-address=::/0 \
    gateway=2606:4700:4700::1111 routing-table=main scope=30 target-scope=11
add check-gateway=ping comment=V6_REC_MAIN_WAN2 distance=3 dst-address=::/0 \
    gateway=2001:4860:4860::8888 routing-table=main scope=30 target-scope=11
add check-gateway=ping comment=V6_REC_MAIN_WAN3 distance=4 dst-address=::/0 \
    gateway=2620:fe::fe routing-table=main scope=30 target-scope=11
add check-gateway=ping comment=V6_PCC_ROUTE_WAN1 disabled=no distance=1 \
    dst-address=::/0 gateway=2606:4700:4700::1111 routing-table=to_WAN1 \
    scope=30 target-scope=11
add check-gateway=ping comment=V6_FAILOVER_WAN2_T1 distance=2 dst-address=\
    ::/0 gateway=2001:4860:4860::8888 routing-table=to_WAN1 scope=30 \
    target-scope=11
add check-gateway=ping comment=V6_FAILOVER_WAN3_T1 distance=3 dst-address=\
    ::/0 gateway=2620:fe::fe routing-table=to_WAN1 scope=30 target-scope=11
add check-gateway=ping comment=V6_PCC_ROUTE_WAN2 distance=1 dst-address=::/0 \
    gateway=2001:4860:4860::8888 routing-table=to_WAN2 scope=30 target-scope=\
    11
add check-gateway=ping comment=V6_FAILOVER_WAN1_T2 distance=2 dst-address=\
    ::/0 gateway=2606:4700:4700::1111 routing-table=to_WAN2 scope=30 \
    target-scope=11
add check-gateway=ping comment=V6_FAILOVER_WAN3_T2 distance=3 dst-address=\
    ::/0 gateway=2620:fe::fe routing-table=to_WAN2 scope=30 target-scope=11
add check-gateway=ping comment=V6_PCC_ROUTE_WAN3 distance=1 dst-address=::/0 \
    gateway=2620:fe::fe routing-table=to_WAN3 scope=30 target-scope=11
add check-gateway=ping comment=V6_FAILOVER_WAN1_T3 distance=2 dst-address=\
    ::/0 gateway=2606:4700:4700::1111 routing-table=to_WAN3 scope=30 \
    target-scope=11
add check-gateway=ping comment=V6_FAILOVER_WAN2_T3 distance=3 dst-address=\
    ::/0 gateway=2001:4860:4860::8888 routing-table=to_WAN3 scope=30 \
    target-scope=11
/ipv6 dhcp-client
add comment=V6_ADDR_WAN1 interface=ether1 request=address use-interface-duid=\
    yes use-peer-dns=no
add comment=V6_ADDR_WAN2 interface=ether2 request=address use-interface-duid=\
    yes use-peer-dns=no
add comment=V6_ADDR_WAN3 interface=ether3 request=address use-interface-duid=\
    yes use-peer-dns=no
/ipv6 firewall filter
add action=accept chain=input comment="V6-IN established related untracked" \
    connection-state=established,related,untracked
add action=drop chain=input comment="V6-IN drop invalid" connection-state=\
    invalid
add action=accept chain=input comment="V6-IN allow ICMPv6" protocol=icmpv6
add action=accept chain=input comment="V6-IN DHCPv6 client replies" dst-port=\
    546 in-interface-list=WAN protocol=udp src-address=fe80::/10
add action=accept chain=input comment="V6-IN allow LAN management" \
    in-interface-list=LAN
add action=drop chain=input comment="V6-IN drop WAN" in-interface-list=WAN
add action=drop chain=input comment="V6-IN drop other"
add action=accept chain=forward comment=\
    "V6-FWD established related untracked" connection-state=\
    established,related,untracked
add action=drop chain=forward comment="V6-FWD drop invalid" connection-state=\
    invalid
add action=accept chain=forward comment=\
    "V6-FWD ICMPv6 destination unreachable" icmp-options=1:0-7 protocol=\
    icmpv6
add action=accept chain=forward comment=\
    "V6-FWD ICMPv6 packet too big (PMTUD)" icmp-options=2:0 protocol=icmpv6
add action=accept chain=forward comment="V6-FWD ICMPv6 time exceeded" \
    icmp-options=3:0-1 protocol=icmpv6
add action=accept chain=forward comment="V6-FWD ICMPv6 parameter problem" \
    icmp-options=4:0-2 protocol=icmpv6
add action=accept chain=forward comment="V6-FWD allow LAN-originated ICMPv6" \
    in-interface-list=LAN protocol=icmpv6
add action=accept chain=forward comment="V6-FWD LAN to WAN" \
    in-interface-list=LAN out-interface-list=WAN
add action=drop chain=forward comment="V6-FWD drop unsolicited WAN" \
    in-interface-list=WAN
add action=drop chain=forward comment="V6-FWD drop other"
/ipv6 firewall mangle
add action=accept chain=prerouting comment=V6_PCC_BYPASS_ROUTER_LOCAL \
    dst-address-type=local in-interface=bridge_LAN
add action=accept chain=prerouting comment=V6_PCC_BYPASS_LAN dst-address=\
    fd7c:3a91:6d20:1::/64 in-interface=bridge_LAN
add action=accept chain=prerouting comment=V6_PCC_BYPASS_LINKLOCAL \
    dst-address=fe80::/10 in-interface=bridge_LAN
add action=mark-connection chain=prerouting comment=V6_PCC_WAN1 \
    connection-mark=no-mark connection-state=new dst-address-type=unicast \
    in-interface=bridge_LAN new-connection-mark=V6_WAN1_conn \
    per-connection-classifier=both-addresses-and-ports:3/0
add action=mark-connection chain=prerouting comment=V6_PCC_WAN2 \
    connection-mark=no-mark connection-state=new dst-address-type=unicast \
    in-interface=bridge_LAN new-connection-mark=V6_WAN2_conn \
    per-connection-classifier=both-addresses-and-ports:3/1
add action=mark-connection chain=prerouting comment=V6_PCC_WAN3 \
    connection-mark=no-mark connection-state=new dst-address-type=unicast \
    in-interface=bridge_LAN new-connection-mark=V6_WAN3_conn \
    per-connection-classifier=both-addresses-and-ports:3/2
add action=mark-routing chain=prerouting comment=V6_PCC_ROUTE_MARK_WAN1 \
    connection-mark=V6_WAN1_conn in-interface=bridge_LAN new-routing-mark=\
    to_WAN1 passthrough=no
add action=mark-routing chain=prerouting comment=V6_PCC_ROUTE_MARK_WAN2 \
    connection-mark=V6_WAN2_conn in-interface=bridge_LAN new-routing-mark=\
    to_WAN2 passthrough=no
add action=mark-routing chain=prerouting comment=V6_PCC_ROUTE_MARK_WAN3 \
    connection-mark=V6_WAN3_conn in-interface=bridge_LAN new-routing-mark=\
    to_WAN3 passthrough=no
/ipv6 firewall nat
add action=masquerade chain=srcnat comment=NAT66_ULA_LAN_to_WAN \
    out-interface-list=WAN src-address=fd7c:3a91:6d20:1::/64
/system clock
set time-zone-name=Asia/Bangkok
/system identity
set name=hEX-3WAN-DualStack
/system ntp client
set enabled=yes
/system ntp client servers
add address=time.cloudflare.com
add address=time.google.com
/tool bandwidth-server
set enabled=no
/tool mac-server
set allowed-interface-list=LAN
/tool mac-server mac-winbox
set allowed-interface-list=LAN
/interface bridge port
add bridge=bridge_LAN interface=ether4
add bridge=bridge_LAN interface=ether5
