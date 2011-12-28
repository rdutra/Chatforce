Chat::Application.routes.draw do
 
  match '/auth/:provider/callback', :to => 'authorization#create'
  match '/auth/failure', :to => 'authorization#fail'
  
end
