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
      './components/schemas/Fruit.yaml' => '#/components/schemas/Fruit',
      './components/schemas/404Response.yaml' => '#/components/schemas/EmptyResponse',
    }
  end

  let(:subject) { described_class.call(components_section: components_section) }

  it 'collects the hash of registered components' do
    expect(subject).to eq(expected_result) 
  end
end
