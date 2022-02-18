# frozen_string_literal: true

Rails.application.routes.draw do
  scope :wapi do # scope should not present in paths
    resources :fruits do
      member { post 'upvote' }

      resources :reviews, module: 'fruits' do
        collection { get 'stats' }
      end
    end
  end
end
