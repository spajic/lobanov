# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lobanov::Support::BundleSchema do 
  let(:subject) do 
    Lobanov::Support::BundleSchema.call(path_to_index)  
  end

  describe 'saves a single-file schema bundle given a path to index.yaml' do 
    context 'with concise schema' do 
      let(:path_to_index) { 'spec/fixtures/bundle_schema/examples/concise/index.yaml' }
      let(:etalon_path) { 'spec/fixtures/bundle_schema/examples/concise/concise_etalon.yaml' } 
      let(:etalon_hash) { YAML.load_file(etalon_path) }

      it 'returns a hash with the expected etalon schema bundle' do
        expect(subject).to eq(etalon_hash)
      end
    end
  end
end

