module NephoRuby
  class User
    attr_accessor :id, :username, :password, :first_name, :last_name, :email, :phone, :address_id, :group_id, :notification_role
    
    def initialize(options = {})
      self.id                 = options[:id]
      self.username           = options[:username]
      self.password           = options[:password]
      self.first_name         = options[:first_name]
      self.last_name          = options[:last_name]
      self.email              = options[:email]
      self.phone              = options[:phone]
      self.address_id         = options[:address_id]
      self.group_id           = options[:group_id]
      self.notification_role  = options[:notification_role]
    end
    
    def to_params
      {
        :id               => self.id,
        :username         => self.username,
        :password         => self.password,
        :first_name       => self.first_name,
        :last_name        => self.last_name,
        :email            => self.email,
        :phone            => self.phone,
        :group            => self.group_id,
        :address          => self.address_id,
        :notificationrole => self.notification_role
      }
    end
  end
end
