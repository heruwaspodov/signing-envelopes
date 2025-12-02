# frozen_string_literal: true

namespace :api do
  namespace :v1 do
    get 'app' => 'api#index'

    # Health Check
    mount HealthCheck.rack => '/health_check', as: 'health_check'

    post :single_sign, to: 'single_sign#signing'
    post :multiple_sign, to: 'multiple_sign#signing'
  end
end
