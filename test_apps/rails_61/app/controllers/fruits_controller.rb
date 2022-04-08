# frozen_string_literal: true

class FruitsController < ApplicationController
  FRUITS = [
    {name: 'orange', color: 'orange', weight: 100, seasonal: false}.freeze,
    {name: 'lemon', color: 'yellow', weight: 50, seasonal: false}.freeze,
    {name: 'watermelon', color: 'green', weight: 200, seasonal: true}.freeze,
    {name: 'durian', color: nil, weight: 500, seasonal: true}.freeze
  ].freeze

  def index
    render json: {
      items: FRUITS
    }
  end

  def show
    num = params[:id].to_i - 1
    if num == 665
      return render json: {}, status: 401
    end


    fruit = FRUITS[num].dup

    if fruit
      if params[:q] == 'without_name'
        fruit.delete(:name)
      end

      if params[:q] == 'with_integer_name'
        fruit[:name] = 999
      end

      if params[:q] == 'with_null_name'
        fruit[:name] = nil
      end

      render json: fruit
    else
      render json: {}, status: :not_found
    end
  end

  def create
    data = params.require([:name, :color, :weight, :seasonal])

    render json: {}, status: :created
  end

  def update
    data = params.require([:id, :name, :color, :weight, :seasonal])

    render json: {}, status: :ok
  end

  def destroy
    data = params.require(:id)

    render json: {}, status: :ok
  end

  # POST /fruits/:id/upvote
  def upvote
    render json: {}, status: :created
  end
end
