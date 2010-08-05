require 'net/https'
require 'uri'

module NephoRuby
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
  
  class ApiError < StandardError; end
  class InvalidServerType < ArgumentError; end
  class HTTPInvalidVerb < ArgumentError; end
end