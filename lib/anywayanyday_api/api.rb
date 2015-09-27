module Anywayanyday
  class Api
    include Anywayanyday::Api::Request
    include Anywayanyday::Api::Fare

    attr_reader :config
    attr_accessor :request_id

    def initialize(config = {})
      @config = Anywayanyday.config
      for k,v in config
        @config[k.to_sym] = v
      end
    end
  end
end
