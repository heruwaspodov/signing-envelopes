# frozen_string_literal: true

Rails.application.routes.draw do
  match '/500', to: 'errors#internal_server_error', via: :all
end
