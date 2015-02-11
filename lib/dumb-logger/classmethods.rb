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

class DumbLogger

  #
  # class DumbLogger eigenclass.
  #
  # Since we may have had to open up a file, make sure closing it
  # again is part of the instance teardown process.
  #
  class << self
    #
    # If we have a currently open output stream that needs to be
    # closed (usually because we opened it ourself), close it as part
    # of the DumbLogger object teardown.
    #
    # @param [DumbLogger] obj
    #  Instance being torn down ('destructed').
    #
    def finalize(obj)
      if (obj.needs_close?)
        obj.instance_variable_get(:@sink_io).close
      end
    end                         # def finalize

    #
    # Instance method builder (like :attr_accessor) for Boolean flags.
    # Defines a reader (`name`), writer (`name=`), and query (`name?`)
    # method for each flag name in the list.
    #
    # @param [Symbol] hashivar
    #  Symbolic name for the instance variable that the flag names
    #  index.
    #
    # @param [Array<Symbol,String>] args
    #  One or more flag identifiers for which `<flag>`, `<flag>=`, and
    #  `<flag>?` methods should be created.
    #
    # @return [Array<Symbol>]
    #  Returns an array of the symbolic names of the accessor methods
    #  created.
    #
    # @example
    #  self.flag_field(:@options, :flag1, :flag2)
    #
    def flag_field(hashivar, *args)
      fmethods	= []
      args = args.map { |o| o.to_s }
      args.each do |mname|
        #
        # `define_method` takes a block, which is a closure, so let's
        # set variables to values we want valid inside the closures.
        #
        hash_key	= mname.to_sym
        reader_method	= mname.to_sym
        writer_method	= (mname + '=').to_sym
        tester_method	= (mname + '?').to_sym
        fmethods	|= [ reader_method, writer_method, tester_method, ]
        #
        # The flag reader method has the same name as the flag itself
        # (which is a key in the specified hash).
        #
        define_method(reader_method) do
          return (instance_variable_get(hashivar)[hash_key] ? true : false)
        end
        #
        # Now define the set-the-flag method.  We need to use the
        # `self.send` mechanism because `self` at this point refers to
        # the proc, and we need it to be evaluated at run-time, when
        # it will refer to the logger instance.
        #
        define_method(writer_method) do |val|
          instance_variable_get(hashivar)[hash_key] = (val ? true : false)
          return eval("self.send(#{reader_method.inspect})")
        end
        #
        # And finally, the 'is-this-set?' query method, which is
        # virtually identical to the reader method.
        #
        define_method(tester_method) do
          return eval("self.send(#{reader_method.inspect})")
        end
      end
    end                         # def flag_field
    protected(:flag_field)

    #
    # Declare flag accessors for internal use only.  See {#flag_field}.
    #
    # @param [Array<Symbol,String>] args
    #  List of flags for which private accessors will be declared.
    #
    # @return (see #flag_field)
    #
    # @example
    #  private_flag(:needs_close, :needs_seek)
    #
    def private_flag(*args)
      fmethods	= self.flag_field(:@controls, *args)
      protected(*fmethods)
    end                         # def private_flag
    protected(:private_flag)

    #
    # Declare flag accessors for public instance variables.  See
    # {#flag_field}.
    #
    # @param [Array<Symbol,String>] args
    #  List of flags for which publicaccessors will be declared.
    #
    # @return (see #flag_field)
    #
    # @example
    #  public_flag(:append, :seek_to_eof)
    #
    def public_flag(*args)
      fmethods	= self.flag_field(:@options, *args)
      public(*fmethods)
    end                         # def private_flag
    protected(:public_flag)

  end                           # class DumbLogger eigenclass

end                             # class DumbLogger
