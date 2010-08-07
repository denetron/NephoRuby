# The NephoRuby module contains all the classes and methods necessary
# to interact with the NephoScale API.  Currently there is no sandbox,
# so all experimentation must be done in "production".
# Keep this in mind before destroying objects.
#
# Author::    Daniel Ballenger (mailto:dballenger@denetron.com)
# Copyright:: Copyright (c) 2010 Daniel Ballenger
# License::   MIT
#
#
# === How to get a list of servers
# n = NephoRuby::Base.new(:username => "abc", :password => "abc123")
#
# <em>Cloud Servers</em>: 
# n.get_servers(:cloud)
#
# <em>Dedicated Servers</em>:
# n.get_servers(:dedicated)
#
# ==== Create a cloud server
# n = NephoRuby::Base.new(:username => "abc", :password => "abc123")
# 
# @image = n.get_images.first # We just want to use the first (Operating System) image for documentation
# 
# @type = n.get_instances[3] # This is a 512MB RAM cloud server
# 
# @credential = n.get_credentials.first # Use the first SSH key/password we have on record
# 
# @server = NephoRuby::CloudServer.new(:hostname => "api-test-machin", :ip_addresses => ["208.166.61.171", "10.128.4.4"], :image => @image, :credential => @credential, :instance_type => @type)
# 
# n.create_server(@server)
# 
# === Delete a cloud server
# n = NephoRuby::Base.new(:username => "abc", :password => "abc123")
# 
# @server = n.get_servers(:cloud).first
#
# n.destroy_server(@server)
#
#

require 'net/https'
require 'uri'

module NephoRuby
  # This class is the base of all operations through the API
  
  class Base
    attr_accessor :username, :password
    
    class << self
      attr_accessor :sandbox_url, :production_url
      attr_accessor :sandbox
    end
    
    include ApiMethods
    
    @@production_url = "https://api.nephoscale.com:443"
    @@sandbox_url = @@production_url # Right now there is no sandbox
    
    def initialize(options = {})
      self.username = options[:username]
      self.password = options[:password]
    end
    
    def sandbox?
      true
    end
    
    private
    def commit(action, verb, params = {})
      verify_verb(verb)
      
      uri = URI.parse(self.sandbox? ? @@sandbox_url : @@production_url)
      
      
      request_uri = "/" + action + "?" + (verb == "get" ? params.to_http_params : "")
      
      case verb
      when "get"
        request = Net::HTTP::Get.new(request_uri)
      when "post"
        request = Net::HTTP::Post.new(request_uri)
      when "put"
        request = Net::HTTP::Put.new(request_uri)
      when "delete"
        request = Net::HTTP::Delete.new(request_uri)
      end
      
      request.basic_auth(self.username, self.password)
      request.set_form_data(params) unless verb == "get"
      
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode  = OpenSSL::SSL::VERIFY_PEER
      http.ca_path      = "./certs"
      
      response = http.request(request)
      response = parse_response(response.body)
      
      raise ApiError, response.message unless response.success?
      response
    end
    
    def parse_response(response)
      json_hash = JSON.parse(response)
      
      ::NephoRuby::Response.new(:data => json_hash["data"], :success => json_hash["success"], :message => json_hash["message"])
    end
    
    def verify_verb(verb)
      raise HTTPInvalidVerb, "Invalid HTTP verb specified for the API call" if ["get", "post", "update", "delete"].index(verb).nil?
    end
  end
  
  # This is raised in the event response.success? is false (something about the call failed)
  class ApiError < StandardError; end
  # This is raised if a server type other than dedicated or cloud is specified
  class InvalidServerType < ArgumentError; end
  # This is raised if an HTTP verb other than GET/POST/PUT/DELETE is supplied
  class HTTPInvalidVerb < ArgumentError; end
end