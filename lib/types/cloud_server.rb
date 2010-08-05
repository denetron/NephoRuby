module NephoRuby
  class CloudServer < Server
    class << self
      def get(*args)
        case args.first
        when :all
          commit("server/cloud/", "get", {})
        end
      end
    end
    
    def initialize(options = {})
      super
    end
  end
end