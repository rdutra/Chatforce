Chat::Application.routes.draw do
  resources :buddies
  root :to => "buddies#index" 
  match "/chat/send", :controller => "chat", :action => "send_message"
  match "/chat/single", :controller => "chat", :action => "single_chat"
  get "authorization/create"
  match '/auth/:provider/callback', :to => 'authorization#create'
  match '/auth/failure', :to => 'authorization#fail'
  match '/auth/connect', :to => 'authorization#connect'
  match "/buddies/list", :controller => "buddies", :action => "index"
  match ':controller(/:action(/:id(.:format)))'
  match '/settings', :controller => "settings", :action => "index"
  match '/save_settings', :controller => "settings", :action => "save_setting"
  
end
