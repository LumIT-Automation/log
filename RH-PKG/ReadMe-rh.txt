The syslog-ng package is not installable from the default repositories in Redhat8/Centos8 systems.
To install the package in redhat8 it's sufficient enable the supplementary repository:

    subscription-manager repos --enable rhel-8-for-x86_64-supplementary-rpms

To install it in Centos8 the epel repos are needed:
    dnf install epel-release

That's all.


