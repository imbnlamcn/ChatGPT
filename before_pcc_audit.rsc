# 2026-10-27 07:22:03 by RouterOS 7.25
# software id = Y15Q-D0X4
#
# model = RB750Gr3
# serial number = 6F3906C09C6A
/interface list
add name=WAN
add name=LAN
/ipv6 settings
set accept-router-advertisements=yes accept-router-advertisements-on=WAN
/ip dhcp-server network
add address=192.168.88.0/24 dns-server=192.168.88.1 gateway=192.168.88.1
/ip pool
add name=pool_LAN ranges=192.168.88.10-192.168.88.200
/interface bridge
add comment="LAN management" mtu=1492 name=bridge_LAN
/interface list member
add interface=ether1 list=WAN
add interface=ether2 list=WAN
add interface=ether3 list=WAN
add interface=bridge_LAN list=LAN
/ip address
add address=192.168.88.1/24 comment="LAN management" interface=bridge_LAN \
    network=192.168.88.0
/ip dhcp-server
add address-pool=pool_LAN interface=bridge_LAN name=dhcp_LAN
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
add add-default-route=no comment=TEST_WAN1_DHCP interface=ether1 name=client1 \
    use-peer-dns=no
add add-default-route=no comment=TEST_WAN2_DHCP interface=ether2 name=client2 \
    use-peer-dns=no
add add-default-route=no comment=TEST_WAN3_DHCP interface=ether3 name=client3 \
    use-peer-dns=no
/ip firewall filter
add action=accept chain=input comment="INPUT established" connection-state=\
    established,related,untracked
add action=drop chain=input comment="INPUT drop invalid" connection-state=\
    invalid
add action=accept chain=input comment="Allow DHCP replies" dst-port=68 \
    in-interface-list=WAN protocol=udp src-port=67
add action=accept chain=input comment="Allow ICMP" protocol=icmp
add action=accept chain=input comment="Allow management from LAN" \
    in-interface-list=LAN
add action=drop chain=input comment="Block router access from WAN" \
    in-interface-list=WAN
add action=drop chain=input comment="Drop other router input"
add action=accept chain=forward comment="FORWARD established" \
    connection-state=established,related,untracked
add action=drop chain=forward comment="FORWARD drop invalid" \
    connection-state=invalid
add action=accept chain=forward comment="Allow LAN to WAN" in-interface-list=\
    LAN out-interface-list=WAN
add action=drop chain=forward comment="Drop other forwarding"
/ip firewall mangle
add action=accept chain=prerouting comment=PCC_BYPASS_LAN dst-address=\
    192.168.88.0/24 in-interface=bridge_LAN
add action=mark-connection chain=prerouting comment=PCC_WAN1 connection-mark=\
    no-mark connection-state=new dst-address-type=!local in-interface=\
    bridge_LAN new-connection-mark=WAN1_conn per-connection-classifier=\
    both-addresses-and-ports:3/0
add action=mark-connection chain=prerouting comment=PCC_WAN2 connection-mark=\
    no-mark connection-state=new dst-address-type=!local in-interface=\
    bridge_LAN new-connection-mark=WAN2_conn per-connection-classifier=\
    both-addresses-and-ports:3/1
add action=mark-connection chain=prerouting comment=PCC_WAN3 connection-mark=\
    no-mark connection-state=new dst-address-type=!local in-interface=\
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
add check-gateway=ping comment=DEF_WAN1_MAIN disabled=no distance=1 \
    dst-address=0.0.0.0/0 gateway=1.1.1.1 target-scope=11
add check-gateway=ping comment=PCC_ROUTE_WAN1 disabled=no distance=1 \
    dst-address=0.0.0.0/0 gateway=1.1.1.1 routing-table=to_WAN1 target-scope=\
    11
add check-gateway=ping comment=PCC_ROUTE_WAN2 disabled=no distance=1 \
    dst-address=0.0.0.0/0 gateway=8.8.8.8 routing-table=to_WAN2 target-scope=\
    11
add check-gateway=ping comment=PCC_ROUTE_WAN3 disabled=no distance=1 \
    dst-address=0.0.0.0/0 gateway=9.9.9.9 routing-table=to_WAN3 target-scope=\
    11
add comment=PROBE_WAN1 dst-address=1.1.1.1/32 gateway=192.168.1.1%ether1 \
    scope=10
add comment=PROBE_WAN2 dst-address=8.8.8.8/32 gateway=192.168.1.1%ether2 \
    scope=10
add comment=PROBE_WAN3 dst-address=9.9.9.9/32 gateway=192.168.1.1%ether3 \
    scope=10
add comment=PROBE_WAN1_T1 dst-address=1.1.1.1/32 gateway=192.168.1.1%ether1 \
    routing-table=to_WAN1 scope=10
add comment=PROBE_WAN2_T1 dst-address=8.8.8.8/32 gateway=192.168.1.1%ether2 \
    routing-table=to_WAN1 scope=10
add comment=PROBE_WAN3_T1 dst-address=9.9.9.9/32 gateway=192.168.1.1%ether3 \
    routing-table=to_WAN1 scope=10
