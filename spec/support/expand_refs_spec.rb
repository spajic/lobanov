# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lobanov::Support::BundleSchema do 
  let(:subject) do 
    Lobanov::Support::ExpandRefs.call(schema)  
  end

  describe 'call' do
    context 'with schema without internal #references' do
      let(:schema) { YAML.load_file('spec/fixtures/bundle_schema/examples/verbose/index.yaml') } 
      let(:etalon) { YAML.load_file('spec/fixtures/bundle_schema/examples/verbose/verbose_etalon.yaml') }
      it 'returns expected etalon result' do 
        expect(subject).to eq(etalon)
      end
    end
  end
end
