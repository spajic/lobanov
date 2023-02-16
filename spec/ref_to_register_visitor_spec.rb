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
      './components/schemas/Fruit.yaml' => '#/components/schemas/Fruit',
      './components/schemas/404Response.yaml' => '#/components/schemas/EmptyResponse',
    }
  end

  let(:expected_nodes) do 
    []
  end

  it 'emits expected nodes' do 
    expect(subject.to_a).to eq(expected_nodes)
  end
end
