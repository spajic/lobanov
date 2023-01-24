# frozen_string_literal: true

module Api
  module V6
    class VegetablesController < ApplicationController
      VEGETABLES = [
        { name: 'tomato', color: 'red', weight: 100, seasonal: false }.freeze,
        { name: 'potato', color: 'yellow', weight: 50, seasonal: false }.freeze,
        { name: 'broccoli', color: 'green', weight: 200, seasonal: true }.freeze,
        { name: 'cabbage', color: nil, weight: 500, seasonal: true }.freeze
      ].freeze

      def index
        render json: {
          items: VEGETABLES
        }
      end

      def show
        num = params[:id].to_i - 1
        return render json: {}, status: 401 if num == 665

        vegetable = VEGETABLES[num].dup

        if vegetable
          process_vegetable(vegetable)

          render json: vegetable
        else
          render json: {}, status: :not_found
        end
      end

      def create
        _data = params.require(%i[name color weight seasonal])

        render json: {}, status: :created
      end

      def update
        _data = params.require(%i[id name color weight seasonal])

        render json: {}, status: :ok
      end

      def destroy
        _data = params.require(:id)

        render json: {}, status: :ok
      end

      # POST /vegetables/:id/upvote
      def upvote
        render json: {}, status: :created
      end

      private

      def process_vegetable(vegetable)
        vegetable.delete(:name) if params[:q] == 'without_name'

        vegetable[:name] = 999 if params[:q] == 'with_integer_name'

        vegetable[:name] = nil if params[:q] == 'with_null_name'
      end
    end
  end
end
