config system global
    set alias "FortiGate-VM64-AWS"
    set allow-traffic-redirect disable
    set gui-auto-upgrade-setup-warning disable
    set hostname "${admin_username}-secondary"
    set ipv6-allow-traffic-redirect disable
    set timezone "Asia/Bangkok"
end

config system admin
    edit "${admin_username}"
        set password "Tidc@2025"
        set accprofile "super_admin"
    next
end

config system interface
    edit "port1"
        set vdom "root"
        set mode dhcp
        set allowaccess ping https ssh http
        set type physical
        set snmp-index 1
        set mtu-override enable
        set mtu 9001
        set alias "management"
        set description "Management Interface"
    next
    edit "port2"
        set vdom "root"
        set mode dhcp
        set allowaccess ping
        set type physical
        set snmp-index 2
        set mtu-override enable
        set mtu 9001
        set alias "public"
        set description "Public/External Interface"
    next
    edit "port3"
        set vdom "root"
        set mode dhcp
        set allowaccess ping
        set type physical
        set snmp-index 3
        set defaultgw disable
        set mtu-override enable
        set mtu 9001
        set alias "private"
        set description "Private/Internal Interface"
    next
    edit "port4"
        set vdom "root"
        set mode dhcp
        set allowaccess ping https ssh fgfm
        set type physical
        set snmp-index 4
        set mtu-override enable
        set mtu 9001
        set alias "heartbeat"
        set description "HA Heartbeat Interface"
    next
end

config system ha
    set group-id 25
    set group-name "FGT-HA"
    set mode a-p
    set password "FortiGate-HA-Password"
    set hbdev "port4" 50
    set encryption enable
    set session-pickup enable
    set session-pickup-connectionless enable
    set session-pickup-expectation enable
    set ha-mgmt-status enable
    config ha-mgmt-interfaces
        edit 1
            set interface "port1"
            set gateway 10.22.8.1
        next
    end
    set override disable
    set priority 100
    set monitor "port2" "port3"
    set failover-hold-time 30
    set unicast-hb enable
    set unicast-hb-peerip ${peer_heartbeat_ip}
end

config system sdn-connector
    edit "AWS"
        set vpc-id ${vpc_id}
        set alt-resource-ip enable
        set update-interval 30
    next
end

config system dns
    set primary 10.22.0.2
    set secondary 96.45.46.46
    set protocol cleartext dot
    set server-hostname "globalsdns.fortinet.net"
    set server-select-method failover
end

config system ntp
    set ntpsync enable
    set type fortiguard
end

config log memory setting
    set status enable
end

config log disk setting
    set status enable
end
