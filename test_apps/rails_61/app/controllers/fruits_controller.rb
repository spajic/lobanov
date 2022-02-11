# frozen_string_literal: true

class FruitsController < ActionController::Base
  # TODO: сохранить в константу 3 фрукта и брать контент из неё
  FRUITS = [
    {name: 'orange', color: 'orange', weight: 100, seasonal: false},
    {name: 'lemon', color: 'yellow', weight: 50, seasonal: false},
    {name: 'watermelon', color: 'green', weight: 200, seasonal: true},
    {name: 'durian', color: nil, weight: 500, seasonal: true}
  ]

  def index
    render json: {
      items: FRUITS
    }
  end

  def show
    num = params[:id].to_i - 1
    fruit = FRUITS[num]

    if fruit
      render json: fruit
    else
      not_found
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
end
