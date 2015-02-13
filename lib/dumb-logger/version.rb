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

require('rubygems')
require('versionomy')

class DumbLogger

  #
  # Initial starting point.
  #
  @version	= Versionomy.parse('0.0.1')

  #
  # First actual release: 1.0.0!
  #
  @version	= @version.change(:major	=> 1,
                                  :tiny		=> 0)

  #
  # Version 1.0.1
  #
  # * Corrected & deprecated `:return` {#message} option key
  # * Added seek-to on first write to a sink
  # * Corrected (and documented) applicable level/mask determination
  #   for {#message}
  # * Added some tests for `:return` *versus* `:newline`
  #
  @version	= @version.bump(:tiny)

  #
  # Version 1.0.2
  #
  # * Added Changelog file.
  # * Added CONTRIBUTORS file.
  # * Moved class methods into a separate file.
  # * Added class methods for defining Boolean flag attributes.
  # * Added override of {#inspect} to conceal our internal bits.
  # * Added `:seek_to_eof` option and made positioning more reliable.
  # * Updated/added various bits of documentation.
  #
  @version	= @version.bump(:tiny)

  #
  # How to advance the version number.
  #
  #@version	= @version.bump(:minor)

  @version.freeze

  #
  # Frozen string representation of the module version number.
  #
  VERSION	= @version.to_s.freeze

  #
  # Returns the {http://rubygems.org/gems/versionomy Versionomy}
  # representation of the package version number.
  #
  # @return [Versionomy]
  #
  def self.version
    return @version
  end                           # def self.version

  #
  # Returns the package version number as a string.
  #
  # @return [String]
  #   Package version number.
  #
  def self.VERSION
    return self.const_get('VERSION')
  end                           # def self.VERSION

end                             # class DumbLogger
