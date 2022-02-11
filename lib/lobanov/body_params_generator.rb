# frozen_string_literal: true

module Lobanov
  class BodyParamsGenerator
    def self.call(payload)
      {
        'required' => true,
        'content' => {
          'application/json' => {
            'schema' => SchemaByObject.call(payload)
          }
        }
      }
    end
  end
end
