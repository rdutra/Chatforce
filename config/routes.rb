Chat::Application.routes.draw do
  resources :buddies

  root :to => "chat#channel1" 
  match "/chat/send", :controller => "chat", :action => "send_message"
  match "/chat/channel1", :controller => "chat", :action => "channel1"
  match '/auth/:provider/callback', :to => 'authorization#create'
  match '/auth/failure', :to => 'authorization#fail'
  match ':controller(/:action(/:id(.:format)))'
  
end
