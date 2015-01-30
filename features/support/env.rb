Proc.new {
  libdir = File.expand_path(File.join(__FILE__, '..', '..', '..', 'lib'))
  $:.replace($: | [ libdir ])
}.call
require('dumb-logger')
require('aruba/cucumber')
