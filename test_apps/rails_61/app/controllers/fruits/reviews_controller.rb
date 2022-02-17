# frozen_string_literal: true

class Fruits::ReviewsController < ApplicationController
  REVIEWS = [
    {text: 'review #1', positive: true},
    {text: 'review #2', positive: false},
    {text: 'review #3', positive: true},
    {text: 'review #4', positive: false},
  ]

  # GET wapi/fruits/:fruit_id/reviews
  def index
    render json: REVIEWS
  end

  # GET wapi/fruits/:fruit_id/reviews/:id.json
  def show
    num = params[:id].to_i - 1
    review = REVIEWS[num]

    if review
      render json: review
    else
      render json: {}, status: :not_found
    end
  end
end
