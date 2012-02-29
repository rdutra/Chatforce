class ApplicationController < ActionController::Base

  before_filter :require_auth, :except => '/index.html'
  protect_from_forgery

  def send_message
    render_text "<li>" + params[:msg_body] + "</li>"
    Juggernaut.publish("/chats", parse_chat_message(params[:msg_body], "Prabhat"))
  end
  
  def parse_chat_message(msg, user)
    return "#{user} says: #{msg}"
  end
  
  def handle_org
  
    id_short = params[:id] [0, 15]
    exists =  Org.exists_org id_short
    if !exists
      Org.insert_org id_short
    end
    render :nothing => true
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
      :buddy_id     => @session["buddy_id"],
      :show_offline => params["show_offline"],
      :idle_time => params["idle_time"]
    }
    Setting.save_settings(options, params["status"])
    redirect_to "buddies/list"
  end
  
  private
    def require_auth
    
      is_ajax = request.headers['X-Requested-With'] == 'XMLHttpRequest'
      if defined? (cookies.signed[:chgo_user_session][0])
        this_session = Session.get_session_by_id(cookies.signed[:chgo_user_session][0])
        if this_session.nil?
          decide_response is_ajax
        end
      else
          decide_response is_ajax
      end
    end
    
   private 
    def decide_response is_ajax
      if is_ajax
        data = {
          :signed => "false"
        }
        render :json => data.to_json
      else
        redirect_to "/index.html"
      end
  
    end
end
