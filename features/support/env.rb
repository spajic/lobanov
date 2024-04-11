# frozen_string_literal: true

require 'aruba/cucumber'

test_app =  ARGV.dup.last.sub('@', '')
example_path = File.expand_path("../../test_apps/#{test_app}", __dir__)

require "#{example_path}/config/environment"

Aruba.configure do |config|
end
