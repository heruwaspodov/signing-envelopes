# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'api/v1/api#index'

  draw(:api)
  draw(:error)

  # must last line to throw error routing
  match '*path' => 'api#no_routes', via: :all, constraints: lambda { |req|
    req.path.exclude? 'rails/active_storage'
  }
end
