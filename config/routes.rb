# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  resources :documents do
    collection do
      get 'new_batch_upload'
      post 'create_batch_upload'
    end
  end
  draw :accounts
  draw :api
  draw :billing
  draw :turbo_native
  draw :users
  draw :dev if Rails.env.local?

  authenticated :user, ->(u) { u.admin? } do
    draw :admin
  end

  resources :announcements, only: %i[index show]

  namespace :action_text do
    resources :embeds, only: [:create], constraints: { id: %r{[^/]+} } do
      collection do
        get :patterns
      end
    end
  end

  scope controller: :static do
    get :about
    get :terms
    get :privacy
    get :pricing
  end

  match '/404', via: :all, to: 'errors#not_found'
  match '/500', via: :all, to: 'errors#internal_server_error'

  authenticated :user do
    root to: 'dashboard#show', as: :user_root
    # Alternate route to use if logged in users should still see public root
    # get "/dashboard", to: "dashboard#show", as: :user_root
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', :as => :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get 'service-worker' => 'rails/pwa#service_worker', :as => :pwa_service_worker
  get 'manifest' => 'rails/pwa#manifest', :as => :pwa_manifest

  # Public marketing homepage
  root to: 'static#index'
end
