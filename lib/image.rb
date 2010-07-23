module NephoRuby
  class Image
    attr_accessor :agent, :deployable_type, :default, :creation_time, :id, :max_cpu, :active, :base_type, :max_memory, :name, :arch
    
    def initialize(options = {})
      self.agent = options[:agent]
      self.deployable_type = options[:deployable_type]
      self.default = options[:default]
      self.creation_time = options[:create_time]
      self.id = options[:id]
      self.max_cpu = options[:max_cpu]
      self.active = options[:active]
      self.base_type = options[:base_type]
      self.max_memory = options[:max_memory]
      self.name = options[:name]
      self.arch = options[:arch]
    end
    
    def has_agent?
      !!self.agent
    end
    
    def default?
      !!self.default
    end
    
    def active?
      !!self.active
    end
  end
end