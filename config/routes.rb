Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations"
  }
  root "top#index"

  resources :books, only: [ :index, :new, :create, :show, :destroy ] do
    member do
      patch :update_progress
      patch :change_deadline
      # 後続 Issue で実装予定
      # patch :complete
      patch :complete
      # 後続 Issue で実装予定
      # patch :change_deadline
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
