# frozen_string_literal: true

require 'bundler/setup'
Bundler.require(:default)

require 'yaml'
require 'rack/test'

require_relative 'config/initializers/lobanov_initializer'
require_relative 'api/v2/todo_api'
