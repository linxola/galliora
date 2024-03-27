Rails.application.routes.draw do
  devise_for :users, path: '', skip: :confirmations,
                     controllers: { registrations: 'users/registrations',
                                    confirmations: 'users/confirmations',
                                    sessions: 'users/sessions',
                                    passwords: 'users/passwords',
                                    omniauth_callbacks: 'users/omniauth_callbacks' }

  devise_scope :user do
    get 'account', to: 'users/registrations#edit', as: :edit_user
    get 'check_email', to: 'users/confirmations#new', as: :new_user_confirmation
    get 'email_confirmation', to: 'users/confirmations#show', as: :user_confirmation
    post 'email_confirmation', to: 'users/confirmations#create', as: :send_user_confirmation
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Defines the root path route ("/")
  root 'landing#index'

  get 'users/:id', to: 'users#show', as: :user
end
