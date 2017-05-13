Name:		check_jwade005_plugin
Version:	1.0
Release:	1%{?dist}
Summary:	this is jwade005's nagios nrpe plugin

Group:		nti320-jwade005
License:	GPL
URL:		https://github.com/jwade005/NTI-320/tree/master/rpm
Source0:	check_jwade005_plugin-1.0.tar.gz

Requires:	bash

%description
this is a plugin for nagios

%prep
%setup -q


%build


%install
rm -rf %{buildroot}

mkdir -p %{buildroot}/usr/lib64/nagios/plugins

install -m 0755 %{name} %{buildroot}/usr/lib64/nagios/plugins/%{name}

%clean
rm -rf %{buildroot}

%files
/usr/lib64/nagios/plugins/check_jwade005_plugin

%post
sudo chown nagios:nagios /usr/lib64/nagios/plugins/check_jwade005_plugin
sudo chmod +x /usr/lib64/nagios/plugins/check_jwade005_plugin
sudo sed -i "215i command[check_jwade005_plugin]=\/usr\/lib64\/nagios\/plugins\/check_jwade005_plugin -w 66 -c 902" /etc/nagios/nrpe.cfg

%doc



%changelog
* Thu May 11 2017 jonathan wade <jwade005@seattlecentral.edu> 1.0.1
- Added support for post install script
