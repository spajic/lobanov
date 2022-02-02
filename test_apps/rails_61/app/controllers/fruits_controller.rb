# frozen_string_literal: true

class FruitsController < ActionController::Base
  def index
    render json: { fruits: 'will_be_here' }
  end
end
