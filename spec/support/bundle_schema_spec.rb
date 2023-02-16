# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lobanov::Support::BundleSchema do 
  describe 'saves a single-file schema bundle given a path to index.yaml' do 
    context 'with concise schema' do 
      let(:index_folder) { 'spec/fixtures/bundle_schema/examples/verbose' }
      let(:etalon_path) { "#{index_folder}/verbose_etalon.yaml" } 
      let(:result_path) { "#{index_folder}/openapi_single.yaml" }

      def clear_file
        FileUtils.rm_f(result_path)
      end

      before do
        clear_file 
      end

      xit 'writes expected content to expected file' do
        Lobanov::Support::BundleSchema.call(index_folder: index_folder)
        generated_bundle = YAML.load_file(result_path)
        etalon = YAML.load_file(etalon_path)
        expect(generated_bundle).to eq(etalon)
      end

      after do 
        clear_file
      end
    end
  end
end

