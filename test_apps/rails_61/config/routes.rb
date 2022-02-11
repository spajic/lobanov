# frozen_string_literal: true

Rails.application.routes.draw do
  scope :wapi do # scope should not present in paths
    resources :fruits
  end
end
