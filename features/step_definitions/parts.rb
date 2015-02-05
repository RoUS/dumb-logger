Given(/^I have a DumbLogger object$/) do
  @duml					= DumbLogger.new
end

And(/^it is sinking to (\S+)$/) do |sink|
  @return_value = @duml.sink		= eval(sink)
end

And(/^the logging style is (\S+)$/) do |style|
  @return_value = @duml.level_style	= DumbLogger.const_get(style)
end

And(/^append mode is set to (\S+)$/) do |mode|
  @return_value = @duml.append			= eval(mode)
end

And(/^the prefix is set to "([^"]*)"$/) do |prefix|
  @return_value = @duml.prefix			= prefix
end

And(/^the loglevel is set to (\S+)$/) do |level|
  @return_value = @duml.loglevel		= level.to_i
end

And(/^I label (?:level|mask|bitmask) (\d+) with name "(.+)"$/) do |level,label|
  @return_value = @duml.label_levels(eval("{#{label.to_sym.inspect}=>#{level}}"))
end

And(/^I label loglevels with:$/) do |labelhash|
  @return_value = @duml.label_levels(eval("{#{labelhash}}"))
end

And(/^I invoke the logger with (\S*)\((.*)\)$/) do |label,args|
  traffic = capture_streams(:$stdout, :$stderr) {
    invocation = "@duml.#{label.empty? ? 'message' : label}(#{args})"
    @return_value = eval(invocation)
  }
  @stdout_text = traffic[:$stdout]
  @stderr_text = traffic[:$stderr]
end

Then(/^stdout should contain exactly (.+)$/) do |xval|
  expect(@stdout_text).to eq eval(xval)
end

Then(/^stdout should contain exactly:$/) do |xval|
  expect(@stdout_text).to eq xval
end

Then(/^stderr should contain exactly (.+)$/) do |xval|
  expect(@stderr_text).to eq eval(xval)
end

Then(/^stderr should contain exactly:$/) do |xval|
  expect(@stderr_text).to eq xval
end

Then(/^the return value should be (.*)$/) do |xval|
  expect(@return_value).to eq eval(xval)
end

Then(/^the (?:log-level|logging-mask) should\s+(?:still)?\s*be (\d+)$/) do |xval|
  expect(@duml.loglevel).to eq xval.to_i
end

Then(/^the sink should be (.+)$/) do |xval|
  expect(@duml.sink).to eq eval(xval)
end

Then(/^the style should be (.+)$/) do |xval|
  expect(@duml.level_style).to eq eval(xval)
end

Then(/^the prefix should be (.+)$/) do |xval|
  expect(@duml.prefix).to eq eval(xval)
end

Then(/^append-mode should be (.+)$/) do |xval|
  expect(@duml.append?).to eq eval(xval)
end

When(/^I query (?:attribute|method) ["']?([_A-Za-z0-9?]+)["']?$/) do |attr|
  @return_value = @duml.send(attr.to_sym)
end

When(/^I set (?:attribute|the)?\s*["']?([_A-Za-z0-9]+)["']? to (.+?)$/) do |attr,val|
  begin
    @return_value = @duml.send((attr + '=').to_sym, eval(val))
  rescue Exception => e
    @exception_raised	= e
    @return_value	= nil
  end
end

Then(/^it should raise an exception of type (\S+)$/) do |xval|
  expect(@exception_raised.class).to eq eval(xval)
end
