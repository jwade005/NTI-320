Name:		check_cool_plugin
Version:	1.2
Release:	1%{?dist}
Summary:	cool new nrpe plugin rpm

Group:		nti320-jwade005
License:	GPL
URL:		github.com/jwade005/nti320/rpm
Source0:	check_cool_plugin-1.0.tar.gz

BuildRoot: %{_tmppath}/%{name}-buildroot

%description
this is a beta rpm build for a nagios nrpe plugin

%prep
%setup -q -c


%build
#%%configure
#make %{?_smp_mflags}


%install
#make install DESTDIR=%{buildroot}
sudo cp /home/Jonathan/rpmbuild/BUILD/check_cool_plugin-1.0/SOURCES/plugins/check_cool_plugin $RPM_BUILD_ROOT/
sudo mv $RPM_BUILD_ROOT/check_cool_plugin /usr/lib64/nagios/plugins/check_cool_plugin
sudo chmod +x /usr/lib64/nagios/plugins/check_cool_plugin
sudo chown root:nagios /usr/lib64/nagios/plugins/check_cool_plugin

sudo sed -i "308i command[check_cool_plugin]=\/usr\/lib64\/nagios\/plugins\/check_cool_plugin -w 66 -c 902" /usr/local/nagios/etc/nrpe.cfg

%clean
rm -rf $RPM_BUILD_ROOT

%post
echo . .
echo .cehck_cool_plugin nagios nrpe plugin installed!.

%files
#/check_cool_plugin
#/check_cool_plugin.spec
#/install

%dir


%doc



%changelog
