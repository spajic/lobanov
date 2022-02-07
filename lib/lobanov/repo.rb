# frozen_string_literal: true

module Lobanov
  # Ответственность Repo - сохранять и загружать схему, подготовленную Generator
  # Самый простой вариант - сохранять просто всю схему в файл по соответствующему пути
  # Но у нас уже была схема хранения по частям в api-backend-specification - реализуем её
  # При сохранении раскладываем схему в components и paths и добавляем в index
  # При загрузке собираем из тех же кусочков обратно
  class Repo
    SCHEMAS_PATH = 'spec/lobanov/schemas'
    COMPONENTS_BASE = 'frontend/api-backend-specification/components'
    PATHS_BASE = 'frontend/api-backend-specification/paths'
    INDEX_BASE = 'frontend/api-backend-specification'
    INDEX_PATH = "#{INDEX_BASE}/index.yaml"

    attr_reader :interaction

    delegate(
      :component_name,
      :path_name,
      :path_schema,
      :status,
      :verb,
      :component_schema,
      to: :generator
    )

    def initialize(interaction:)
      @interaction = interaction
    end

    def generator
      @generator ||= Generator.new(interaction: interaction)
    end

    def store_schema
      write("#{COMPONENTS_BASE}/#{component_name}", component_schema)
      write("#{PATHS_BASE}/#{path_name}", replace_component_schema_with_ref)
      update_index
    end

    def load_schema
      # начинаем c api-backend-specification/index.yaml и проходим по ссылкам
      index = YAML.load_file(INDEX_PATH)
      path_index = index.dig('paths', "/#{path_name}")
      return nil unless path_index

      path_schema = read_relative(path_index['$ref'])

      component_index = index['components']['schemas'][component_name_for_index]
      component_schema = read_relative(component_index['$ref'])

      path_schema[verb.downcase]['responses'][status.to_s]['content']['application/json']['schema'] = component_schema

      {
        'paths' => {
          generator.path_with_curly_braces => path_schema
        }
      }
    end

    def replace_component_schema_with_ref
      res = path_schema.dup
      content = res[verb.downcase]['responses'][status.to_s]['content']
      content['application/json']['schema'] = ref_to_component
      res
    end

    def update_index
      index = YAML.load_file(INDEX_PATH)

      index['paths']["/#{path_name}"] = {'$ref' => "./paths/#{path_name}.yaml"}

      index['components']['schemas'][component_name_for_index] = {
        '$ref' => "./components/#{component_name}.yaml"
      }

      File.write(INDEX_PATH, index.to_yaml)
    end

    def component_name_for_index
      component_name.split('/').last
    end

    def ref_to_component
      nesting_depth = path_name.count('/') + 1
      component_path = ('../' * nesting_depth) + "components/#{component_name}.yaml"
      {'$ref' => component_path}
    end

    private

    def write(path, object)
      full_path = "#{path}.yaml"
      ensure_directory_exists(full_path)
      File.write full_path, YAML.dump(object)
    end

    def read_relative(relative_path)
      full_path = "#{INDEX_BASE}/#{relative_path}"
      YAML.load_file(full_path)
    end

    def read(path)
      YAML.load_file("#{path}.yaml")
    end

    def ensure_directory_exists(path)
      dirname = File.dirname(path)
      FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
    end
  end
end
