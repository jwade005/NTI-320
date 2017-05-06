Name: check_cool_plugin
Version: 1
Release: 0
Summary: cool new nrpe plugin rpm
Source0: check_cool_plugin-1.0.tar.gz
License: GPL
Group: nti320
BuildArch: noarch
BuildRoot: %{_tmppath}/%{name}-buildroot
%description
this is a beta rpm build for a nagios nrpe plugin
%prep
%setup -q
%build
%install
install -m 0755 -d $RPM_BUILD_ROOT/usr/lib64/nagios/plugins/
install -m 0755 check_cool_plugin.sh $RPM_BUILD_ROOT/usr/lib64/nagios/plugins/backup.sh
%clean
rm -rf $RPM_BUILD_ROOT
%post
echo . .
echo .cehck_cool_plugin nagios nrpe plugin installed!.
%files
%dir /usr/lib64/nagios/plugins/
/usr/lib64/nagios/plugins/check_cool_plugin.sh
