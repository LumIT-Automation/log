%postun
#!/bin/bash

if rpm -qa | grep -q syslog-ng; then
    printf "\n* Post-removing...\n"

    printf "\n* Restarting syslog-ng...\n"
    systemctl restart syslog-ng
fi

exit 0
