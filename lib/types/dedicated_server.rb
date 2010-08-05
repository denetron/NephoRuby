module NephoRuby
  class DedicatedServer < Server
    attr_accessor :in_stock
    
    def intialize(options = {})
      self.in_stock = options[:in_stock]
      
      super
    end
    
    def in_stock?
      !!self.in_stock
    end
  end
end