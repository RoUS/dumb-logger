# -*- coding: utf-8 -*-
#--
#   Copyright © 2015 Ken Coar
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#++

Proc.new {
  libdir = File.join(File.dirname(__FILE__), 'lib')
  xlibdir = File.expand_path(libdir)
  $:.unshift(xlibdir) unless ($:.include?(libdir) || $:.include?(xlibdir))
}.call
require('dumb-logger/version')

Gem::Specification.new do |spec|
  spec.name          	= 'dumb-logger'
  spec.version       	= DumbLogger::VERSION
  spec.authors       	= [
                           'Ken Coar',
                          ]
  spec.email         	= [
                           'kcoar@redhat.com',
                          ]
  spec.summary       	= %q{Primitive level/mask-driven stream logger.}
  spec.description   	= <<-EOD
Primitive no-frills level/mask-driven stream logger,
originally developed to write messages to $stderr as part
of command-line app debugging.  But now so much more!
  EOD
  spec.homepage      	= 'https://github.com/RoUS/dumb-logger'
  spec.license       	= 'Apache 2.0'

  spec.files         	= `git ls-files -z`.split("\x0")
  spec.executables   	= spec.files.grep(%r!^bin/!) { |f| File.basename(f) }
  spec.test_files    	= spec.files.grep(%r!^(test|spec|features)/!)
  spec.extra_rdoc_files = [
                           'README.md',
                          ]
  spec.rdoc_options	= [
                           '--main',
                           'README.md',
                          ]
  spec.require_paths 	= [
                           'lib',
                          ]

  #
  # Make a hash for our dependencies, since we're using some fancy
  # code to declare them depending upon the version of the
  # environment.
  #
  requirements_all	= {
    'versionomy'	=> [
                            '>= 0.4.3',
                           ],
  }
  requirements_dev	= {
    'aruba'		=> [],
    'bundler'		=> [
                            '~> 1.7',
                           ],
    'cucumber'		=> [],
    'rake'		=> [
                            '~> 10.0',
                           ],
    'rdiscount'		=> [],
    'yard'		=> [
                            '>= 0.8.2',
                           ],
  }

  requirements_all.each do |gem,*vargs|
    args	= [ gem ]
    args.push(*vargs) unless (vargs.count.zero? || vargs[0].empty?)
    spec.add_dependency(*args)
  end

  #
  # The following bit of hanky-panky was adapted from uuidtools-2.1.3.
  #
  if (spec.respond_to?(:specification_version))
    spec.specification_version = 3

    if (Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0'))
      depmethod	= :add_development_dependency
    else
      depmethod	= :add_dependency
    end
  else
    depmethod	= :add_dependency
  end
  requirements_dev.each do |gem,*vargs|
    args	= [ gem ]
    args.push(*vargs) unless (vargs.count.zero? || vargs[0].empty?)
    spec.send(depmethod, *args)
  end

end
