# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lobanov::Generator do
  let(:subject) do
    described_class.new(interaction: interaction)
  end

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
          'investment' => '0.0',
          'investment_quote_currency' => '0.0',
          'upper_price' => '11000.0',
          'lower_price' => '9000.0',
          'quantity_per_grid' => '1.0',
          'grids_quantity' => 101,
          'total_quantity' => '0.0',
          'current_profit' => '0.0',
          'current_profit_percent' => 0,
          'current_price' => 100.0,
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

  describe '#call with grid_bots interaction' do
    let(:interaction) { grid_bots_interaction }
    let(:expected_result) do
      {
        'paths' => {
          '/wapi/grid_bots/{id}' => path_schema
        }
      }
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
              investment
              investment_quote_currency
              upper_price
              lower_price
              quantity_per_grid
              grids_quantity
              total_quantity
              current_profit
              current_profit_percent
              current_price
              status
              grid
              tv_key
              tv_pair
              trailing_view_supported
              is_contract
            ],
            'properties' => {
              'id' => {'type' => 'integer', 'example' => 1},
              'name' => {'type' => 'string', 'example' => 'test bot'},
              'created_at' => {'type' => 'integer', 'example' => 1_633_612_919},
              'account_id' => {'type' => 'integer', 'example' => 1},
              'pair' => {'type' => 'string', 'example' => 'USDT_BTC'},
              'strategy_type' => {'type' => 'string', 'example' => 'manual'},
              'leverage_custom_value' => {'type' => 'number', 'example' => 2.5},
              'investment' => {'type' => 'string', 'example' => '0.0'},
              'investment_quote_currency' => {'type' => 'string', 'example' => '0.0'},
              'upper_price' => {'type' => 'string', 'example' => '11000.0'},
              'lower_price' => {'type' => 'string', 'example' => '9000.0'},
              'quantity_per_grid' => {'type' => 'string', 'example' => '1.0'},
              'grids_quantity' => {'type' => 'integer', 'example' => 101},
              'total_quantity' => {'type' => 'string', 'example' => '0.0'},
              'current_profit' => {'type' => 'string', 'example' => '0.0'},
              'current_profit_percent' => {'type' => 'integer', 'example' => 0},
              'current_price' => {'type' => 'number', 'example' => 100.0},
              'status' => {'type' => 'string', 'example' => 'enabled'},
              'grid' => {'type' => 'array', 'minItems' => 0, 'uniqueItems' => true, 'items' => {}},
              'tv_key' => {'type' => 'string', 'example' => 'BINANCE'},
              'tv_pair' => {'type' => 'string', 'example' => 'USDT_BTC'},
              'trailing_view_supported' => {'type' => 'boolean', 'example' => true},
              'is_contract' => {'type' => 'boolean', 'example' => false}
            }
          }
        }
      }
    end

    it 'returns expected result' do
      expect(subject.call).to eq(expected_result)

      expect(subject.endpoint_path).to eq('/wapi/grid_bots/:id')
      expect(subject.component_name).to eq('wapi/GridBot')
      expect(subject.verb).to eq('GET')
      expect(subject.status).to eq(200)
      expect(subject.component_schema).to eq(component_schema)
      expect(subject.path_name).to eq('wapi/grid_bots/[id]')
      expect(subject.path_schema).to eq(path_schema)
    end
  end
end