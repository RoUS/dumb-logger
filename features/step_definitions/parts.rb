Given /^I have a DumbLogger object$/ do
  @duml					= DumbLogger.new
end

And /^it is sinking to (\S+)$/ do |sink|
  @return_value = @duml.sink		= eval(sink)
end

And /^the logging style is (\S+)$/ do |style|
  @return_value = @duml.level_style	= DumbLogger.const_get(style)
end

And /^append mode is set to (\S+)$/ do |mode|
  @return_value = @duml.append			= eval(mode)
end

And /^the prefix is set to "([^"]*)"$/ do |prefix|
  @return_value = @duml.prefix			= prefix
end

And /^the loglevel is set to (\d+)$/ do |level|
  @return_value = @duml.loglevel		= level.to_i
end

And /^I invoke the logger with \((.*)\)$/ do |args|
  @return_value = eval("@duml.message(#{args})")
end

Then /^the return value should be (.*)$/ do |expected_val|
  expect(@return_value).to eq eval(expected_val)
end

Then /^the (?:log-level|logging-mask) should\s+(?:still)?\s*be (\d+)$/ do |expected_val|
  expect(@duml.loglevel).to eq expected_val.to_i
end

Then /^the sink should be (.+)$/ do |expected_val|
  expect(@duml.sink).to eq eval(expected_val)
end

Then /^the style should be (.+)$/ do |expected_val|
  expect(@duml.level_style).to eq eval(expected_val)
end

Then /^the prefix should be (.+)$/ do |expected_val|
  expect(@duml.prefix).to eq eval(expected_val)
end

Then /^append-mode should be (.+)$/ do |expected_val|
  expect(@duml.append?).to eq eval(expected_val)
end

When /^I query attribute ["']?([_A-Za-z0-9?]+)["']?$/ do |attr|
  @return_value = @duml.send(attr.to_sym)
end

When /^I set attribute ["']?([_A-Za-z0-9]+)["']? to (.+?)$/ do |attr,val|
  begin
    @return_value = @duml.send((attr + '=').to_sym, eval(val))
  rescue Exception => e
    @exception_raised	= e
    @return_value	= nil
  end
end

Then /^it should raise an exception of type (\S+)$/ do |expected_val|
  expect(@exception_raised.class).to eq eval(expected_val)
end
