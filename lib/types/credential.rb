module NephoRuby
  class Credential
   attr_accessor :id, :name, :public_key, :private_key, :password, :group
   
   def initialize(options = {})
     self.id          = options[:id]
     self.name        = options[:name]
     self.public_key  = options[:public_key]
     self.private_key = options[:private_key]
     self.password    = options[:password]
     self.group       = options[:group]
   end
   
   def key?
    self.password.nil?
   end
   
   def to_params
    {
      :friendly_name  => self.name,
      :password       => self.password,
      :public_key     => self.public_key,
      :private_key    => self.private_key,
      :key_group      => self.group
    }
   end
  end
end