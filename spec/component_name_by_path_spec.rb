# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lobanov::ComponentNameByPath do
  subject { described_class.call(endpoint_path) }

  context 'with single resource path' do
    let(:endpoint_path) { 'wapi/grid_bots/:id' }
    let(:expected_result) { 'wapi/GridBot' }

    it 'returns expected result' do
      expect(subject).to eq(expected_result)
    end
  end

  context 'with slash in beginning' do
    let(:endpoint_path) { '/wapi/grid_bots/:id' }
    let(:expected_result) { 'wapi/GridBot' }

    it 'returns expected result' do
      expect(subject).to eq(expected_result)
    end
  end

  context 'with collection path' do
    let(:endpoint_path) { 'wapi/grid_bots' }
    let(:expected_result) { 'wapi/GridBots' }

    it 'returns expected result' do
      expect(subject).to eq(expected_result)
    end
  end

  context 'with collection path/' do
    let(:endpoint_path) { 'wapi/grid_bots/' }
    let(:expected_result) { 'wapi/GridBots' }

    it 'returns expected result' do
      expect(subject).to eq(expected_result)
    end
  end

  context 'with nested resource' do
    let(:endpoint_path) { 'wapi/owners/:owner_id/pets/:pet_id/toys/:toy_id' }
    let(:expected_result) { 'wapi/Toy' }

    it 'returns expected result' do
      expect(subject).to eq(expected_result)
    end
  end

  context 'with nested collection' do
    let(:endpoint_path) { 'wapi/owners/:owner_id/pets/:pet_id/toys' }
    let(:expected_result) { 'wapi/Toys' }

    it 'returns expected result' do
      expect(subject).to eq(expected_result)
    end
  end
end
