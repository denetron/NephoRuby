module NephoRuby
  module ApiMethods
    
    # https://kb.nephoscale.com/api/server.html#servercloud
    # https://kb.nephoscale.com/api/server.html#serverdedicated
    def get_servers(type)
      servers = []
      
      case type
      when :cloud
        response = commit("server/cloud/", "get", {})
        
        for vm in response.data
          servers.push(parse_cloud_json(vm))
        end
      when :dedicated
        response = commit("server/dedicated/", "get", {})
        
        for dedicated in response.data
          servers.push(parse_dedicated_json(dedicated))
        end
      else
        raise InvalidServerType, "Only cloud or dedicated are valid server types"
      end
      
      servers
    end
    
    def get_server(type, server_id)
      case type
      when :cloud
        response = commit("server/cloud/#{server_id}/", "get", {})
        
        parse_cloud_json(response.data.first)
      when :dedicated
        response = commit("server/dedicated/#{server_id}/", "get", {})
        
        parse_dedicated_json(response.data.first)
      end
    end
    
    # https://kb.nephoscale.com/api/server.html#servercloud
    # https://kb.nephoscale.com/api/server.html#serverdedicated
    def create_server(server)
      case server.class.to_s
      when "NephoRuby::CloudServer"
        commit("server/cloud/", "post", server.to_params)
      when "NephoRuby::DedicatedServer"
        commit("server/dedicated/", "post", server.to_params)
      else
        raise InvalidServerType, "Only cloud or dedicated server types can be added"
      end
    end
    
    def power_control(server, action)
      case server.class.to_s
      when "NephoRuby::CloudServer"
        commit("/server/cloud/#{server.id}/initiator/#{action.to_s}/", "post", {})
      when "NephoRuby::DedicatedServer"
        commit("/server/dedicated/#{server.id}/initiator/#{action.to_s}/", "post", {})
      end
    end
    
    def destroy_server(server)
      case server.class.to_s
      when "NephoRuby::CloudServer"
        commit("server/cloud/#{server.id}/", "delete", {})
      when "NephoRuby::DedicatedServer"
        commit("server/dedicated/#{server.id}/", "delete", {})
      else
        raise InvalidServerType, "Only cloud or dedicated server types can be added"
      end
    end
    
    # https://kb.nephoscale.com/api/quickstart.html#instance-list
    def get_instances
      instances = []
      response = commit("server/type/cloud/", "get", {})
      
      for instance in response.data
        instances.push(::NephoRuby::Instance.new( :id           => instance["id"],
                                                  :ram          => instance["ram"],
                                                  :storage      => instance["storage"],
                                                  :name         => instance["name"],
                                                  :description  => instance["description"]))
      end
      
      instances
    end
    
    # https://kb.nephoscale.com/api/quickstart.html#image-list
    def get_images
      images = []
      response = commit("image/server/", "get", {})
      
      for image in response.data
        images.push(parse_image_json(image))
      end
      
      images
    end
    
    def get_image(id)
      response = commit("image/server/#{id}/", "get", {})
      
      parse_image_json(response.data.first)
    end
    
    # https://kb.nephoscale.com/api/quickstart.html#unassigned-public-ipv4-address-list
    def get_ip_addresses(version = 4, selector = :unassigned)
      addresses = []
      response = commit("network/ipaddress/", "get", {:type => 0, :version => version, :unassigned => (selector == :unassigned ? 'true' : 'false')})
      
      for address in response.data
        addresses.push(IPAddr.new(address["ipaddress"]))
      end
      
      addresses
    end
    
    
    def get_credentials
      credentials = []
      response = commit("key/", "get", {})
      
      for cred in response.data
        credentials.push(NephoRuby::Credential.new( :id           => cred["id"],
                                                    :name         => cred["friendly_name"],
                                                    :password     => cred["password"],
                                                    :public_key   => cred["public_key"],
                                                    :private_key  => cred["private_key"],
                                                    :group        => cred["group"]))
      end
      
      credentials
    end
    
    def create_credential(credential)
      if credential.key?
        response = commit("key/sshrsa/", "post", credential.to_params)
        
        response.data["id"]
      else
        response = commit("key/password/", "post", credential.to_params)
        
        response.data["id"]
      end
    end
    
    def destroy_credential(credential)
      if credential.key?
        response = commit("key/sshrsa/#{credential.id}/", "delete", {})
      else
        response = commit("key/password/#{credential.id}/", "delete", {})
      end
    end
    
    def get_acl_groups
      groups = []
      response = commit("account/group/", "get", {})
      
      for group in response.data
        groups.push(parse_group_json(group))
      end
      
      groups
    end
    
    def get_users
      users = []
      
      response = commit("account/user/", "get", {})
      
      for user in response.data
        users.push(parse_user_json(user))
      end
      
      users
    end
    
    def create_user(user)
      response = commit("account/user/", "post", user.to_params)
      
      response.data["id"]
    end
    
    def update_user(user)
      response = commit("account/user/#{user.id}/", "put", user.to_params)
      
      response.data["id"]
    end
    
    def destroy_user(user)
      response = commit("account/user/#{user.id}/", "delete")
      
      response.data["id"]
    end
    
    private
    def parse_cloud_json(json)
      image = ::NephoRuby::Image.new(:agent           => json["image"]["has_agent"],
                                     :deployable_type => json["image"]["deployable_type"],
                                     :default         => json["image"]["is_default"],
                                     :creation_time   => json["image"]["create_time"],
                                     :id              => json["image"]["id"],
                                     :max_cpu         => json["image"]["max_cpu"],
                                     :active          => json["image"]["is_active"],
                                     :base_type       => json["image"]["base_type"],
                                     :max_memory      => json["image"]["max_memory"],
                                     :name            => json["image"]["friendly_name"],
                                     :arch            => json["image"]["architecture"])
                                     
      ::NephoRuby::CloudServer.new( :id           => json["id"],
                                    :memory       => json["memory"],
                                    :power_state  => json["power_status"],
                                    :hostname     => json["hostname"],
                                    :ip_addresses => json["ipaddresses"].split(", ").map { |i| IPAddr.new(i) },
                                    :created_at   => json["create_time"],
                                    :image        => image)
    end
    
    def parse_dedicated_json(json)
      image = ::NephoRuby::Image.new(:agent           => json["image"]["has_agent"],
                                     :deployable_type => json["image"]["deployable_type"],
                                     :default         => json["image"]["is_default"],
                                     :creation_time   => json["image"]["create_time"],
                                     :id              => json["image"]["id"],
                                     :max_cpu         => json["image"]["max_cpu"],
                                     :active          => json["image"]["is_active"],
                                     :base_type       => json["image"]["base_type"],
                                     :max_memory      => json["image"]["max_memory"],
                                     :name            => json["image"]["friendly_name"],
                                     :arch            => json["image"]["architecture"])
                                     
      ::NephoRuby::DedicatedServer.new( :id           => json["id"],
                                        :memory       => json["memory"],
                                        :power_state  => json["power_status"],
                                        :hostname     => json["hostname"],
                                        :created_at   => json["create_time"],
                                        :ip_addresses => json["ipaddresses"].split(", ").map { |i| IPAddr.new(i) },
                                        :image        => image)
    end
    
    def parse_image_json(json)
      ::NephoRuby::Image.new( :id               => json["id"],
                              :active           => json["is_active"],
                              :default          => json["is_default"],
                              :agent            => json["has_agent"],
                              :creation_time    => json["create_time"],
                              :max_cpu          => json["max_cpu"],
                              :max_memory       => json["max_memory"],
                              :arch             => json["architecture"],
                              :deployable_type  => json["deployable_type"],
                              :name             => json["friendly_name"])
    end
    
    def parse_group_json(json)
      ::NephoRuby::AclGroup.new(:id   => json["id"],
                                :name => json["name"])
    end
    
    def parse_user_json(json)
      ::NephoRuby::User.new(:id         => json["id"],
                            :username   => json["username"],
                            :first_name => json["first_name"],
                            :last_name  => json["last_name"],
                            :email      => json["email"],
                            :phone      => json["phone"])
    end
  end
end