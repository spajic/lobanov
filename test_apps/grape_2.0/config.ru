# frozen_string_literal: true

require 'boot'
require 'rack_application'

run RackApplication.to_app
