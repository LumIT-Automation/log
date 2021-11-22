#!/bin/bash

# Default config directory.
confDir=/etc/syslog-ng/conf.d
logCelery="no"

HELP="usage: $0 -a apiType
-d dir where config files are written (default $confDir)
-c add config lines for celery logs (default no)
-h this help

Example: $0 -a api-f5
"

DEBUG='n'
while getopts "a:d:ch" opt; do
    case $opt in
        a  ) apiType="$OPTARG" ;;
        d  ) confDir="$OPTARG" ;;
        c  ) logCelery="yes" ;;
        h  ) echo "$HELP"; exit 0 ;;
        *  ) echo "$HELP"; exit 0 
    esac
done
shift $(($OPTIND - 1))

if [ -z "$apiType" ]; then
    echo "$HELP"
    exit 1
fi

APITYPE=`echo $apiType | tr [:lower:] [:upper:]`

if ! whoami | grep -q '^root$';then 
    echo "This script should be launched as root"
    exit 11
fi

mkdir -p /var/log/automation/${apiType}

confFilter='# apiType
filter f_match_DJANGO_APITYPE {
    match("django_apiType" value("PROGRAM"));
};
filter f_match_HTTP_APITYPE {
    match("http_apiType" value("PROGRAM"));
};
filter f_match_APACHE_ACCESS_APITYPE {
    match("apache_access_apiType" value("PROGRAM"));
};
filter f_match_APACHE_ERROR_APITYPE {
    match("apache_error_apiType" value("PROGRAM"));
};
filter f_match_DB_APITYPE {
    match("db_apiType" value("PROGRAM"));
};
filter f_match_CONSUL_AG_APITYPE {
    match("consul_agent_apiType" value("PROGRAM"));
};
filter f_match_REDIS_APITYPE {
    match("redis_apiType" value("PROGRAM"));
};
filter f_match_MARIADB_ERR_APITYPE {
    match("mariadb_error_apiType" value("PROGRAM"));
};
filter f_match_MARIADB_AUDIT_APITYPE {
    match("mariadb_audit_apiType" value("PROGRAM"));
};
filter f_match_UPGRADES_APITYPE {
    match("unattended-upgrades_apiType" value("PROGRAM"));
};
'


confDst='# apiType
destination d_django_apiType { file("/var/log/automation/apiType/django_apiType.log"); };
destination d_http_apiType { file("/var/log/automation/apiType/http_apiType.log"); };
destination d_apache_a_apiType { file("/var/log/automation/apiType/apache_access_apiType.log"); };
destination d_apache_e_apiType { file("/var/log/automation/apiType/apache_error_apiType.log"); };
destination d_db_apiType { file("/var/log/automation/apiType/db_apiType.log"); };
destination d_consul_agent_apiType { file("/var/log/automation/apiType/consul_agent_apiType.log"); };
destination d_redis_apiType { file("/var/log/automation/apiType/redis_apiType.log"); };
destination d_mariadb_err_apiType { file("/var/log/automation/apiType/mysql_err_apiType.log"); };
destination d_mariadb_audit_apiType { file("/var/log/automation/apiType/mysql_audit_apiType.log"); };
destination d_upgrades_apiType { file("/var/log/automation/apiType/unattended_upgrades_apiType.log"); };
'


confLog='# apiType
log { source(s_tcp_rfc5424); filter(f_match_DJANGO_APITYPE); destination(d_django_apiType); };
log { source(s_tcp_rfc5424); filter(f_match_HTTP_APITYPE); destination(d_http_apiType); };
log { source(s_tcp_rfc5424); filter(f_match_APACHE_ACCESS_APITYPE); destination(d_apache_a_apiType); };
log { source(s_tcp_rfc5424); filter(f_match_APACHE_ERROR_APITYPE); destination(d_apache_e_apiType); };
log { source(s_tcp_rfc5424); filter(f_match_DB_APITYPE); destination(d_db_apiType); };
log { source(s_tcp_rfc5424); filter(f_match_CONSUL_AG_APITYPE); destination(d_consul_agent_apiType); };
log { source(s_tcp_rfc5424); filter(f_match_REDIS_APITYPE); destination(d_redis_apiType); };
log { source(s_tcp_rfc5424); filter(f_match_MARIADB_ERR_APITYPE); destination(d_mariadb_err_apiType); };
log { source(s_tcp_rfc5424); filter(f_match_MARIADB_AUDIT_APITYPE); destination(d_mariadb_audit_apiType); };
log { source(s_tcp_rfc5424); filter(f_match_UPGRADES_APITYPE); destination(d_upgrades_apiType); };
'

if [ "$logCelery" == "yes" ]; then
    confFilter=${confFilter}'filter f_match_CELERY_APITYPE {
    match("celery_apiType" value("PROGRAM"));
};
'
    confDst=${confDst}'destination d_celery_apiType { file("/var/log/automation/apiType/celery_apiType.log"); };
'
    confLog=${confLog}'log { source(s_tcp_rfc5424); filter(f_match_CELERY_APITYPE); destination(d_celery_apiType); };
'
fi

cd $confDir || exit 1

echo "$confFilter" | sed -e "s/apiType/${apiType}/g" -e "s/APITYPE/${APITYPE}/g" > 01_filter_${apiType}.conf
echo "$confDst" | sed -e "s/apiType/${apiType}/g" -e "s/APITYPE/${APITYPE}/g" > 02_destination_${apiType}.conf
echo "$confLog" | sed -e "s/apiType/${apiType}/g" -e "s/APITYPE/${APITYPE}/g" > 03_log_${apiType}.conf

exit 0

