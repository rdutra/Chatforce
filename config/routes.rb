Chat::Application.routes.draw do
 
  get "authorization/create"
 
  match '/auth/:provider/callback', :to => 'authorization#create'
  match '/auth/failure', :to => 'authorization#fail'
  
end
