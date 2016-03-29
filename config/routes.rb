Rails.application.routes.draw do
  root 'files#index'
  get '/files' => 'files#index'
  get '/search' => 'files#search'
end
