%post
#!/bin/bash

printf "\n* Post-installing...\n"

printf "\n* Restarting syslog-ng...\n"
systemctl restart syslog-ng

printf "\n* Post-install accomplished.\n"

exit 0

