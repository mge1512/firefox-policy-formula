#
# spec file for package firefox-policy-formula
#
# Copyright (c) 2026 Matthias G. Eckermann
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via https://bugs.opensuse.org/
#


%define fname firefox-policy
Name:           %{fname}-formula
Version:        0.2.1
Release:        0
Summary:        Firefox Enterprise Policies Salt Formula for SUSE Multi-Linux Manager and Uyuni
License:        Apache-2.0
Group:          System/Management
URL:            https://github.com/mge1512/firefox-policy-formula
Source0:        %{name}-%{version}.tar.gz
Requires:       salt-master
BuildArch:      noarch

%description
Salt Formula with a form for SUSE Multi-Linux Manager and Uyuni.
It manages the system-wide Firefox enterprise policy file
(policies.json) on client systems from structured pillar data,
replacing manual editing or the Firefox Enterprise Policy Generator.


%prep
%setup -q

%build

%install
mkdir -p %{buildroot}%{_datadir}/susemanager/formulas/states/%{fname}
mkdir -p %{buildroot}%{_datadir}/susemanager/formulas/metadata/%{fname}
cp -R states/* %{buildroot}%{_datadir}/susemanager/formulas/states/%{fname}
cp -R metadata/* %{buildroot}%{_datadir}/susemanager/formulas/metadata/%{fname}

%files
%defattr(-,root,root,-)
%license LICENSE
%doc README.md
%{_datadir}/susemanager

%changelog
