# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lobanov::Support::CollectRegisteredComponents do
  let(:components_section_yaml) do
    <<~YAML
    schemas:
      Fruit:
        "$ref": ./components/schemas/Fruit.yaml
      EmptyResponse:
        "$ref": "./components/schemas/404Response.yaml"
      InternalErrorResponse:
        description: Internal error happened
    YAML
  end

  let(:components_section) { YAML.load(components_section_yaml) }

  let(:expected_result) do
    {
      'path/to/index/components/schemas/Fruit.yaml' => '#/components/schemas/Fruit',
      'path/to/index/components/schemas/404Response.yaml' => '#/components/schemas/EmptyResponse',
    }
  end

  let(:root_folder) { 'path/to/index' }

  let(:subject) { described_class.call(components_section: components_section, root_folder: root_folder) }

  it 'collects the hash of registered components' do
    expect(subject).to eq(expected_result) 
  end
end
