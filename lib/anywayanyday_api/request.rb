module Anywayanyday
  class Api
    module Request
      def request(resource, params)
        url = [config.host, resource, nil].join('/')
        params = Hash[params.map{|k,v| [k.to_s.size < 4 ? k.to_s.upcase : k.to_s.capitalize,v]}]
        response = RestClient.get url, {:params => params}
        # puts response.to_str
        data = Nokogiri::XML(response.to_str).root
        error_message = data['Error']
        if error_message
          err = Error.new
          err.message = error_message
          raise AnywayanydayError, err
        end
        data
      rescue RestClient::Exception => e
        err = Error.new(e.response, e.http_code)
        err.message = e.message
        raise err
      end
    end
  end
end