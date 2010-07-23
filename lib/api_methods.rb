module NephoRuby
  module ApiMethods
    def get_servers(type)
      servers = []
      
      case type
      when :cloud
        response = commit("server/cloud/", "get", {})
        
        for vm in response.data
          #     attr_accessor :agent, :deployable_type, :default, :creation_time, :id, :max_cpu, :active, :base_type, :max_memory, :name, :arch
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
                                                    :os =>            vm["image"]["friendly_name"],
                                                    :arch =>          vm["image"]["architecture"],
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
      case server.class
      when ::NephoRuby::CloudServer
        
      when ::NephoRuby::DedicatedServer
        
      else
        raise InvalidServerType "Only cloud or dedicated server types can be added"
      end
    end
  end
end