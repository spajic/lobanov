# frozen_string_literal: true

module Lobanov
  module Configuration
    SPECIFICATION_FOLDER = 'frontend/api-backend-specification'

    attr_accessor :specification_folder

    def configure
      yield self
    end

    def self.extended(base)
      base.set_default_configuration
    end

    def set_default_configuration
      self.specification_folder = SPECIFICATION_FOLDER
    end
  end
end
