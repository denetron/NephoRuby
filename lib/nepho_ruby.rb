require 'net/https'
require 'uri'

module NephoRuby
  class Base
    attr_accessor :username, :password
    
    class << self
      attr_accessor :sandbox_url, :production_url
      attr_accessor :sandbox
    end
    
    @@production_url = "https://api.nephoscale.com:443"
    @@sandbox_url = @@production_url # Right now there is no sandbox
    
    def initialize(options = {})
      self.username = options[:username]
      self.password = options[:password]
    end
    
    def sandbox?
      true
    end
    
    def commit(action, verb, params = {})
      verify_verb(verb)
      
      uri                     = URI.parse(self.sandbox? ? @@sandbox_url : @@production_url)
      
      request                 = Net::HTTP::Post.new("/" + action)
      request.basic_auth(self.username, self.password)
      request.set_form_data(params)
      
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode  = OpenSSL::SSL::VERIFY_PEER
      http.ca_path      = "./certs"
        
      http.request(request)
    end
    
    def parse_response
      
    end
    
    def verify_verb(verb)
      raise HTTPInvalidVerb, "Invalid HTTP verb specified for the API call" if ["get", "post", "update", "delete"].index(verb).nil?
    end
  end
  
  class HTTPInvalidVerb < ArgumentError; end
end