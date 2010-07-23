module NephoRuby
  class Response
    attr_accessor :message, :data, :success
    
    def initialize(options = {})
      self.message  = options[:message]
      self.data     = options[:data]
      self.success  = options[:success]
    end
    
    def data
      self.data
    end
    
    def success?
      !!self.success
    end
    
    def failure?
      !self.success
    end
  end
end