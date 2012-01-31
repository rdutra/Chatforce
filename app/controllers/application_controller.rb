class ApplicationController < ActionController::Base
  protect_from_forgery
  def send_message
    render_text "<li>" + params[:msg_body] + "</li>"
    Juggernaut.publish("/chats", parse_chat_message(params[:msg_body], "Prabhat"))
  end
  
  def parse_chat_message(msg, user)
    return "#{user} says: #{msg}"
  end
  
  def save_setting
    @session = Session.get_session_by_id cookies.signed[:chgo_user_session][0]
    if params["check_id"] == 'on'
      ahistory = 1
    else  
      ahistory = 0
    end
    options = {
      :history      => ahistory,
      :skin         => params["select_skin"],
      :buddy_id     => @session["buddy_id"]
    }
    Setting.save_settings(options)
    #redirect_to :controller => 'buddies', :action => 'index'
  end
end
