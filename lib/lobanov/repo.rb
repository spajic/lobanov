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

    def api_marker
      @api_marker ||= generator.api_marker
    end

    def index_path
      "#{Lobanov.specification_folder}/#{index_path_marker}/index.yaml"
    end

    def index_path_marker
      if api_marker == 'wapi'
        'wapi'
      else
        version_number = api_marker.last
        "private/v#{version_number}"
      end
    end

    def store_schema
      path_schema = generator.path_schema
      path_schema = extract_component_schema_to_file(path_schema)
      path_schema = extract_request_body_to_file(path_schema) if status.to_i < 400

      update_index(path_schema)
    end

    def store_new_tags
      index = find_index 
      node = index.dig('paths', path_with_curly_braces, verb)
      node['tags'] |= GenerateInteractionTags.call(interaction)
      File.write(index_path, index.to_yaml)
    end

    def extract_component_schema_to_file(path_schema)
      extracted_schema =
        path_schema.dig(verb, 'responses', status, 'content', 'application/json', 'schema')
      return path_schema unless extracted_schema

      write("#{components_base}/responses/#{response_component_name}", extracted_schema)

      path_schema[verb]['responses'][status]['content']['application/json']['schema'] =
        { '$ref' => ref_to_component_file }

      path_schema
    end

    def ref_to_component_file
      "./components/responses/#{response_component_name}.yaml"
    end

    def extract_request_body_to_file(path_schema)
      extracted_body =
        path_schema.dig(verb, 'requestBody', 'content', 'application/json', 'schema')
      return path_schema if extracted_body.nil?

      write("#{bodies_base}/#{generator.request_body_name}", extracted_body)

      path_schema[verb]['requestBody']['content']['application/json']['schema'] =
        { '$ref' => ref_to_request_body_file }

      path_schema
    end

    def ref_to_request_body_file
      "./components/requestBodies/#{generator.request_body_name}.yaml"
    end

    def update_index(path_schema)
      index = find_index

      append_to_path!(index, path_with_curly_braces, path_schema)

      File.write(index_path, index.to_yaml)
    end

    private

    def folder
      Lobanov.specification_folder
    end

    def components_base
      [folder, 'components'].join('/')
    end

    def paths_base
      [folder, 'paths'].join('/')
    end

    def bodies_base
      [components_base, 'requestBodies'].join('/')
    end

    def write(path, object)
      full_path = "#{path}.yaml"
      ensure_file_exists(full_path)
      File.write full_path, YAML.dump(object)
    end

    def append_to_path!(index, _path, object)
      content = index['paths'][path_with_curly_braces]

      # Если ответ с ошибкой, не обновляем parameters и requestBody, там что-то не то
      if status.to_i >= 400
        object[verb].delete('parameters')
        object[verb].delete('requestBody')
      end

      merged = process_content(content, object)

      index['paths'][path_with_curly_braces] = merged
    end

    def process_content(content, object)
      return object if content.nil?

      return content.merge(object) unless content[verb]

      merge_response(content, object)
    end

    def merge_response(content, object)
      content[verb]['responses'].merge!(object[verb]['responses'])
      content[verb]['parameters'] = object[verb]['parameters'] if object[verb]['parameters']
      content
    end

    def read(path)
      YAML.load_file("#{path}.yaml")
    end

    def ensure_file_exists(path)
      dirname = File.dirname(path)
      FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
      File.write(path, '---') unless File.exist?(path)
    end

    def find_index
      begin
        YAML.load_file(index_path)
      rescue Errno::ENOENT
        # If new api version was created at first lobanov iteration we don't have index file
        initialize_index_sample
      end
    end

    def initialize_index_sample
      {
        'paths' => {
          path_with_curly_braces => {}
        }
      }
    end

    def components_base
      if api_marker == 'wapi'
        "#{Lobanov.specification_folder}/#{api_marker}/components"
      else
        version_number = api_marker.last
        "#{Lobanov.specification_folder}/private/v#{version_number}/components"
      end
    end

    def bodies_base
      "#{components_base}/requestBodies"
    end
  end
end
