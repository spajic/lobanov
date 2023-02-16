# frozen_string_literal: true

module Lobanov
  module Support
    class ExpandRefs
      # TODO: наверно проще всю логику сделать здесь
      # - [ ] передать сюда registered_components
      # - [ ] если реф в registered_components, то заменить его на registered_components[ref]
      # - [ ] если реф не в registered_components, то загрузить файл по пути ref
      # - [ ] исключение для schema['components']['schemas'] первого уровня - там всегда загужаем файл
      def self.call(schema, current_folder, registered_components:)
        current_path = Pathname.new(current_folder)

        Lobanov::RefVisitor.visit(schema).each do |node|
          path = node[:path]
          value = node[:value]

          ref = value['$ref']
          ref_path = current_path.join(ref)
          ref_folder = ref_path.parent

          ref_schema =
            if registered_components.key?(ref_path.to_s) && !(path.size == 3 && path[0] == 'components' && path[1] == 'schemas')
              {'$ref' => registered_components[ref_path.to_s]}
            else
              YAML.load_file(Pathname.new(current_folder).join(ref)) 
            end
          expanded_ref_schema = self.call(ref_schema, ref_folder, registered_components: registered_components) # recursion here

          if path == [] # expanded schema contains only the ref and nothing else
            schema = expanded_ref_schema
          elsif path.size == 1
            schema[path.last] = expanded_ref_schema
          else
            schema.dig(*path[0..-2])[path.last] = expanded_ref_schema 
          end
        end
        
        schema
      end
    end
  end
end
