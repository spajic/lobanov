# frozen_string_literal: true

class ApplicationController < ActionController::Base
  rescue_from ActionController::ParameterMissing, with: :invalid_parameters

  def invalid_parameters(exception)
    bad_request exception.message, title: 'Bad request'
  end

  def bad_request(message, title: nil)
    respond_to do |format|
      format.json { render json: { message: message, title: title }, status: :bad_request }
      format.all { head :bad_request }
    end
  end
end
