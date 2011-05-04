require "httparty"
require "configify"
require "active_support/inflector"
require "active_support/core_ext/hash"
require "cgi"

["item", "config", "contact", "company", "event", "project_blog", "activity_template"].each do |lib|
  require File.join(File.dirname(__FILE__), "solve360", lib)
end

module Solve360
  def self.debug
    Company.debug_output
    Contact.debug_output    
  end
  
  class SaveFailure < Exception
  end
end