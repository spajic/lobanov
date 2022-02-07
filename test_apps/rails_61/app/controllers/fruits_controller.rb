# frozen_string_literal: true

class FruitsController < ActionController::Base
  def index
    render json: { fruits: 'will_be_here' }
  end

  def show
    case params[:id].to_i
    when 1
      render json: {
        color: nil
      }
    when 2
      render json: {
        color: 'yellow'
      }
    end
  end
end
