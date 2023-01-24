Name:       automation-interface-log
Version:    RH_VERSION
Release:    RH_RELEASE
Summary:    Automation Interface Syslog (commit: GITCOMMIT).

License:    GPLv3+
Source0:    RPM_SOURCE

Requires:   syslog-ng, podman >= 3.0.1
Conflicts:  rsyslog

BuildArch:  noarch

%description
automation-interface-log

%include %{_topdir}/SPECS/postinst.spec
%include %{_topdir}/SPECS/postrm.spec

%prep
%setup  -q #unpack tarball

%install
cp -rfa * %{buildroot}

%include %{_topdir}/SPECS/files.spec



