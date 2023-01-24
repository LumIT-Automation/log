%post
#!/bin/bash

printf "\n* Post-installing...\n"

# Get the gateway of the podman network
gw=`podman network inspect podman | grep gateway | grep -Eo '[0-9\.]+'`

# Fallback.
if [ -z "$gw" ]; then
    net=$(podman network inspect podman | grep subnet | grep -Eo '[0-9\./]+')
    gw=$(echo $net | sed -r 's#[0-9]+/[0-9]+#1#')
fi

# If the $gw ip address is really present on the host system, configure syslog-ng to listen at that address.
if [ -n "$gw" ]; then
    if ip a | grep -q $gw; then
        echo "########################
# Sources
########################
# receive logs from a remote server using the RFC3164 protocol (BSD-syslog protocol).
source s_tcp_rfc3164 {
    network(
        ip(127.0.0.1)
        transport(\"tcp\")
        port(514)
        ip-protocol(4)
    );
};

# receive logs from remote servers using the RFC5424 protocol (IETF-standard syslog protocol).
source s_tcp_rfc5424 { 
    syslog(
        ip(${gw})
        port(601)
        transport(\"tcp\")
        ip-protocol(4)
    );
    syslog(
        ip(127.0.0.1)
        port(601)
        transport(\"tcp\")
        ip-protocol(4)
    );
};
" > /etc/syslog-ng/conf.d/00_sources.conf
    fi
fi

printf "\n* Restarting syslog-ng...\n"
systemctl restart syslog-ng

printf "\n* Post-install accomplished.\n"

exit 0

