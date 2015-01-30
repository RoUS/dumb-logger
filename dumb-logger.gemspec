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
  spec.summary       	= %q{Primitive level/mask driven stream logger.}
#  spec.description   	= %q{TODO: Write a longer description. Optional.}
  spec.homepage      	= ''
  spec.license       	= 'Apache 2.0'

  spec.files         	= `git ls-files -z`.split("\x0")
  spec.executables   	= spec.files.grep(%r!^bin/!) { |f| File.basename(f) }
  spec.test_files    	= spec.files.grep(%r!^(test|spec|features)/!)
  spec.require_paths 	= [
                           'lib',
                          ]

  spec.add_development_dependency('bundler', '~> 1.7')
  spec.add_development_dependency('rake', '~> 10.0')

  spec.add_dependency('versionomy')
end
