Name:		check_cool_plugin
Version:	1.0
Release:	1%{?dist}
Summary:	cool new nrpe plugin rpm

Group:		nti320-jwade005
License:	GPL
URL:		github.com/jwade005/nti320/rpm
Source0:	check_cool_plugin-1.0.tar.gz

BuildRequires:
Requires:

BuildRoot: %{_tmppath}/%{name}-buildroot

%description
this is a beta rpm build for a nagios nrpe plugin

%prep
%setup -q


%build
%configure
make %{?_smp_mflags}


%install
make install DESTDIR=%{buildroot}
install -m 0755 -d $RPM_BUILD_ROOT/usr/lib64/nagios/plugins/
install -m 0755 check_cool_plugin.sh $RPM_BUILD_ROOT/usr/lib64/nagios/plugins/check_cool_plugin

%clean
rm -rf $RPM_BUILD_ROOT

%post
echo . .
echo .cehck_cool_plugin nagios nrpe plugin installed!.

%files
%dir /usr/lib64/nagios/plugins/
/usr/lib64/nagios/plugins/check_cool_plugin.sh


%doc



%changelog
