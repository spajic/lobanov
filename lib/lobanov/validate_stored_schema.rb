# frozen_string_literal: true

module Lobanov
  # Validates stored_schema and returns validation error for particular conditions
  # Schemas are ruby objects representing OpenApi3 schema
  class ValidateStoredSchema
    attr_reader :stored_schema, :operation_id

    def self.call(...)
      new(...).call
    end

    def initialize(stored_schema:, operation_id:)
      @stored_schema = stored_schema
      @operation_id = operation_id
    end

    def call
      missing_type_paths = []
      missing_example_paths = []

      Visitor.visit(stored_schema).each do |node|
        path = node[:path]
        value = node[:value]
        # Может быть пустой объект в корне (пустой ответ render json: {})
        next if path == ['properties'] && value == {}

        # у object не должно быть example, примеры внутри properties
        if value['type'] == 'object'
          next
        end

        if value['type'].nil?
          missing_type_paths << path.join('->')
        end

        if value['type'] != 'array' && value['example'].nil?
          missing_example_paths << path.join('->')
        end
      rescue StandardError => e
        raise e.class, "#{path.join('\\')}: #{e.message}", e.backtrace
      end

      raise_error(missing_type_paths, missing_example_paths)
    end

    private

    def raise_error(missing_type_paths, missing_example_paths)
      return if [missing_type_paths, missing_example_paths].all?(&:empty?)

      error = {
        operation_id: operation_id,
        missing_types: missing_type_paths,
        missing_examples: missing_example_paths
      }

      exception = MissingTypeOrExampleError.new(format_error(error))
      exception.set_backtrace(['(ノಠ益ಠ)ノ彡┻━┻'])
      raise exception
    end

    def format_error(error)
      res = +"Problem with #{error[:operation_id]}\n"
      res += format_errors_paths('Missing types', error[:missing_types])
      res += format_errors_paths('Missing examples', error[:missing_examples])

      res.gsub!('->properties->', '->')

      res
    end

    def format_errors_paths(category, paths)
      return '' if paths&.empty?

      res = +''
      res << "\n#{category}:\n"
      paths.each { |path| res += "#{path}\n" }
      res
    end
  end
end
