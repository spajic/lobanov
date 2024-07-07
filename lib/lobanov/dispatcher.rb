# frozen_string_literal: true

module Lobanov
  class Dispatcher
    def self.build
      if defined?(Rails)
        ::Lobanov::Dispatchers::RailsDispatcher
      elsif defined?(Grape)
        ::Lobanov::Dispatchers::GrapeDispatcher
      end
    end
  end
end
