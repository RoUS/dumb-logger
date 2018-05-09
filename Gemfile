source('https://rubygems.org/')
#ENV['use_gemspec']	= 'true'

#
# All the dependencies *were* in dumb-logger.gemspec, but Bundler is
# remarkably stupid about gems needed *by* the gemspec.
#
if (ENV.has_key?('use_gemspec'))
  warn('Using gemspec for dependencies')
  gemspec
else
  warn('Using Gemfile for dependencies')
  unless (defined?(RUBY_ENGINE))
    RUBY_ENGINE		= 'ruby'
  end
  unless (defined?(RUBY_VERSION_SEGS))
    RUBY_VERSION_SEGS	= RUBY_VERSION.sub(%r![^\d.]!, '').split(%r!\.!).map { |s| s.to_i }
    RUBY_XVERSION	= ('%02i.%02i.%02i' % RUBY_VERSION_SEGS)
  end

  group(:default, :development, :test) do
    gem('bundler',	'>= 1.0.7')
    gem('versionomy',	'>= 0.4.4')
    if (RUBY_XVERSION < '01.09.00')
      gem('ruby-debug',	'>= 0')
    elsif (RUBY_XVERSION =~ %r!^01\.09..!)
      gem('debugger',	'>= 0')
    elsif (RUBY_XVERSION >= '02.00.00')
      gem('byebug',	'>= 0')
    end

    gem('dumb-logger',
        :path		=> '.')
  end                           # group(:default, :development, :test)

  group(:test, :development) do
    gem('aruba')
    gem('cucumber')
    gem('json',		'>= 1.8.1')
    gem('rake',		'>= 10.0')
    gem('rdiscount')
    gem('rdoc')
    gem('redcarpet',	'< 3.0.0')
    gem('simplecov',
        :require	=> false)
    gem('test-unit',
        :require	=> 'test/unit')
    gem('yard',		'>= 0.9.11')
  end                           # group(:test, :development)
end
