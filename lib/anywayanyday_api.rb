require 'rest_client'
require 'nokogiri'

require 'anywayanyday_api/request'
require 'anywayanyday_api/version'
require 'anywayanyday_api/fare'
require 'anywayanyday_api/api'
require 'anywayanyday_api/error'

class Hash
  def to_query(namespace = nil)
    collect do |key, value|
      value.to_query(namespace ? "#{namespace}[#{key}]" : key)
    end.sort * '&'
  end
end

module Anywayanyday
  class << self

    def configure
      yield config
    end

    def config
      @config ||= OpenStruct.new {}
    end

    def api(config = {})
      Anywayanyday::Api.new(config)
    end
  end
end
