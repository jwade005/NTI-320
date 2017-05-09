%define        __spec_install_post %{nil}
%define          debug_package %{nil}
%define        __os_install_post %{_dbpath}/brp-compress

Name:		check_cool_plugin
Version:	1.0
Release:	1%{?dist}
Summary:	cool new nrpe plugin rpm

Group:		nti320-jwade005
License:	GPL
URL:		github.com/jwade005/nti320/rpm
Source0:	%{name}-%{version}.tar.gz

BuildRoot:	%{_tmppath}/%{name}-%{version}-%{release}-buildroot

%description
this is a beta rpm build for a nagios nrpe plugin

%prep
%setup -q -c

%build

%install
rm -rf %{buildroot}
mkdir -p  %{buildroot}
cp -a * %{buildroot}

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root,-)
/SOURCES/plugins/%{name}
/SOURCES/plugins/install

%post
./install

%dir

%doc

%changelog
