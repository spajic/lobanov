# frozen_string_literal: true

module Lobanov
  class FindResponseForInteraction
    def self.call(interaction)
      begin
        index = YAML.load_file(interaction.base_path.join('index.yaml'))
      rescue Errno::ENOENT
        return
      end
      relative_path = index.dig(*dig_args(interaction))
      interaction.base_path.join(relative_path)
    end

    def self.dig_args(interaction)
      ['paths',
       interaction.path_with_curly_braces,
       interaction.verb.downcase,
       'responses',
       interaction.status.to_s,
       'content',
       'application/json',
       'schema',
       '$ref']
    end
  end
end
