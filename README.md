# DumbLogger

*As though there weren't enough Ruby gems for logging.. here's another one!*

`DumbLogger` is a very simple package for logging messages, typically
for command-line applications.  You simply instantiate the class, set
the maximum log-level required for messages to be displayed, and
subsequently invoke the `#message` method with the text and
appropriate level associated with it.  If the logger's maximum level
is greater than or equal to the message's, the text will be written to
the logging sink.

Alternatively, you can instead treat logging levels as bitmasks
(_e.g._, "bit 3 means log network activity"), and messages will be
sent to the logging sink if any of the set bits in their mask are also
set in the logger's mask.

Messages with a loglevel (or mask) of +0+ **always** get written to
the sink.

By default, `DumbLogger` uses a sink of `$stderr`, but you can tell it
to write messages somewhere else.  If the sink is a file that needs to
be opened, by default new text will be appended to any existing
content, but you can cause it to rewind and truncate the file before
writing.  If you change sinks and the current one was opened as a
file, it will be closed before switching to the new sink.

Sinks can be either filenames or streams (instances of `IO`);
append-mode doesn't apply to streams.

Text is logged using the `#message` method, which takes an arbitrary
number of strings, symbols, integers, and hashes as arguments.

* The last integer in the argument list will be used as the message's
  level;
* Any hashes in the argument list will be merged and used as options;
  and
* If the argument contains multiple strings, each one will be written
  on a separate line.

Global options that can be set with #new include:

* whether files should be opened in append mode;
* whether loglevels are integers or bitmasks; 
* what the maximum logging level, or active logging bitmask, is;
* where messages should be sent (the sink); and
* a string that should be prefixed to each line written to the sink.

You can define names for logging level values, so you can use them in
subsequent calls.  In addition, defining a named level creates that
method on the instance tied to that level.  That is, these are
equivalent:

```
daml = DumbLogger.new(:names => { :info => 0, :debug => 4 })
daml.info('Level 0 message')
daml.debug('Level 4 message')

daml = DumbLogger.new
daml.message(0, 'Level 0 message')
daml.message(4, 'Level 4 message')
```

Options that can be set on a per-`#message` basis include:

* a prefix string specific to the message (temporarily overriding the
  default set at instantiation time); and
* whether the (last) line of the message should be terminated with a
  newline or not.  (Useful for multi-stage "`Doing foo: done`" type
  messages.) **Note:** This is done by either including `DumbLogger::NO_NL`
  in the argument list, or `{ :newline => false }` as part of an option
  hash.

## Installation

Add this line to your application's Gemfile:

```ruby
gem('dumb-logger')
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dumb-logger

## Usage

```ruby
require('dumb-logger')

#
# Create a logger with integer levels, a max level of 5, and
# everything else defaulted:
#
duml = DumbLogger.new(:loglevel => 5)

#
# Will not be written to the sink ($stderr):
#
duml.message(6, 'Silent message!')

#
# Will be written to the sink no matter what:
#
# => "Logger started!  Neener, neener!\n"
#
duml.message(0, 'Logger started!  Neener, neener!')

#
# Two lines will be logged with the prefix '[DEMO] ':
#
# => "[DEMO] This is line 1\n[DEMO] This is line 2\n"
#
# Note that the default loglevel is 0, which means 'always send'.
#
duml.message('This is line 1', { :prefix => '[DEMO] ' }, 'This is line 2')

#
# Two lines will be sent to the sink, but the second one will *not*
# end with a newline:
#
# => "This will destroy your life.\nAre you sure? "
#
duml.message(DumbLogger::NO_NL,
             'This will destroy your life',
             'Are you sure? ')
```

## Contributing

1. Fork it ( https://github.com/RoUS/dumb-logger/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Licence

`DumbLogger` is copyright © 2015 by Ken Coar, and is made available
under the terms of the Apache Licence 2.0:

```
   Copyright © 2015 Ken Coar

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
```
