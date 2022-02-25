# frozen_string_literal: true

module Lobanov
  module Configuration
    attr_accessor(
      :namespaces_to_ignore,
      :specification_folder
    )

    def configure
      yield self
    end

    def self.extended(base)
      base.set_default_configuration
    end

    def set_default_configuration
      self.namespaces_to_ignore = ['wapi']
      self.specification_folder = 'frontend/api-backend-specification'
    end
  end
end
