# frozen_string_literal: true

module Lobanov
  module Configuration
    DEFAULT_SPECIFICATION_FOLDER = 'frontend/api-backend-specification'

    attr_accessor :specification_folder
    attr_accessor :namespaces # hash like {'v1' => 'private/v1', 'wapi' => 'wapi'}

    def configure
      yield self
    end

    def self.extended(base)
      base.set_default_configuration
    end

    def set_default_configuration
      self.specification_folder = DEFAULT_SPECIFICATION_FOLDER
      self.namespaces = {}
    end
  end
end
