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

require('dumb-logger/version')

#
# This is just a one-off class to allow reporting things to stderr
# according to the verbosity level.  Very simple, not a complete
# logger at all.
#
class DumbLogger

  #
  # class DumbLogger eigenclass.
  # Since we may have had to open up a file, make sure closing it
  # again is part of our teardown process.
  #
  class << self
    #
    # If we have a currently open output stream that needs to be
    # closed (usually because we opened it ourself), close it as part
    # of the DumbLogger object teardown.
    #
    # @param [Reporter] obj
    #  Instance being torn down ('destructed').
    #
    def finalize(obj)
      if (obj.instance_variable_get(:@options)[:needs_close])
        obj.sink.close
      end
    end                         # def finalize
  end                           # class DumbLogger eigenclass

  #
  # Message flag for "do not append a newline".
  #
  NO_NL		= :no_nl

  #
  # Treat loglevel numbers as actual levels.
  #
  USE_LEVELS	= :loglevels_are_numbers

  #
  # Treat loglevel numbers as bitmasks.
  #
  USE_BITMASK	= :loglevels_are_bitmasks

  #
  # @!attribute [rw] loglevel
  #
  # Current reporting criteria; either a simple integer or a bitmask.
  #
  # @see #level_style
  #
  # If loglevels are being treated as integers, this is the maximum
  # level that will reported; that is, if a message is submitted with
  # level 7, but the loglevel is 5, the message will *not* be
  # reported.
  #
  # If loglevels are being treated as bitmasks, messages will be
  # reported only if submitted with a loglevel which has at least one
  # bit set that is also set in the instance loglevel.
  #
  # @return [Integer]
  #  Sets or returns the loglevel value.
  #
  attr_reader(:loglevel)

  attr_reader(:level_style)

  #
  # @!attribute [rw] level_style
  #
  # Control whether loglevels are treated as ascending integers, or as
  # bitmasks.
  #
  # @param [Symbol] style
  #  Either +USE_LEVELS+ or +USE_BITMASK+.
  #
  # @return [Symbol]
  #  Returns the current setting.
  #
  def level_style=(style)
    unless ([ USE_LEVELS, USE_BITMASK ].include?(style))
      raise ArgumentError.new('invalid loglevel style')
    end
    @level_style = style
  end                           # def level_style=

  #
  # @!attribute [rw] sink
  #
  # Sets or returns the sink to which we send our messages.
  #
  # When setting the sink, the value can be either an IO instance or a
  # string.  If a string, the +:append+ flag from the instance options
  # is used to determine whether the file will be rewritten from the
  # beginning, or just have text appended to it.
  # 
  # @return [IO]
  #  Returns the current report sink.
  #
  attr_reader(:sink)

  #
  # @!attribute [r] options
  #
  # Options controlling various aspects of our operation.
  #
  # @return [Hash]
  #  Returns current set of DumbLogger options for the instance.
  #
  attr_reader(:options)

  #
  # @!attribute [rw] prefix
  #
  # Prefix string to be inserted at the beginning of each line of
  # output we emit.
  #
  # @return [String]
  #  Sets or returns the prefix string to be used henceforth.
  #
  attr_accessor(:prefix)

  #
  # The loglevel attribute writer is custom in order to enforce
  # integer values.
  #
  # @param [Integer] arg
  #  New value for the maximum message verbosity.
  # @return [Integer]
  #  Returns loglevel in effect henceforth.
  #
  def loglevel=(arg)
    @loglevel = arg.to_i
    return @loglevel
  end                           # def loglevel=

  #
  # The #sink writer has special requirements, so we define it
  # explicitly.  See {#sink} for full documentation.
  #
  # @return [IO]
  #  Returns the sink IO object.
  #
  def sink=(arg)
    @sink.close if (@options[:needs_close] && (arg != @sink))
    #
    # If it's an IO, then we assume it's already open.
    #
    if (arg.kind_of?(IO))
      @sink = arg
      @options[:needs_close] = false
    else
      #
      # If it's a string, we treat it as a file name, open it, and
      # flag it for closing later.
      #
      @sink = File.open(arg, (self.append ? 'a' : 'w'))
      @options[:needs_close] = true
    end
    return @sink
  end                           # def sink=

  #
  # Constructor.
  #
  # @param [Hash] args
  # @option args [Boolean] :append (true)
  #  If true, any files opened will have reported text appended to them.
  # @option args [String] :prefix ('')
  #  String to insert at the beginning of each line of report text.
  # @option args [IO,String] :sink ($stderr)
  #  Where reports should be sent.
  # @option args [Integer] :loglevel (0)
  #  Maximum log level for reports.  See {#loglevel}.
  # @option args [Symbol] :level_style (USE_LEVELS)
  #  Whether message loglevels should be treated as integer levels or
  #  as bitmasks.
  #
  def initialize(args={})
    opts = args[:options] || {}
    @options = { :append => true }.merge(opts)
    self.prefix = args[:prefix] || ''
    self.level_style = args[:level_style] || args[:style] || USE_LEVELS
    self.loglevel = args[:loglevel] || args[:log_level] || 0
    @options[:needs_close] = false
    self.sink = args[:sink] || $stderr
  end                           # def initialize

  #
  # @!attribute [rw] append
  #
  # Controls the behaviour of sink files (*not* IO streams).  If
  # +true+, report text will be added to the end of any existing
  # contents; if +false+, files will be truncated and reports will
  # begin at position +0+.
  #
  # @return [Boolean]
  #  Sets or returns the append-on-write control value.
  #
  def append
    return (@options[:append] ? true : false)
  end                           # def append

  def append=(arg)
    @options[:append]	= (arg ? true : false)
    return self.append
  end                           # def append=

  #
  # @return [Boolean]
  #  Returns +true+ if new sink files opened by the instance will have
  #  report text appended to them.
  #
  def append?
    return self.append
  end                           # def append?

  #
  # Submit a report for possible transmission.
  # The argument is an array of strings, integers, and/or symbols.
  # Reports with a loglevel of zero (the default) are *always*
  # transmitted.
  #
  # @param [Array<String,Symbol,Integer,Hash>] args
  #  * The last integer in the array will be treated as the report's
  #    loglevel; default is +0+.
  #  * Any +Hash+ elements in the array will be merged and will
  #    temporarily override instance-wide options (_e.g._,
  #    <code>{ :prefix => 'alt' }</code> ).
  #  * If the DumbLogger::NO_NL value (a +Symbol+) appears in the array,
  #    the report will not include a terminating newline (useful for
  #    +"progress:..done"+ reports).
  #  * Any strings in the array are treated as text to be reported,
  #    one _per_ line.  Each line will begin with the value of
  #    #prefix, and only the final line is subject to the
  #    DumbLogger::NO_NL special-casing.
  #
  # @return [nil,Integer]
  #  Returns either +nil+ if the message's loglevel is higher than the
  #  reporting level, or the level of the report.
  #
  #  If integer levels are being used, a non-+nil+ return value is
  #  that of the message.  If bitmask levels are being used, the
  #  return value is a mask of the active level bits that applied to
  #  the message (_i.e._, +msg_bits & logging_mask+).
  #
  def message(*args)
    #
    # Extract any symbols, hashes, and integers from the argument
    # list.  This makes the calling format very flexible.
    #
    (symopts, args)	= args.partition { |elt| elt.kind_of?(Symbol) }
    (hashopts, args)	= args.partition { |elt| elt.kind_of?(Hash) }
    hashopts		= hashopts.reduce(:merge) || {}
    (level, args)	= args.partition { |elt| elt.kind_of?(Integer) }
    level		= level.last || 0
    cur_loglevel	= self.loglevel
    cur_style		= self.level_style
    unless (level.zero?)
      if (cur_style == USE_LEVELS)
        return nil if (cur_loglevel < level)
      elsif (cur_style == USE_BITMASK)
        return nil if ((level = level & cur_level).zero?)
      end
    end
    prefix_text		= hashopts[:prefix] || self.prefix
    text		= prefix_text + args.join("\n#{prefix_text}")
    if ((! hashopts[:newline]) \
        && (symopts & [ NO_NL, :no_eol, :nonl, :no_nl ]).empty?)
      self.sink.puts(text)
    else
      self.sink.print(text)
    end
    return level
  end                           # def message

end                             # class DumbLogger
