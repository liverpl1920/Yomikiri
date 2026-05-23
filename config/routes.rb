Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations",
    passwords: "users/passwords",
    confirmations: "users/confirmations"
  }
  root "top#index"

  resource :mypage, only: [ :show, :update ] do
    get :stats
  end
  resource :email_change, only: [ :edit, :update ], controller: "users/email_changes"
  get "email_change/complete", to: "users/email_changes#complete", as: :email_change_complete

  resources :books, only: [ :index, :new, :create, :show, :destroy, :edit, :update ] do
    collection do
      get :search
      get :cover_proxy
    end
    member do
      patch :update_progress
      patch :update_memo
      patch :change_deadline
      patch :complete
      patch :update_review
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
