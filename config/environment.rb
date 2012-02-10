# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Chat::Application.initialize!



Rails.application.config.session_store = {
  :key    => '_app_session',
  :secret => 'R8e&5Or#'
}

ENV['sfdc_api_version'] = '23.0'
