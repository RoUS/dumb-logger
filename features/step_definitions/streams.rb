Then(%r!^stdout should contain exactly (.+)$!) do |xval|
  expect(@stdout_text).to eq(eval(xval))
end

Then(%r!^stdout should contain exactly:$!) do |xval|
  expect(@stdout_text).to eq(xval)
end

Then(%r!^stderr should contain exactly (.+)$!) do |xval|
  expect(@stderr_text).to eq(eval(xval))
end

Then(%r!^stderr should contain exactly:$!) do |xval|
  expect(@stderr_text).to eq(xval)
end

