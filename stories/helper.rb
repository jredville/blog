ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
 
require 'spec/rails/story_adapter'
# require File.dirname(__FILE__) + '/../lib/selenium-ruby-client-driver/selenium'
require File.dirname(__FILE__) + '/../lib/authenticated_test_helper'

Dir[File.dirname(__FILE__) + "/steps/*.rb"].uniq.each { |file| require file }


