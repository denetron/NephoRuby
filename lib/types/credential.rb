module NephoRuby
  class Credential
   attr_accessor :id, :public_key, :private_key, :password, :group
   
   def initialize(options = {})
     self.id          = options[:id]
     self.public_key  = options[:public_key]
     self.private_key = options[:private_key]
     self.password    = options[:password]
     self.group       = options[:group]
   end
   
   def key?
    self.password.nil?
   end
  end
end