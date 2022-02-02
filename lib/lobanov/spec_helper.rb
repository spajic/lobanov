# frozen_string_literal: true

# Tie to RSpec
module Lobanov
  module SpecHelper
    module Rails
      extend ActiveSupport::Concern

      module ClassMethods
        module LobanovSession
          def process(*)
            super.tap do
              if Lobanov::Spy.enabled?
                Lobanov::Spy
                  .current
                  .add_interaction_by_action_dispatch(@request, @response)
              end
            end
          end
        end

        def new(*)
          super.extend(LobanovSession)
        end
      end
    end
  end
end

if defined?(ActionDispatch::Integration::Session)
  ActionDispatch::Integration::Session.include Lobanov::SpecHelper::Rails
end

if defined?(ActionController::TestCase::Behavior)
  ActionController::TestCase::Behavior.include Lobanov::SpecHelper::Rails
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
