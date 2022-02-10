# frozen_string_literal: true

module Lobanov
  module Configuration
    attr_accessor(
      :namespaces_to_ignore
    )

    def configure
      yield self
    end

    def self.extended(base)
      base.set_default_configuration
    end

    def set_default_configuration
      self.namespaces_to_ignore = ['wapi']
    end
  end
end
