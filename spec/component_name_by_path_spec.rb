# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lobanov::ComponentNameByPath do
  subject do
    res = described_class.call(endpoint_path)[:full]
  end

  context 'with empty namespaces_to_ignore' do
    before(:all) do
      Lobanov.configure do |config|
        config.namespaces_to_ignore = []
      end
    end

    context 'with single resource path' do
      let(:endpoint_path) { 'wapi/grid_bots/:id' }
      let(:expected_result) { 'wapi/grid_bots/GridBot' }

      it 'returns expected result' do
        expect(subject).to eq(expected_result)
      end
    end

    context 'with slash in beginning' do
      let(:endpoint_path) { '/wapi/grid_bots/:id' }
      let(:expected_result) { 'wapi/grid_bots/GridBot' }

      it 'returns expected result' do
        expect(subject).to eq(expected_result)
      end
    end

    context 'with collection path' do
      let(:endpoint_path) { 'wapi/grid_bots' }
      let(:expected_result) { 'wapi/grid_bots/GridBots' }

      it 'returns expected result' do
        expect(subject).to eq(expected_result)
      end
    end

    context 'with collection path/' do
      let(:endpoint_path) { 'wapi/grid_bots/' }
      let(:expected_result) { 'wapi/grid_bots/GridBots' }

      it 'returns expected result' do
        expect(subject).to eq(expected_result)
      end
    end

    context 'with nested resource' do
      let(:endpoint_path) { 'wapi/owners/:owner_id/pets/:pet_id/toys/:toy_id' }
      let(:expected_result) { 'wapi/owners/pets/toys/Toy' }

      it 'returns expected result' do
        expect(subject).to eq(expected_result)
      end
    end

    context 'with nested collection' do
      let(:endpoint_path) { 'wapi/owners/:owner_id/pets/:pet_id/toys' }
      let(:expected_result) { 'wapi/owners/pets/toys/Toys' }

      it 'returns expected result' do
        expect(subject).to eq(expected_result)
      end
    end
  end

  context 'with Lobanov.namespaces_to_ignore = ["wapi"]' do
    before(:all) do
      Lobanov.configure do |config|
        config.namespaces_to_ignore = ['wapi']
      end
    end

    after(:all) do
      Lobanov.configure do |config|
        config.namespaces_to_ignore = []
      end
    end

    context 'with single resource path' do
      let(:endpoint_path) { 'wapi/grid_bots/:id' }
      let(:expected_result) { 'grid_bots/GridBot' }

      it 'returns expected result' do
        expect(subject).to eq(expected_result)
      end
    end

    context 'with slash in beginning' do
      let(:endpoint_path) { '/wapi/grid_bots/:id' }
      let(:expected_result) { 'grid_bots/GridBot' }

      it 'returns expected result' do
        expect(subject).to eq(expected_result)
      end
    end

    context 'with collection path' do
      let(:endpoint_path) { 'wapi/grid_bots' }
      let(:expected_result) { 'grid_bots/GridBots' }

      it 'returns expected result' do
        expect(subject).to eq(expected_result)
      end
    end

    context 'with collection path/' do
      let(:endpoint_path) { 'wapi/grid_bots/' }
      let(:expected_result) { 'grid_bots/GridBots' }

      it 'returns expected result' do
        expect(subject).to eq(expected_result)
      end
    end

    context 'with nested resource' do
      let(:endpoint_path) { 'wapi/owners/:owner_id/pets/:pet_id/toys/:toy_id' }
      let(:expected_result) { 'owners/pets/toys/Toy' }

      it 'returns expected result' do
        expect(subject).to eq(expected_result)
      end
    end

    context 'with nested collection' do
      let(:endpoint_path) { 'wapi/owners/:owner_id/pets/:pet_id/toys' }
      let(:expected_result) { 'owners/pets/toys/Toys' }

      it 'returns expected result' do
        expect(subject).to eq(expected_result)
      end
    end
  end
end
