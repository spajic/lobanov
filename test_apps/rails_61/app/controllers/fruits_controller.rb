# frozen_string_literal: true

class FruitsController < ActionController::Base
  rescue_from ActionController::ParameterMissing, with: :invalid_parameters

  def invalid_parameters(exception)
    bad_request exception.message, title: 'Bad request'
  end

  def bad_request(message, title: nil)
    respond_to do |format|
      format.json {render json: {message: message, title: title}, status: :bad_request}
      format.all {head :bad_request}
    end
  end

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
    if num == 665
      return render json: {}, status: 401
    end


    fruit = FRUITS[num]

    if fruit
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
