require 'rubygems'
require 'httparty'

class Users
  include HTTParty
  format :json

  def self.set_headers token
    headers 'Authorization' => "OAuth #{token}"
  end

  def self.root_url instance
    @root_url = instance+"/services/data/v"+ENV['sfdc_api_version']
  end
  
  def self.getAll instance, token
    Users.set_headers token
    soql = "SELECT Id, Name, SmallPhotoUrl, CompanyName from User LIMIT 9999"
    get(Users.root_url(instance)+"/query/?q=#{CGI::escape(soql)}")
  end
  
  def self.get_user_info(id, instance, token)
    Users.set_headers token
    get(Users.root_url(instance)+"/chatter/users/"+id)
  end
  
  def self.getMe instance, token
    user = Users.get_user_info("me", instance, token)
    return user
  end
  
  def self.getOrg
    Users.set_headers
  end
  
  def self.getUsersForSync instance, token
    Users.set_headers token
    soql = "SELECT User_id__c, User_name__c, User_sphoto__c from TG_Sync__c LIMIT 9999"
    get(Users.root_url(instance)+"/query/?q=#{CGI::escape(soql)}")
  end
 
end
