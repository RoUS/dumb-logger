Given(%r!^I run system\("([^"]+)"\)$!) do |xval|
  wrap_exception do
    system(xval)
  end
end

