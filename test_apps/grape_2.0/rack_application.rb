# frozen_string_literal: true

require_relative 'boot'

module RackApplication
  def self.to_app
    return @rack_application if defined? @rack_application

    builder = Rack::Builder.new
    builder.run(API::V2::TodoApi.new)

    @rack_application = builder
  end
end
