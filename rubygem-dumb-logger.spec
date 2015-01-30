%global	gem_name	dumb-logger
%global	rubyabi		1.9.1

Name:		rubygem-%{gem_name}
Version:	0.0.0
Release:	1%{?dist}

Summary:	A very basic level-or-mask status logger.

Group:		Development/Languages

License:	Apache 2.0 or GPLv2
URL:		git@github.com:RoUS/dumb-logger.git
Source0:	%{gem_name}-%{version}.gem

BuildRequires:	ruby(abi) = %{rubyabi}
BuildRequires:	ruby-devel
BuildRequires:	rubygems-devel
BuildRequires:	rubygem(rake)
BuildRequires:	rubygem(aruba)
BuildRequires:	rubygem(bundler)
BuildRequires:	rubygem(cucumber)
BuildRequires:	rubygem(yard)
Requires:	ruby(abi) = %{rubyabi}
Requires:	rubygems
Provides:	rubygem(dumb-logger) = %{version}


%description
This provides a simple text-based logger class that can deliver
messages to files or Ruby IO streams based on logging levels or
bitmasks.


%prep
%setup -q -c -T
mkdir -p ./%{gem_dir}


%build
export CONFIGURE_ARGS="--with-cflags='%{optflags}'"
gem install --local --install-dir .%{gem_dir} -V --force %{SOURCE0}


%install
mkdir -p $RPM_BUILD_ROOT%{gem_dir}
mkdir -p $RPM_BUILD_ROOT%{gem_extdir}/ext/%{gem_name}/ext
 
cp -a .%{gem_dir}/* %{buildroot}/%{gem_dir}

# Let's move arch dependent files to arch specific directory
cp -a ./%{gem_instdir}/ext/json/ext/json \
	$RPM_BUILD_ROOT%{gem_extdir}/ext/%{gem_name}/ext

chmod 0644 $RPM_BUILD_ROOT%{gem_instdir}/install.rb
chmod 0644 $RPM_BUILD_ROOT%{gem_instdir}/tests/*.rb
# Let's move arch dependent files to arch specific directory
cp -a ./%{gem_instdir}/ext/json/ext/json \
	$RPM_BUILD_ROOT%{gem_extdir}/ext/%{gem_name}/ext

chmod -R 0655 $RPM_BUILD_ROOT%{gem_instdir}/features

# We don't need those files anymore.
rm -rf $RPM_BUILD_ROOT%{gem_instdir}/{.require_paths,.gitignore,.travis.yml}


%check
pushd .%{gem_instdir}
ruby -S testrb -Ilib:ext/%{gem_name}/ext $(ls -1 tests/test_*.rb | sort)
popd


%files
%defattr(-,root,root,-)
%doc %{gem_instdir}/[A-Z]*
%exclude	%{gem_instdir}/Rakefile
%dir %{gem_instdir}
%dir %{gem_instdir}/lib
%dir %{gem_instdir}/lib/%{gem_name}
%{gem_instdir}/tools/
%{gem_instdir}/lib/%{gem_name}.rb
%{gem_instdir}/lib/%{gem_name}/version.rb
%{gem_spec}


%changelog
