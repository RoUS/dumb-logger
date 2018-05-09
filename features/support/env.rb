Proc.new {
  libdir = File.expand_path(File.join(__FILE__, '..', '..', '..', 'lib'))
  $:.replace($: | [ libdir ])
}.call

#
# Must load and start simplecov before any application code
#
require('json')
require('versionomy')

if (Versionomy.ruby_version >= Versionomy.parse('1.9'))
  require('simplecov')
  SimpleCov.start do
    add_filter('/features/')
    add_filter('/libexec')
    add_filter('/lib/hll_active_record/')
    add_filter('/test/')
    add_filter('/tmp/')
  end
  SimpleCov.command_name(ARGV.join(' '))
end

require('dumb-logger')
require('aruba/cucumber')

if (Versionomy.ruby_version < Versionomy.parse('2.0.0'))
  require('ruby-debug')
else
  require('byebug')
end

# @private
#
# This module provides helper methods for the Cucumber testing suite.
#
module DumbLogger_TestSupport

  #
  # Suggested by from https://github.com/codegram/spinach
  #

  #
  # Provide helpers to wrap IO streams by temporarily redirecting them
  # to a StringIO object.
  #

  # @private
  #
  # Capture IO to one or more streams during block execution.
  #
  # @param [Array<Symbol,String>] stms
  #  One or more stream identifiers to be captured.  Symbols like `:$stderr`
  #  and strings like `"$stdout"` are acceptable.
  #
  # @yield
  #  Block for which stream traffic should be captured.
  #
  # @return [String,Hash<<String,Symbol>=>String>]
  #  If only one stream was specified, the result will be a simple string.
  #
  def capture_streams(*stms, &block)
    if (stms.any? { |o| (! (o.kind_of?(String) || o.kind_of?(Symbol))) })
      raise ArgumentError.new('streams must be strings or symbols')
    end
    ovalues	= stms.inject({}) { |memo,stm|
      stmname	= stm.to_s
      stmobj	= eval(stmname)
      unless (stmobj.kind_of?(IO))
        raise ArgumentError.new("'#{stm.inspect}' is not an IO object")
      end
      stat	= {
        :persistent	=> stmobj,
        :temporary	=> StringIO.new,
      }
      eval("#{stmname} = stat[:temporary]")
      memo[stm]		= stat
      memo
    }
    #
    # Make sure we restore the streams to their original settings if an
    # exception gets raised.  We don't care about the exception, just
    # making sure the streams are as they were when we were called.
    #
    rvalues		= stms.map { |o| {o => ''} }.reduce(:merge)
    begin
      yield
    ensure
      rvalues		= ovalues.inject({}) { |memo,(stm,stat)|
        eval("#{stm.to_s} = stat[:persistent]")
        memo[stm]		= stat[:temporary].string
        memo
      }
    end
    rvalues = rvalues.values.first if (rvalues.count == 1)
    return rvalues
  end                           # def capture_streams

  # @private
  #
  # Capture standard output activity as a string.
  #
  # @yield
  #  Block during the execution of which output is to be captured.
  #
  # @return [String]
  #  Returns whatever was sent to `$stdout` during the block's execution.
  #
  def capture_stdout(&block)
    return capture_stream(:$stdout, &block)
  end                           # def capture_stdout

  # @private
  #
  # Capture standard error activity as a string.
  #
  # @yield (see #capture_stdout)
  #
  # @return [String]
  #  Returns whatever was sent to `$stderr` during the block's execution.
  #
  # @see #capture_stdout
  # @see #capture_streams
  #
  def capture_stderr(&block)
    return capture_stream(:$stderr, &block)
  end                           # def capture_stderr

  #
  # Wrap the specified block in a rescue block so we can capture any
  # exceptions.
  #
  # @yield
  #
  # @return [nil,Object]
  #   Returns the exit value of the block (whatever it may be), or
  #   `nil` if an exception was caught.
  #
  def wrap_exception(&block)
    @exception_raised	= nil
    @return_value		= nil
    begin
      #
      # Do this in two steps in case the block itself puts something
      # in the @return_value ivar.
      #
      result		= block.call
      @return_value	||= result
    rescue Exception => exc
      @exception_raised	= exc
      @return_value	= nil
    end
    return @return_value
  end

end                             # module DumbLogger_TestSupport

include DumbLogger_TestSupport

def wrap_exception(&block)
  @exception_raised	= nil
  @return_value		= nil
  begin
    result		= block.call
    @return_value	||= result
  rescue Exception => exc
    @exception_raised	= exc
  end
end

