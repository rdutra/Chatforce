require 'security'
class SettingsController < ApplicationController
  
  def index
    @session = Session.get_session_by_id cookies.signed[:chgo_user_session][0]
    org_id = @session["token"].split('!')[0]
    org = Org.get_org_by_sfid(org_id)
  end
end
