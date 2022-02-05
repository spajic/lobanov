require 'aruba/cucumber'

example_path = File.expand_path('../../../test_apps/rails_61', __FILE__)
puts "⭐️⭐️⭐️#{example_path}"

# require 'rspec/expectations'
require "#{example_path}/config/environment"

Aruba.configure do |config|
end

