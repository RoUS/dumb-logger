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
require('dumb-logger/classmethods')

#
# This is just a one-off class to allow reporting things to stderr
# according to the verbosity level.  Very simple, not a complete
# logger at all.
#
# @todo
#  Allow assignment of prefices to levels the way we now do labels.
#  Will probably only work with level-based reporting, since
#  mask-based reports may get transmitted due to a mask `AND` that
#  doesn't match any named masks.
#
class DumbLogger

  #
  # Message flag for "do not append a newline".
  #
  NO_NL		= :no_nl

  #
  # Treat loglevel numbers as bitmasks.
  #
  USE_BITMASK	= :loglevels_are_bitmasks

  #
  # Treat loglevel numbers as actual levels.
  #
  USE_LEVELS	= :loglevels_are_numbers

  #
  # Special sink values, which will get evaluated on every transmission.
  #
  SPECIAL_SINKS	= [
                   :$stdout,
                   :$stderr,
                  ]

  # @private
  #
  # Flag indicating that the sink is new and hasn't had anything sent
  # to it yet.
  #
  private_flag(:first_write)

  # @private
  #
  # Flag indicating that we explicitly opened the sink, and thus are
  # responsible for closing it again.
  #
  private_flag(:needs_close)

  # @private
  #
  # Flag indicating that we need to position the logger stream before
  # the next write.
  #
  private_flag(:needs_seek)

  # @private
  #
  # Flag indicating that the sink is special and needs to be evaluated
  # before each write operation.
  #
  private_flag(:volatile)

  # @private
  #
  # Rewrite the #inspect method so our internals aren't exposed.
  #
  # @return [String]
  #
  def inspect
    result = super
    #
    # Not sure how they'll be displayed in the output, so strip out
    # occurrences with leading and trailing commas.
    #
    result.sub!(%r!@?controls=\{[^}]*\}(?:,\s*)(>)?!, '\1')
    result.sub!(%r!,\s*@?controls=\{[^}]*\}!, '')
    result.sub!(%r!,\s*@?sink_io=.*?([,>])!, '\1')
    result.sub!(%r!@?sink_io=.*?([,>])!, '\1')
    return result
  end                           # def inspect

  #
  # @!attribute [rw] append
  #
  # Controls the behaviour of subsequently-opened sink files (but
  # *not* IO streams).  If `true`, report text will be added to the
  # end of any existing contents; if `false`, files will be truncated
  # and reports will begin at position `0`.
  #
  # @note
  #  This setting is only important when a sink is being activated,
  #  such as `DumbLogger` object instantiation or because of a call to
  #  {#sink=}, and it controls the position of the first write to the
  #  sink.  Once a sink is activated (opened), writing continues
  #  sequentially from that point.
  #
  # @note
  #  Setting this attribute *only* affects **files** subsequently
  #  opened by `DumbLogger`.  Stream sinks are *always* in
  #  append-mode.  As long as the sink is a stream, this setting will
  #  be ignored -- but it will become meaningful whenever the sink
  #  becomes a file.
  #
  # @return [Boolean]
  #  Sets or returns the file append-on-write control value.
  #
  # @example
  #  #
  #  # Create a logger that will create or open the file `/tmp/foo.log`
  #  # for messages, and begin writing at the beginning regardless of
  #  # what content it might already contain.
  #  #
  #  File.open('/tmp/foo.log', 'w') { |io| io.puts('Pre-text.') }
  #  daml = DumbLogger.new(:sink => '/tmp/foo.log', :append => false)
  #  daml.append?
  #  => false
  #  daml.message(0, 'Logged message')
  #  #
  #  # /tmp/foo.log should now contain "Logged message.\n"
  #  #
  #
  # @example
  #  #
  #  # Create a logger than will append text to an existing (or new)
  #  # file.
  #  #
  #  File.open('/tmp/foo.log', 'w') { |io| io.puts('Pre-text.') }
  #  daml = DumbLogger.new(:sink => '/tmp/foo.log', :append => true)
  #  daml.append?
  #  => true
  #  daml.message(0, 'Logged message')
  #  #
  #  # /tmp/foo.log should now contain "Pre-text.\nLogged message.\n"
  #  #
  #
  public_flag(:append)

  #
  # @!method append?
  #
  # @return [Boolean]
  #  Returns `true` if new sink files opened by the instance will have
  #  report text appended to them.
  #

  #
  # Allow the user to assign labels to different log levels or mask
  # combinations.  All labels will be downcased and converted to
  # symbols.
  #
  # In addition, the labels are added to the instance as methods that
  # will log messages with the specified level.
  #
  # @see #labeled_levels
  #
  # @param [Hash{String,Symbol=>Integer}] labelhash
  #  Hash of names or symbols and the integer log levels/masks they're
  #  labelling.
  #
  # @return [Hash<Symbol,Integer>]
  #  Returns a hash of the labels (as symbols) and levels/masks that
  #  have been assigned.
  #
  # @raise [ArgumentError]
  #  Raises an *ArgumentError* exception if the argument isn't a hash
  #  with integer values.
  #
  # @example
  #  #
  #  # Add labels corresponding to repeated '-v' command-line options:
  #  #
  #  daml = DumbLogger.new(:level_style => DumbLogger::USE_LEVELS)
  #  daml.label_levels(:labels => {
  #                      :v    => 1,
  #                      :vv   => 2,
  #                      :vvv  => 3,
  #                      :vvvv => 4,
  #                    })
  #
  #  daml.v  ('Message sent for loglevel >= 1 (-v, -vv, -vvv, etc.)')
  #  daml.vv ('Message sent for loglevel >= 2 (-vv, -vvv, etc.)')
  #  daml.vvv('Message sent for loglevel >= 3 (-vvv, -vvvv, etc.)')
  #
  # @example
  #  #
  #  # Copy labels from the already set up stderr logger to a new one
  #  # sinking to stdout:
  #  #
  #  stdout_logger = DumbLogger.new
  #  stdout_logger.label_levels(stderr_logger.labeled_levels)
  #
  def label_levels(labelhash)
    #
    # Verify our argument first.
    #
    unless (labelhash.kind_of?(Hash))
      raise ArgumentError.new('level labels must be supplied as a hash')
    end
    unless (labelhash.values.all? { |o| o.kind_of?(Integer) })
      raise ArgumentError.new('labeled levels must be integers')
    end
    #
    # Create a hash of the labels-as-Symbols and their integer values.
    #
    newhash = labelhash.inject({}) { |memo,(label,level)|
      label_sym = label.to_s.downcase.to_sym
      memo[label_sym] = level
      memo
    }
    #
    # Add them to our existing list of labels, possibly silently
    # overriding any colliding names.
    #
    @options[:labels].merge!(newhash)
    #
    # Create singleton methods on this instance corresponding to the
    # labels.  We force the correct interpretation by using our
    # label's value in a trailing option hash.
    #
    newhash.each do |label,level|
      self.define_singleton_method(label) do |*args|
        optkey		= (self.log_masks? ? :mask : :level)
        override	= {
          optkey	=> level,
        }
        args << override
        return self.message(*args)
      end
    end
    return newhash
  end                           # def label_levels

  #
  # Return a list of all the levels or bitmasks that have been labeled.
  # The return value is suitable for use as input to the #label_levels
  # method of this or another instance of this class.
  #
  # @see #label_levels
  #
  # @return [Hash<Symbol,Integer>]
  #  Returns a hash of labels (as symbols) and the log levels they
  #  identify.
  #
  def labeled_levels
    return Hash[@options[:labels].sort].freeze
  end                           # def labeled_levels

  #
  # @!attribute [rw] level_style
  #
  # Control whether loglevels are treated as ascending integers, or as
  # bitmasks.
  #
  # @return [Symbol]
  #  Returns the current setting (either {USE_LEVELS} or {USE_BITMASK}).
  #
  # @raise [ArgumentError]
  #  Raises an *ArgumentError* exception if the style isn't
  #  recognised.
  #
  def level_style
    return @options[:level_style]
  end                           # def level_style

  def level_style=(style)
    unless ([ USE_LEVELS, USE_BITMASK ].include?(style))
      raise ArgumentError.new('invalid loglevel style')
    end
    @options[:level_style] = style
  end                           # def level_style=

  #
  # @!attribute [rw] loglevel
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
  # When used as an attribute writer ( *e.g.*, `obj.loglevel = val`),
  # the argument will be treated as an integer.
  #
  # @return [Integer]
  #  Returns the maximum loglevel/logging mask in effect henceforth.
  #
  # @raise [ArgumentError]
  #  Raise an *ArgumentError* exception if the new value cannot be
  #  converted to an integer.
  #
  def loglevel=(arg)
    unless (arg.respond_to?(:to_i))
      raise ArgumentError.new('loglevels are integers')
    end
    @options[:loglevel] = arg.to_i
    return self.loglevel
  end                           # def loglevel=
  alias_method(:logmask=, :loglevel=)

  def loglevel
    return @options[:loglevel].to_i
  end                           # def loglevel
  alias_method(:logmask, :loglevel)

  #
  # Returns `true` if loglevel numbers are interpreted as integers
  # rather than bitmasks.  (See {#level_style} for more information.)
  #
  # @return [Boolean]
  #  Returns `true` if loglevels are regarded as integers rather than
  #  bitmasks, or `false` otherwise.
  #
  # @see #log_masks?
  # @see #level_style
  #
  def log_levels?
    return (@options[:level_style] == USE_LEVELS) ? true : false
  end                           # def log_levels?

  #
  # Returns `true` if loglevel numbers are interpreted as bitmasks
  # rather than integers.  (See {#level_style} for more information.)
  #
  # Determine how loglevel numbers are interpreted.  (See
  # {#level_style} for more information.)
  #
  # Returns `true` if they're treated as bitmasks rather than integers.
  #
  # @return [Boolean]
  #  Returns `true` if loglevels are regarded as bitmasks rather than
  #  integers, or `false` otherwise.
  #
  # @see #log_levels?
  # @see #level_style
  #
  def log_masks?
    return (@options[:level_style] == USE_BITMASK) ? true : false
  end                           # def log_masks?

  # @private
  #
  # List of option keys settable in the constructor.
  #
  CONSTRUCTOR_OPTIONS	= [
                           :append,
                           :level_style,
                           :loglevel,
                           :logmask,
                           :labels,
                           :prefix,
                           :seek_to_eof,
                           :sink,
                          ]

  #
  # @!attribute [r] options
  #
  # Options controlling various aspects of `DumbLogger`'s operation.
  #
  # @return [Hash]
  #  Returns current set of DumbLogger options for the instance.
  #
  def options
    result = @options.dup.freeze
    return result
  end                           # def options

  #
  # @!attribute [rw] prefix
  #
  # Prefix string to be inserted at the beginning of each line of
  # output we emit.
  #
  # @note
  #  This can be overridden at runtime *via* the `:prefix` option hash
  #  element to the {#message} method ( *q.v.*).
  #
  # @return [String]
  #  Sets or returns the prefix string to be used henceforth.
  #
  def prefix
    return @options[:prefix]
  end                           # def prefix

  def prefix=(arg)
    @options[:prefix] = arg.to_s
    return self.prefix
  end                           # def prefix=

  #
  # Re-open the current sink (unless it's a stream).  This may be
  # useful if you want to stop and truncate in the middle of logging
  # (by changing the {#append=} option), or something.
  #
  # @return [Boolean]
  #  Returns `true` if the sink was successfully re-opened, or `false`
  #  otherwise (such as if it's a stream).
  #
  # @raise [IOError]
  #  Raises an *IOError* exception if the sink stream is already
  #  closed.
  #
  def reopen
    return false unless (self.needs_close? && self.sink.kind_of?(String))
    raise IOError.new('sink stream is already closed') if (@sink_io.closed?)
    @sink_io.reopen(self.sink, (self.append? ? 'a' : 'w'))
    @sink_io.sync = true if (@sink_io.respond_to?(:sync=))
    return true
  end                           # def reopen

  #
  # @!attribute [rw] sink
  #
  # Sets or returns the sink to which we send our messages.
  #
  # When setting the sink, the value can be an IO instance, a special
  # symbol, or a string.  If a string, the `:append` flag from the
  # instance options (see {#append=} and {#append?}) is used to
  # determine whether the file will be rewritten from the beginning,
  # or just have text appended to it.
  #
  # Sinking to one of the special symbols (`:$stderr` or `:$stdout`;
  # see {SPECIAL_SINKS}) results in the sink being re-evaluated at
  # each call to {#message}.  This is useful if these streams might be
  # altered after the logger has been instantiated.
  #
  # @note
  #  File sink contents may appear unpredictable under the following
  #  conditions:
  #  * Messages are being sinked to a file, **and**
  #  * the file is being accessed by one or more other processes, **and**
  #  * changes to the file are interleaved between those made by the
  #    `DumbLogger` {#message} method and activity by the other
  #    process(es).
  #
  # @return [IO,String,Symbol]
  #  Returns the sink path, special name, or IO object.
  #
  def sink
    return @options[:sink]
  end                          # def sink

  def sink=(arg)
    if (self.needs_close? \
        && @sink_io.respond_to?(:close) \
        && (! [ self.sink, @sink_io ].include?(arg)))
      @sink_io.close unless (@sink_io.closed?)
      @sink_io = nil
    end

    self.volatile = false
    if (arg.kind_of?(IO))
      #
      # If it's an IO, then we assume it's already open.
      #
      @options[:sink] = @sink_io = arg
      self.needs_close = false
    elsif (SPECIAL_SINKS.include?(arg))
      #
      # If it's one of our special symbols, we don't actually do
      # anything except record the fact -- because they get
      # interpreted at each #message call.
      #
      @options[:sink] = arg
      @sink_io = nil
      self.volatile = true
    else
      #
      # If it's a string, we treat it as a file name, open it, and
      # flag it for closing later.
      #
      @options[:sink] = arg
      @sink_io = File.open(@options[:sink], (self.append? ? 'a' : 'w'))
      self.needs_close = true
    end
    #
    # Note that you cannot seek-position the $stdout or $stderr
    # streams.  However, there doesn't seem to be a clear way to
    # determine that, so we'll wrap the actual seek (in {#message}) in
    # a rescue block.
    #
    self.first_write = true
    @sink_io.sync = true if (@sink_io.respond_to?(:sync=))
    return self.sink
  end                           # def sink=

  #
  # Constructor.
  #
  # @param [Hash] args
  #
  # @option args [Boolean] :append (true)
  #  If true, any **files** opened will have transmitted text appended to
  #  them.  See {#append=}.
  # @note
  #  Streams are **always** treated as being in `:append => true` mode.
  #
  # @option args [String] :prefix ('')
  #  String to insert at the beginning of each line of report text.
  #  See {#prefix=}.
  #
  # @option args [Boolean] :seek_to_eof (false)
  #  Whether to *always* position at EOF before writing in {#append} mode.
  #
  # @option args [IO,String] :sink (:$stderr)
  #  Where reports should be sent.  See {#sink=}.
  #
  # @option args [Integer] :loglevel (0)
  #  Maximum log level for reports.  See {#loglevel=}.
  #
  # @option args [Integer] :logmask (0)
  #  Alias for `:loglevel`.
  #
  # @option args [Symbol] :level_style (USE_LEVELS)
  #  Whether message loglevels should be treated as integer levels or
  #  as bitmasks.  See {#level_style=}.
  #
  # @raise [ArgumentError]
  #  Raises an *ArgumentError* exception if the argument isn't a hash.
  #
  def initialize(args={})
    unless (args.kind_of?(Hash))
      raise ArgumentError.new("#{self.class.name}.new requires a hash")
    end
    @controls		= {}
    @options		= {
      :labels		=> {},
    }
    #
    # Here are the default settings for a new instance with no
    # arguments.  We put 'em here so they don't show up in docco under
    # the Constants heading.
    #
    default_opts	= {
      :append		=> true,
      :level_style	=> USE_LEVELS,
      :loglevel		=> 0,
      :prefix		=> '',
      :sink		=> :$stderr,
    }
    #
    # Make a new hash merging the user arguments on top of the
    # defaults.  This avoids altering the user's hash.
    #
    temp_opts		= default_opts.merge(args)
    #
    # Throw out any option keys we don't recognise.
    #
    temp_opts.delete_if { |k,v| (! CONSTRUCTOR_OPTIONS.include?(k)) }
    #
    # Do loglevel stuff.  We're going to run this through the writer
    # method, since it has argument validation code.
    #
    # If the user wants to use bitmasks, then the :logmask argument
    # key takes precedence over the :loglevel one.
    #
    self.level_style = temp_opts[:level_style]
    temp_opts.delete(:level_style)
    if (self.log_masks?)
      temp_opts[:loglevel] = temp_opts[:logmask] if (temp_opts.key?(:logmask))
    end
    temp_opts.delete(:logmask)
    #
    # Now go through the remaining options and handle them.  If the
    # option has an associated writer method, call it -- otherwise,
    # just load it into the `@options` hash.
    #
    temp_opts.each do |opt,val|
      wmethod	= (opt.to_s + '=').to_sym
      if (self.respond_to?(wmethod))
        self.send(wmethod, val)
      else
        @options[opt] = val
      end
    end
  end                           # def initialize

  #
  # @!attribute [rw] seek_to_eof
  #
  # Controls whether the sink is *always* positioned to the EOF before
  # writing message text.
  #
  # @note
  #  Only meaningful in {#append} mode; ignored otherwise.
  #
  # @note
  #  Setting this attribute *only* affects **files** opened by
  #  `DumbLogger`.  Stream sinks are *always* in append-mode.  As long
  #  as the sink is a stream, this setting will be ignored -- but it
  #  will become active whenever the sink is set to a file.
  #
  # @return [Boolean]
  #  Sets or returns the file seek-to-EOF control value.
  #
  public_flag(:seek_to_eof)
  def seek_to_eof
    result	= (@options[:seek_to_eof] ? true : false)
    self.needs_seek = self.first_write || result
    return result
  end                           # def seek_to_eof

  #
  # Submit a message for possible transmission to the current sink.
  # The argument is an array of arrays, strings, integers, and/or
  # symbols.  Reports with a loglevel of zero (the default) are
  # *always* transmitted.
  #
  # @param [Array<Array,String,Symbol,Integer,Hash>] args
  #  * The last integer in the array will be treated as the report's
  #    loglevel; default is `0`.
  #
  #    **Overridden by `:level` or `:mask` in an options hash passed
  #    to the method.**
  #  * Any `Array` elements in the arguments will be merged and the
  #    values interpreted as level labels (see {#label_levels}).  If
  #    loglevels are bitmasks (see {#level_style}), the labeled levels
  #    are `OR`ed together; otherwise the lowest labeled level will be
  #    used for the message.
  #
  #    **Overridden by `:level` or `:mask` in an options hash passed
  #    to the method.**
  #  * Any `Hash` elements in the array will be merged and will
  #    temporarily override instance-wide options -- *e.g.*,
  #    `{ :prefix  => 'alt' }` .  Valid *per*-call options are:
  #    * `:prefix  => String`
  #    * `:seek_to_eof => Boolean`
  #      (temporarily overrides {#seek_to_eof} logger setting.)
  #    * `:level   => Integer`
  #      (takes precedence over `:mask` if {#level_style} is {USE_LEVELS}.)
  #    * `:mask    => Integer`
  #      (takes precedence over `:level` if {#level_style} is {USE_BITMASK}.)
  #    * `:newline => Boolean`
  #      (takes precedence over {DumbLogger::NO_NL} in the argument list)
  #    * `:return  => Boolean`
  #      (alias for `:newline`; **deprecated after 1.0.0**)
  #  * If the {DumbLogger::NO_NL} value (a `Symbol`) appears in the
  #    array, or a hash element of `:newline => false` (or `:return =>
  #    false`), the report will not include a terminating newline
  #    (useful for `"progress:..done"` reports).
  #  * Any strings in the array are treated as text to be reported,
  #    one *per* line.  Each line will begin with the value of
  #    logger's value of {#prefix} (or any overriding value set with
  #    `:prefix` in a hash of options), and only the final line is
  #    subject to the {DumbLogger::NO_NL} special-casing.
  #
  # @note
  #  Use of the `:return` hash option is deprecated in versions after
  #  1.0.0.  Use `:newline` instead.
  #
  # @return [nil,Integer]
  #  Returns either `nil` if the message's loglevel is higher than the
  #  reporting level, or the level of the report.
  #
  #  If integer levels are being used, a non-`nil` return value is
  #  that of the message.  If bitmask levels are being used, the
  #  return value is a mask of the active level bits that applied to
  #  the message -- *i.e.*, `message_mask & logging_mask` .
  #
  def message(*args)
    #
    # Extract any symbols, hashes, and integers from the argument
    # list.  This makes the calling format very flexible.
    #
    (symopts, args)	= args.partition { |elt| elt.kind_of?(Symbol) }
    #
    # Pull out any symbols that are actually names for levels (or
    # masks).  The args variable now contains no Symbol elements.
    #
    symlevels		= (symopts & self.labeled_levels.keys).map { |o|
      self.labeled_levels[o]
    }.compact
    #
    # Now any option hashes.
    #
    (hashopts, args)	= args.partition { |elt| elt.kind_of?(Hash) }
    hashopts		= hashopts.reduce(:merge) || {}
    #
    # All hashes have been removed from the args array, and merged
    # together into a single *per*-message options hash.
    #

    #
    # Now some fun stuff.  The appropriate loglevel/mask for this
    # message can come from
    #
    # * Integers in the argument array (last one takes precedence); or
    # * Values of symbolic level/mask labels (again, last one takes
    #   precedence, and overrides any explicit integers); or
    # * Any `:level` or `:mask` value in the options hash (which one
    #   of those takes precedence depends on the current logging
    #   style).
    #
    (lvls, args)	= args.partition { |elt| elt.kind_of?(Integer) }
    if (self.log_levels?)
      level		= hashopts[:level] || hashopts[:mask]
    else
      level		= hashopts[:mask] || hashopts[:level]
    end
    if (level.nil?)
      if (self.log_levels?)
        level		= symlevels.empty? ? lvls.last : symlevels.min
      else
        level		= symlevels.empty? ? lvls.last : symlevels.reduce(:|)
      end
    end
    level		||= 0
    #
    # We should now have a minimum logging level, or an ORed bitmask,
    # in variable 'level'.  Time to see if it meets our criteria.
    #
    unless (level.zero?)
      if (self.log_levels?)
        return nil if (self.loglevel < level)
      elsif (self.log_masks?)
        level &=  self.logmask
        return nil if (level.zero?)
      end
    end
    #
    # Looks like the request loglevel/mask is within the logger's
    # requirements, so let's build the output string.
    #
    prefix_text		= hashopts[:prefix] || self.prefix
    text		= prefix_text + args.join("\n#{prefix_text}")
    #
    # The :return option is overridden by :newline, and renamed to it
    # if :newline isn't already in the options hash.
    #
    if (hashopts.key?(:return) && (! hashopts.key?(:newline)))
      hashopts[:newline] = hashopts[:return]
      hashopts.delete(:return)
    end
    unless (hashopts.key?(:newline))
      hashopts[:newline]= (! symopts.include?(NO_NL))
    end
    text << "\n" if (hashopts[:newline])
    #
    # Okey.  If the output stream is marked 'volatile', it's one of
    # our special sinks and we need to evaluate it on every write.
    #
    stream = self.volatile ? eval(self.sink.to_s) : @sink_io
    #
    # If this is our first write to this sink, or we're in {#append}
    # mode and always supposed to seek to the EOF,, make sure we
    # position properly before writing!
    #
    if ((self.first_write? || self.seek_to_eof?) \
        && stream.respond_to?(:seek))
      poz	= (self.append? \
                   ? IO::SEEK_END \
                   : IO::SEEK_SET)
      begin
        #
        # Can't seek on some things, so just catch the exception and
        # ignore it.
        #
        stream.seek(0, poz)
      rescue Errno::ESPIPE => exc
        #
        # Do nothing..
        #
      end
    end
    stream.write(text)
    stream.flush if (self.volatile?)
    self.first_write = false
    #
    # All done!  Return the level, or mask bits, that resulted in the
    # text being transmitted.
    #
    return level
  end                           # def message

end                             # class DumbLogger
