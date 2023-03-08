# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lobanov::GenerateInteractionTags do
  let(:subject) do
    described_class.call(interaction)
  end

  context 'with FruitsReviewShow operation' do
    let(:interaction) do
      Lobanov::Interaction.new(
        verb: 'GET',
        api_marker: 'wapi',
        endpoint_path: '/fruits/:id/reviews/:review_id',
        controller_action: 'show',
        path_info: '/fruits/1/reviews/2.json',
        path_params: { 'id' => '1', 'review_id' => '2' },
        query_params: {},
        payload: {},
        status: 200,
        body: []
      )
    end

    it 'returns expected tags' do
      expect(subject).to eq(%w[Fruits])
    end
  end

  context 'with MiniAppsRatingsUpvote operation' do
    let(:interaction) do
      Lobanov::Interaction.new(
        verb: 'POST',
        api_marker: 'wapi',
        endpoint_path: '/mini_apps/:id/ratings/upvote',
        controller_action: 'upvote',
        path_info: '/mini_apps/1/ratings/upvote.json',
        path_params: { 'id' => '1' },
        query_params: {},
        payload: {},
        status: 200,
        body: []
      )
    end

    it 'returns expected tags' do
      puts interaction.operation_id
      expect(subject).to eq(%w[MiniApps])
    end
  end
end
