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
          servers.push(parse_dedicated_json(vm))
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
        images.push(::NephoRuby::Image.new( :id               => image["id"],
                                            :active           => image["is_active"],
                                            :default          => image["is_default"],
                                            :agent            => image["has_agent"],
                                            :creation_time    => image["create_time"],
                                            :max_cpu          => image["max_cpu"],
                                            :max_memory       => image["max_memory"],
                                            :arch             => image["architecture"],
                                            :deployable_type  => image["deployable_type"],
                                            :name             => image["friendly_name"]))
      end
      
      images
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
  end
end