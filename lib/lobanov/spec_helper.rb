# frozen_string_literal: true

# Tie to RSpec
module Lobanov
  module SpecHelper
    # We override the method from ActionController::TestRequest
    # action_controller/test_case.rb (this is for controller specs)
    # def process(action,
    #   method: "GET", params: nil, session: nil, body: nil, flash: {}, format: nil, xhr: false, as: nil
    # )
    # And there is another method (for request specs)
    # def process(method, path, params: nil, headers: nil, env: nil, xhr: false, as: nil)
    # This is in lib/action_dispatch/testing/integration.rb
    module RailsControllerSpec
      extend ActiveSupport::Concern

      # We need to override method defined in
      # class TestCase
      #   module Behavior
      #     module ClassMethods
      module ClassMethods
        module LobanovBehavior
          def process(action, **keywords)
            super(action, **keywords).tap do
              if Lobanov::Spy.enabled?
                Lobanov::Spy
                  .current
                  .add_interaction_by_action_dispatch(@request, @response)
              end
            end
          end
        end

        def new(*)
          super.extend(LobanovBehavior)
        end
      end
    end

    module RailsRequestSpec
      def process(method, path, **keywords)
        super(method, path, **keywords).tap do
          if Lobanov::Spy.enabled?
            Lobanov::Spy
              .current
              .add_interaction_by_action_dispatch(@request, @response)
          end
        end
      end
    end

    module RackRequestSpec
      def process_request(uri, env)
        super(uri, env).tap do
          if Lobanov::Spy.enabled?
            Lobanov::Spy
              .current
              .add_interaction_by_action_dispatch(last_request, last_response)
          end
        end
      end
    end
  end
end

if defined? Rails
  if defined?(ActionController::TestCase::Behavior)
    ActionController::TestCase::Behavior.include Lobanov::SpecHelper::RailsControllerSpec
  end

  if defined?(ActionDispatch::Integration::Session)
    ActionDispatch::Integration::Session.prepend Lobanov::SpecHelper::RailsRequestSpec
  end
elsif defined?(Grape)
  ::Rack::Test::Session.prepend Lobanov::SpecHelper::RackRequestSpec
end

if defined?(RSpec)
  RSpec.configure do |config|
    config.around(:each, :lobanov) do |ex|
      Lobanov.capture(&ex)
    end

    config.around(:each, :lobanov!) do |ex|
      Lobanov.capture!(&ex)
    end
  end
end
