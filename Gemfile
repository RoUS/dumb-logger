source('https://rubygems.org/')

#
# All the dependencies *were* in dumb-logger.gemspec, but Bundler is
# remarkably stupid about gems needed *by* the gemspec.
#
#gemspec

RUBY_ENGINE	= 'ruby' unless (defined?(RUBY_ENGINE))

group(:default, :development, :test) do
  gem('bundler',	'>= 1.0.7')
  gem('versionomy',	'>= 0.4.4')
  platforms(:mri_18) do
    gem('ruby-debug',	'>= 0')
  end
  platforms(:mri_19) do
    gem('debugger',	'>= 0')
  end
  platforms(:mri_20, :mri_21) do
    gem('byebug',	'>= 0')
  end

  gem('dumb-logger',
      :path		=> '.')
end

group(:test, :development) do
  gem('aruba')
  gem('cucumber')
  gem('json',		'>= 1.8.0')
  gem('rake')
  gem('simplecov',
      :require		=> false)
  gem('rdiscount')
  gem('redcarpet',	'< 3.0.0')
  gem('test-unit',
      :require		=> 'test/unit')
  gem('rdoc')
  gem('yard',		'~> 0.8.6')
end
