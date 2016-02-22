Rails.application.routes.draw do
  resources :datasets
  root to: 'visitors#index'
end
