Rails.application.routes.draw do
  root 'files#index'
  get '/files' => 'files#index'
  get '/all_files' => 'files#all_files'
  get '/search' => 'files#search'
  get '/view_document' => 'files#view_document'
  get '/add' => 'files#add'
  post '/upload_document' => 'files#upload_document'
  get '/download' => 'files#download'
end
