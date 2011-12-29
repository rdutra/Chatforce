require 'rubygems'
require 'httparty'

class Users
  include HTTParty
  format :json

  def self.set_headers
    headers 'Authorization' => "OAuth #{ENV['sfdc_token']}"
  end

  def self.root_url
    @root_url = ENV['sfdc_instance_url']+"/services/data/v"+ENV['sfdc_api_version']
  end
  
  def self.getAll
    Users.set_headers
    soql = "SELECT Id, Name, SmallPhotoUrl, CompanyName from User LIMIT 9999"
    get(Users.root_url+"/query/?q=#{CGI::escape(soql)}")
  end
  
  def self.syncronize
  
  end
 
end
