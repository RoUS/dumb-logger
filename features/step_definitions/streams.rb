Then(%r!^stdout should match this string\s(.+)$!) do |xval|
  expect(@stdout_text).to eq(eval(xval))
end

Then(%r!^stdout should match this string:$!m) do |xval|
  expect(@stdout_text).to eq(xval)
end

Then(%r!^stderr should match this string\s(.+)$!) do |xval|
  expect(@stderr_text).to eq(eval(xval))
end

Then(%r!^stderr should match this string:$!m) do |xval|
  expect(@stderr_text).to eq(xval)
end

