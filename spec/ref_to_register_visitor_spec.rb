# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lobanov::RefToRegisterVisitor do
  let(:subject) do
    described_class.visit(
      schema: schema, 
      registered_components: registered_components,
      current_folder: root_folder,
    ) 
  end

  let(:root_folder) { 'spec/fixtures/bundle_schema/examples/verbose' }
  let(:schema) { YAML.load_file("#{root_folder}/index.yaml") } 
  
  let(:registered_components) do
    {
      "#{root_folder}/components/schemas/Fruit.yaml" => '#/components/schemas/Fruit',
      "#{root_folder}/components/schemas/404Response.yaml" => '#/components/schemas/EmptyResponse',
    }
  end

  let(:expected_nodes) do 
    [
      {
        path: ['paths', '/fruits', 'get', 'responses', '200', 'content', 'application/json', 'schema', 'properties', 'items', 'items'],
        value: { '$ref' => '#/components/schemas/Fruit' }
      },
      {
        path: ['paths', '/fruits', 'post', 'requestBody', 'content', 'application/json', 'schema'],
        value: { '$ref' => '#/components/schemas/Fruit' }
      },
    ]
  end

  it 'emits expected nodes' do 
    expect(subject.to_a).to eq(expected_nodes)
  end

  # Make this test work!
  xit 'does not modify incoming schema' do 
    incoming_schema = schema.dup
    described_class.visit(
      schema: incoming_schema, 
      registered_components: registered_components, 
      current_folder: root_folder
    ).to_a
    
    expect(incoming_schema).to eq(schema)
  end
end
