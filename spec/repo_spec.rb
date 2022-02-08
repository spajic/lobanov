# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lobanov::Repo do
  let(:repo) { described_class.new(interaction: grid_bots_interaction) }
  let(:grid_bots_interaction) do
    Lobanov::Interaction.new(
      verb: 'GET',
      endpoint_path: '/wapi/grid_bots/:id',
      path_info: '/wapi/grid_bots/1.json',
      path_params: {'id' => '1'},
      query_params: {},
      payload: {},
      status: 200,
      body: {
        'bot' => {
          'id' => 1,
          'name' => 'test bot',
          'created_at' => 1_633_612_919,
          'account_id' => 1,
          'pair' => 'USDT_BTC',
          'strategy_type' => 'manual',
          'leverage_custom_value' => 2.5,
          'leverage_type_cd' => 1,
          'investment' => '0.0',
          'investment_quote_currency' => '0.0',
          'upper_price' => '11000.0',
          'lower_price' => '9000.0',
          'quantity_per_grid' => '1.0',
          'grids_quantity' => 101,
          'total_quantity' => '0.0',
          'current_profit' => '0.0',
          'current_profit_percent' => 0,
          'status' => 'enabled',
          'grid' => [],
          'tv_key' => 'BINANCE',
          'tv_pair' => 'USDT_BTC',
          'trailing_view_supported' => true,
          'is_contract' => false
        }
      }
    )
  end

  let(:path_schema) do
    {
      'get' => {
        'parameters' => [
          {
            'in' => 'path',
            'name' => 'id',
            'description' => 'id',
            'schema' => {'type' => 'integer'},
            'required' => true,
            'example' => '1'
          }
        ],
        'responses' => {
          '200' => {
            'description' => 'GET /wapi/grid_bots/:id -> 200',
            'content' => {
              'application/json' => {
                'schema' => component_schema
              }
            }
          }
        }
      }
    }
  end

  let(:path_schema_with_component_ref) do
    {
      'get' => {
        'parameters' => [
          {
            'in' => 'path',
            'name' => 'id',
            'description' => 'id',
            'schema' => {'type' => 'integer'},
            'required' => true,
            'example' => '1'
          }
        ],
        'responses' => {
          '200' => {
            'description' => 'GET /wapi/grid_bots/:id -> 200',
            'content' => {
              'application/json' => {
                'schema' => {
                  '$ref' => '../../../components/wapi/grid_bots/GridBot.yaml'
                }
              }
            }
          }
        }
      }
    }
  end

  let(:component_schema) do
    {
      'type' => 'object',
      'required' => ['bot'],
      'properties' => {
        'bot' => {
          'type' => 'object',
          'required' => %w[
            id
            name
            created_at
            account_id
            pair
            strategy_type
            leverage_custom_value
            leverage_type_cd
            investment
            investment_quote_currency
            upper_price
            lower_price
            quantity_per_grid
            grids_quantity
            total_quantity
            current_profit
            current_profit_percent
            status
            grid
            tv_key
            tv_pair
            trailing_view_supported
            is_contract
          ],
          'properties' => {
            'id' => {'type' => 'integer'},
            'name' => {'type' => 'string'},
            'created_at' => {'type' => 'integer'},
            'account_id' => {'type' => 'integer'},
            'pair' => {'type' => 'string'},
            'strategy_type' => {'type' => 'string'},
            'leverage_custom_value' => {'type' => 'number'},
            'leverage_type_cd' => {'type' => 'integer'},
            'investment' => {'type' => 'string'},
            'investment_quote_currency' => {'type' => 'string'},
            'upper_price' => {'type' => 'string'},
            'lower_price' => {'type' => 'string'},
            'quantity_per_grid' => {'type' => 'string'},
            'grids_quantity' => {'type' => 'integer'},
            'total_quantity' => {'type' => 'string'},
            'current_profit' => {'type' => 'string'},
            'current_profit_percent' => {'type' => 'integer'},
            'status' => {'type' => 'string'},
            'grid' => {'type' => 'array', 'minItems' => 0, 'uniqueItems' => true, 'items' => {}},
            'tv_key' => {'type' => 'string'},
            'tv_pair' => {'type' => 'string'},
            'trailing_view_supported' => {'type' => 'boolean'},
            'is_contract' => {'type' => 'boolean'}
          }
        }
      }
    }
  end

  describe '#ref_to_component' do
    let(:subject) do
      repo.ref_to_component
    end
    let(:expected_ref) { {'$ref' => '../../../components/wapi/grid_bots/GridBot.yaml'} }

    it 'returns expected result' do
      expect(subject).to eq(expected_ref)
    end
  end

  describe '#replace_component_schema_with_ref' do
    let(:subject) do
      repo.replace_component_schema_with_ref
    end

    it 'returns expected result' do
      expect(subject).to eq(path_schema_with_component_ref)
    end
  end
end