add comment=PROBE_WAN1_T2 dst-address=1.1.1.1/32 gateway=192.168.1.1%ether1 \
    routing-table=to_WAN2 scope=10
add comment=PROBE_WAN2_T2 dst-address=8.8.8.8/32 gateway=192.168.1.1%ether2 \
    routing-table=to_WAN2 scope=10
add comment=PROBE_WAN3_T2 dst-address=9.9.9.9/32 gateway=192.168.1.1%ether3 \
    routing-table=to_WAN2 scope=10
add comment=PROBE_WAN1_T3 dst-address=1.1.1.1/32 gateway=192.168.1.1%ether1 \
    routing-table=to_WAN3 scope=10
add comment=PROBE_WAN2_T3 dst-address=8.8.8.8/32 gateway=192.168.1.1%ether2 \
    routing-table=to_WAN3 scope=10
add comment=PROBE_WAN3_T3 dst-address=9.9.9.9/32 gateway=192.168.1.1%ether3 \
    routing-table=to_WAN3 scope=10
add check-gateway=ping comment=REC_MAIN_WAN2 distance=3 dst-address=0.0.0.0/0 \
    gateway=8.8.8.8 routing-table=main target-scope=11
add check-gateway=ping comment=REC_MAIN_WAN3 distance=4 dst-address=0.0.0.0/0 \
    gateway=9.9.9.9 routing-table=main target-scope=11
add check-gateway=ping comment=FAILOVER_WAN2_T1 distance=2 dst-address=\
    0.0.0.0/0 gateway=8.8.8.8 routing-table=to_WAN1 scope=30 target-scope=11
add check-gateway=ping comment=FAILOVER_WAN1_T2 distance=2 dst-address=\
    0.0.0.0/0 gateway=1.1.1.1 routing-table=to_WAN2 scope=30 target-scope=11
add check-gateway=ping comment=FAILOVER_WAN3_T2 distance=3 dst-address=\
    0.0.0.0/0 gateway=9.9.9.9 routing-table=to_WAN2 scope=30 target-scope=11
add check-gateway=ping comment=FAILOVER_WAN3_T1 distance=3 dst-address=\
    0.0.0.0/0 gateway=9.9.9.9 routing-table=to_WAN1 scope=30 target-scope=11
add check-gateway=ping comment=FAILOVER_WAN1_T3 distance=2 dst-address=\
    0.0.0.0/0 gateway=1.1.1.1 routing-table=to_WAN3 scope=30 target-scope=11
add check-gateway=ping comment=FAILOVER_WAN2_T3 distance=3 dst-address=\
    0.0.0.0/0 gateway=8.8.8.8 routing-table=to_WAN3 scope=30 target-scope=11
/ipv6 dhcp-client
add comment=TEST_IPV6_PD_WAN1 dhcp-options="" interface=ether1 pool-name=\
    ISP1_PD pool-prefix-length=64 request=address
add comment=TEST_IPV6_ADDR_WAN2 dhcp-options="" interface=ether2 pool-name=\
    ISP2_PD pool-prefix-length=64 request=address use-interface-duid=yes \
    use-peer-dns=no
add comment=TEST_IPV6_ADDR_WAN3 dhcp-options="" interface=ether3 pool-name=\
    ISP3_PD pool-prefix-length=64 request=address use-interface-duid=yes \
    use-peer-dns=no
/ipv6 firewall filter
add action=accept chain=input comment="V6-IN established-related" \
    connection-state=established,related,untracked
add action=drop chain=input comment="V6-IN drop-invalid" connection-state=\
    invalid
add action=accept chain=input comment="V6-IN allow-ICMPv6" protocol=icmpv6
add action=accept chain=input comment="V6-IN allow-DHCPv6-client" dst-port=\
    546 in-interface-list=WAN protocol=udp src-address=fe80::/10
add action=accept chain=input comment="V6-IN allow-LAN" in-interface-list=LAN
add action=drop chain=input comment="V6-IN drop-WAN" in-interface-list=WAN
add action=accept chain=forward comment="V6-FWD established-related" \
    connection-state=established,related,untracked
add action=drop chain=forward comment="V6-FWD drop-invalid" connection-state=\
    invalid
add action=accept chain=forward comment="V6-FWD allow-ICMPv6" \
    in-interface-list=LAN protocol=icmpv6
add action=accept chain=forward comment="V6-FWD LAN-to-WAN" \
    in-interface-list=LAN out-interface-list=WAN
add action=drop chain=forward comment="V6-FWD drop-unsolicited-WAN" \
    in-interface-list=WAN
add action=drop chain=forward comment="V6-FWD drop-other"
add action=drop chain=input comment="V6-IN drop-other"
/ipv6 firewall nat
add action=masquerade chain=srcnat comment=NAT66_ULA_LAN_to_WAN \
    out-interface-list=WAN src-address=fd7c:3a91:6d20:1::/64
/system clock
set time-zone-name=Asia/Bangkok
/interface bridge port
add bridge=bridge_LAN interface=ether4
add bridge=bridge_LAN interface=ether5
