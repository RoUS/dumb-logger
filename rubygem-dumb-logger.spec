%global gems_dir	%(ruby -rubygems -e 'begin ; puts(Gem::RUBYGEMS_DIR) ; rescue ; puts(Gem::dir) ; end' 2>/dev/null)
%global geminstdir	%{gemdir}/gems/%{gemname}-%{version}
%global	gem_name	dumb-logger
%global	rubyabi		1.8

Name:		rubygem-%{gem_name}
Version:	0.0.0
Release:	1%{?dist}
BuildArch:	noarch

Summary:	A very basic level-or-mask status logger.

Group:		Development/Languages

License:	Apache 2.0 or GPLv2
URL:		https://github.com/RoUS/dumb-logger
Source0:	%{gem_name}-%{version}.gem

Requires:	ruby(abi) = %{rubyabi}
Requires:	ruby(rubygems) >= 1.3.6
Requires:	ruby 
BuildRequires:	ruby(abi) = %{rubyabi}
BuildRequires:	ruby
BuildRequires:	ruby(rubygems) >= 1.3.6
BuildRequires:	rubygem(versionomy)
Provides:	rubygem(dumb-logger) = %{version}


%description
This provides a simple text-based logger class that can deliver
messages to files or Ruby IO streams based on logging levels or
bitmasks.


%package doc
Summary:	Documentation for %{name}
Group:		Documentation
Requires:	%{name} = %{version}-%{release}
BuildArch:	noarch


%description doc
Documentation for %{name}


%prep
%setup -q -c -T
mkdir -p ./%{gems_dir}


%build
export CONFIGURE_ARGS="--with-cflags='%{optflags}'"
gem install --local --install-dir .%{gems_dir} -V --force %{SOURCE0}


%install
mkdir -p $RPM_BUILD_ROOT%{gems_dir}
 
cp -a .%{gems_dir}/* %{buildroot}/%{gems_dir}

#
# Comment these out until we know how to handle them.
#
#chmod    0644 $RPM_BUILD_ROOT%{gem_instdir}/tests/*.rb
#chmod -R 0655 $RPM_BUILD_ROOT%{gem_instdir}/features

#
# We don't need these files anymore, and they shouldn't be in the RPM.
#
rm -rf $RPM_BUILD_ROOT%{gem_instdir}/{.require_paths,.gitignore,.travis.yml}
rm -rf $RPM_BUILD_ROOT%{gem_instdir}/{test*,features*,rel-eng,Gemfile*}
rm -rf $RPM_BUILD_ROOT%{gem_instdir}/{Rakefile*,tasks*}
rm -rf $RPM_BUILD_ROOT%{gem_instdir}/%{name}.spec


#%check
#pushd .%{gem_instdir}
#ruby -S testrb -Ilib:ext/%{gem_name}/ext $(ls -1 tests/test_*.rb | sort)
#popd


%files
%defattr(-,root,root,-)
%doc		%{gem_instdir}/Change[Ll]og
%doc		%{gem_instdir}/CONTRIBUTORS.md
%doc		%{gem_instdir}/LICEN[SC]E.md
%dir		%{gem_instdir}
%dir		%{gem_instdir}/lib
%dir		%{gem_instdir}/lib/%{gem_name}
%{gem_instdir}/lib/*.rb
%{gem_instdir}/lib/%{gem_name}/*.rb
%{gem_spec}


%files doc
%doc		%{gemdir}/doc/%{gemname}-%{version}
%doc		%{geminstdir}/[A-Z]*.html


%changelog
* Fri Feb 13 2015 Ken Coar 1.0.2
- Added the Changelog and CONTRIBUTORS files.
- Added rake task to generate HTML from the markdown files.

* Mon Feb  9 2015 Ken Coar <coar@apache.org> - 
- Add positioning on first write to sink.  (Needs tests.)
- Add ability to reposition on *every* write to the sink.  (Needs tests.)
- Mark :return as deprecated, and update documentation & tests appropriately.
- Add tests verifying :newline overrides :return .
- Override the default #inspect method to conceal internal structures.
  (Needs tests.)
- Add class methods for declaring Boolean attributes (public or private).
- Move internal flags to a separate concealed structure, with a class
  method to define them.
