# frozen_string_literal: true

require 'forwardable'

module Lobanov
  # Ответственность Repo - сохранять и загружать схему, подготовленную Generator
  # Самый простой вариант - сохранять просто всю схему в файл по соответствующему пути
  # Но у нас уже была схема хранения по частям в api-backend-specification - реализуем её
  # При сохранении раскладываем схему в components и paths и добавляем в index
  # При загрузке собираем из тех же кусочков обратно
  class Repo
    extend Forwardable

    COMPONENTS_BASE = 'frontend/api-backend-specification/components'
    PATHS_BASE = 'frontend/api-backend-specification/paths'
    BODIES_BASE = "#{COMPONENTS_BASE}/requestBodies"
    INDEX_BASE = 'frontend/api-backend-specification'
    INDEX_PATH = "#{INDEX_BASE}/index.yaml"

    attr_reader :interaction

    def_delegator :generator, :response_component_name
    def_delegator :generator, :path_with_square_braces
    def_delegator :generator, :path_with_curly_braces

    def initialize(interaction:)
      @interaction = interaction
    end

    def generator
      @generator ||= Generator.new(interaction: interaction)
    end

    def verb
      @verb ||= generator.verb.downcase
    end

    def status
      @status ||= generator.status.to_s
    end

    def store_schema
      path_schema = generator.path_schema
      path_schema = extract_component_schema_to_file(path_schema)
      path_schema = extract_request_body_to_file(path_schema) if status.to_i < 400

      # write_append(PATHS_BASE + store_path_name, path_schema)
      update_index(path_schema)
    end

    def extract_component_schema_to_file(path_schema)
      extracted_schema =
        path_schema.dig(verb, 'responses', status, 'content', 'application/json', 'schema')
      return path_schema unless extracted_schema

      write(COMPONENTS_BASE + '/responses/' + response_component_name, extracted_schema)

      path_schema[verb]['responses'][status]['content']['application/json']['schema'] =
        {'$ref' => ref_to_component_definition}

      path_schema
    end

    def ref_to_component_definition
      "#/components/responses/#{response_component_name}"
    end

    def ref_to_component_file
      "./components/responses/#{response_component_name}.yaml"
    end

    def extract_request_body_to_file(path_schema)
      extracted_body =
        path_schema.dig(verb, 'requestBody', 'content', 'application/json', 'schema')
      return path_schema if extracted_body.nil?

      write(BODIES_BASE + '/'  + generator.request_body_name, extracted_body)

      path_schema[verb]['requestBody']['content']['application/json']['schema'] =
        {'$ref' => ref_to_request_body_definition}

      path_schema
    end

    def ref_to_request_body_file
      "./components/requestBodies/#{generator.request_body_name}.yaml"
    end

    def ref_to_request_body_definition
      "#/components/requestBodies/#{generator.request_body_name}"
    end

    def store_path_name
      path_with_square_braces + '/' + 'path'
    end

    def nesting_depth
      @nesting_depth ||= store_path_name.count('/')
    end

    def load_schema
      # начинаем c api-backend-specification/index.yaml и проходим по ссылкам
      index = YAML.load_file(INDEX_PATH)
      path_index = index.dig('paths', store_path_name)
      return nil unless path_index

      path_schema = read_relative(path_index['$ref'])

      component_index = index['components']['responses'][response_component_name]
      component_schema = read_relative(component_index['$ref'])

      path_schema[verb]['responses'][status.to_s]['content']['application/json']['schema'] = component_schema

      {
        'paths' => {
          generator.path_with_curly_braces => path_schema
        }
      }
    end

    def update_index(path_schema)
      index = YAML.load_file(INDEX_PATH)

      append_to_path!(index, path_with_curly_braces, path_schema)

      index['components']['responses'][response_component_name] = {
        '$ref' => ref_to_component_file
      }

      if path_schema[verb]['requestBody']
        index['components']['requestBodies'][generator.request_body_name] = {
          '$ref' => ref_to_request_body_file
        }
      end

      File.write(INDEX_PATH, index.to_yaml)
    end

    private

    def write(path, object)
      full_path = "#{path}.yaml"
      ensure_file_exists(full_path)
      File.write full_path, YAML.dump(object)
    end

    def append_to_path!(index, path, object)
      content = index['paths'][path_with_curly_braces]

      # Если ответ с ошибкой, не обновляем parameters и requestBody, там что-то не то
      if status.to_i >= 400
        object[verb].delete('parameters')
        object[verb].delete('requestBody')
      end

      merged =
        if content.nil?
          object
        elsif content[verb] # если уже было что-то для этого пути и этого HTTP-метода
          content[verb]['responses'].merge!(object[verb]['responses'])
          if object[verb]['parameters']
            content[verb]['parameters'] = object[verb]['parameters']
          end
          content
        else
          content.merge(object)
        end

      index['paths'][path_with_curly_braces] = merged
    end

    def read_relative(relative_path)
      full_path = "#{INDEX_BASE}/#{relative_path}"
      YAML.load_file(full_path)
    end

    def read(path)
      YAML.load_file("#{path}.yaml")
    end

    def ensure_file_exists(path)
      dirname = File.dirname(path)
      FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
      File.write(path, '---') unless File.exist?(path)
    end
  end
end
