Given(/^I have a DumbLogger object$/) do
  @duml			= DumbLogger.new
end

Given(/^I create a DumbLogger object using\s+(.*)$/) do |xval|
  wrap_exception do
    @duml		= DumbLogger.new(eval(xval))
  end
  @duml			= @return_value
end

Given(/^I create a DumbLogger object using:$/) do |xval|
  wrap_exception do
    @duml		= DumbLogger.new(eval(xval))
  end
end

And(/^it is sinking to (\S+)$/) do |sink|
  wrap_exception do
    @duml.sink		= eval(sink)
  end
end

And(/^the logging style is (\S+)$/) do |style|
  wrap_exception do
    @duml.level_style	= DumbLogger.const_get(style)
  end
end

And(/^append mode is set to (\S+)$/) do |mode|
  wrap_exception do
    @duml.append	= eval(mode)
  end
end

And(/^the prefix is set to "([^"]*)"$/) do |prefix|
  wrap_exception do
    @duml.prefix	= prefix
  end
end

And(/^the loglevel is set to (\S+)$/) do |level|
  wrap_exception do
    @duml.loglevel	= level.to_i
  end
end

And(/^I label (?:level|mask|bitmask) ((?:0d)?\d+|0x[[:xdigit:]]+|0b[01]+) with name "(.+)"$/) do |level,label|
  wrap_exception do
    @duml.label_levels(eval("{#{label.to_sym.inspect}=>#{level}}"))
  end
end

And(/^I label loglevels with:$/) do |labelhash|
  wrap_exception do
    @duml.label_levels(eval("{#{labelhash}}"))
  end
end

And(/^I label loglevels with\s+(.*[^:])$/) do |labelhash|
  wrap_exception do
    @duml.label_levels(eval("#{labelhash}"))
  end
end

And(/^I invoke the logger with (\S*)\((.*)\)$/) do |label,args|
  wrap_exception do
    traffic		= capture_streams(:$stdout, :$stderr) {
      invocation	= "@duml.#{label.empty? ? 'message' : label}(#{args})"
      @return_value	= eval(invocation)
    }
    @stdout_text	= traffic[:$stdout]
    @stderr_text	= traffic[:$stderr]
    @return_value
  end
end

Then(/^stdout should contain exactly (.+)$/) do |xval|
  expect(@stdout_text).to eq(eval(xval))
end

Then(/^stdout should contain exactly:$/) do |xval|
  expect(@stdout_text).to eq(xval)
end

Then(/^stderr should contain exactly (.+)$/) do |xval|
  expect(@stderr_text).to eq(eval(xval))
end

Then(/^stderr should contain exactly:$/) do |xval|
  expect(@stderr_text).to eq(xval)
end

Then(/^the return value should be (.*)$/) do |xval|
  expect(@return_value).to eq(eval(xval))
end

Then(/^the return value should be:$/) do |xval|
  expect(@return_value).to eq(eval(xval))
end

Then(/^the return value should include ['"]?(.*)['"]?$/) do |xval|
  expect(@return_value).to match(%r!#{xval}!)
end

Then(/^the return value should not include ['"]?(.*)['"]?$/) do |xval|
  expect(@return_value).not_to match(%r!#{xval}!)
end

Then(/^the (?:log-level|logging-mask) should\s+(?:still)?\s*be ((?:0d)?\d+|0x[[:xdigit:]]+|0b[01]+)$/) do |xval|
  expect(@duml.loglevel).to eq(xval.to_i)
end

Then(/^the loglevel should be (.+)$/) do |xval|
  expect(@duml.loglevel).to eq(eval(xval))
end

Then(/^the logmask should be (.+)$/) do |xval|
  expect(@duml.logmask).to eq(eval(xval))
end

Then(/^the sink should be (.+)$/) do |xval|
  expect(@duml.sink).to eq(eval(xval))
end

Then(/^the style should be (.+)$/) do |xval|
  expect(@duml.level_style).to eq(eval(xval))
end

Then(/^the prefix should be (.+)$/) do |xval|
  expect(@duml.prefix).to eq(eval(xval))
end

Then(/^append-mode should be (.+)$/) do |xval|
  expect(@duml.append?).to eq(eval(xval))
end

When(/^I query (?:attribute|method) ["']?([_A-Za-z0-9?]+)["']?$/) do |attr|
  wrap_exception do
    @duml.send(attr.to_sym)
  end
end

When(/^I set (?:attribute|the)?\s*["']?([_A-Za-z0-9]+)["']? to (.+?)$/) do |attr,val|
  wrap_exception do
    @duml.send((attr. + '=').to_sym, eval(val))
  end
end

Then(/^it should raise an exception of type (\S+)$/) do |xval|
  expect(@exception_raised.class).to eq(eval(xval))
end
