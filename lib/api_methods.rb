module NephoRuby
  module ApiMethods
    
    # https://kb.nephoscale.com/api/server.html#servercloud
    # https://kb.nephoscale.com/api/server.html#serverdedicated
    def get_servers(type)
      servers = []
      
      case type
      when :cloud
        response = commit("server/cloud/", "get", {})
        
        raise ApiError unless response.success?
        
        for vm in response.data
          image = ::NephoRuby::Image.new(:agent => vm["image"]["has_agent"],
                                         :deployable_type => vm["image"]["deployable_type"],
                                         :default => vm["image"]["is_default"],
                                         :creation_time => vm["image"]["create_time"],
                                         :id => vm["image"]["id"],
                                         :max_cpu => vm["image"]["max_cpu"],
                                         :active => vm["image"]["is_active"],
                                         :base_type => vm["image"]["base_type"],
                                         :max_memory => vm["image"]["max_memory"],
                                         :name => vm["image"]["friendly_name"],
                                         :arch => vm["image"]["architecture"])
                                         
          servers.push(::NephoRuby::CloudServer.new(:memory =>        vm["memory"],
                                                    :power_state =>   vm["power_status"],
                                                    :hostname =>      vm["hostname"],
                                                    :ip_addresses =>  vm["ipaddresses"].split(", "),
                                                    :created_at =>    vm["create_time"],
                                                    :image =>         image))
    
        end
      when :dedicated
      else
        raise InvalidServerType, "Only cloud or dedicated are valid server types"
      end
      
      servers
    end
    
    def create_server(server)
#      case server.class
#      when NephoRuby::CloudServer
puts server.to_params.to_json
        response = commit("server/cloud/", "post", server.to_params.to_json)
#      when NephoRuby::DedicatedServer
#        
#      else
#        raise InvalidServerType, "Only cloud or dedicated server types can be added"
#      end
    end
    
    # https://kb.nephoscale.com/api/quickstart.html#instance-list
    def get_instance_types
      instances = []
      response = commit("server/type/cloud/", "get", {})
      
      raise ApiError unless response.success?
      
      for instance in response.data
        instances.push(::NephoRuby::Instance.new( :id => instance["id"],
                                                  :ram => instance["ram"],
                                                  :storage => instance["storage"],
                                                  :name => instance["name"],
                                                  :description => instance["description"]))
      end
      
      instances
    end
    
    # https://kb.nephoscale.com/api/quickstart.html#image-list
    def get_image_list
      images = []
      response = commit("image/server/", "get", {})
      
      raise ApiError unless response.success?
      
      for image in response.data
        images.push(::NephoRuby::Image.new( :id => image["id"],
                                            :active => image["is_active"],
                                            :default => image["is_default"],
                                            :agent => image["has_agent"],
                                            :creation_time => image["create_time"],
                                            :max_cpu => image["max_cpu"],
                                            :max_memory => image["max_memory"],
                                            :arch => image["architecture"],
                                            :deployable_type => image["deployable_type"],
                                            :name => image["friendly_name"]))
      end
      
      images
    end
    
    # https://kb.nephoscale.com/api/quickstart.html#unassigned-public-ipv4-address-list
    def get_ip_addresses(version = 4, selector = :unassigned)
      addresses = []
      response = commit("network/ipaddress/", "get", {:type => 0, :version => version, :unassigned => (selector == :unassigned ? 'true' : 'false')})
      puts response.inspect
      raise ApiError unless response.success?
      
      for address in response.data
        addresses.push(IPAddr.new(address["ipaddress"]))
      end
      
      addresses
    end
    
    def get_credentials
      credentials = []
      response = commit("key/", "get", {})
      
      raise ApiError unless response.success?
      
      for cred in response.data
        credentials.push(NephoRuby::Credential.new( :id => cred["id"],
                                                    :password => cred["password"],
                                                    :public_key => cred["public_key"],
                                                    :private_key => cred["private_key"],
                                                    :group => cred["group"]))
      end
      
      credentials
    end
  end
end