# frozen_string_literal: true

Rails.application.routes.draw do
  resources :fruits, only: [:index, :show]
end
