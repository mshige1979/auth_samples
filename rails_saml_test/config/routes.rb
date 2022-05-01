Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root "hello#index"

  resources :saml, only: :index do
    collection do
      get :sso
      post :acs
      get :metadata
      get :logout
      post :logout
    end
  end

end
