
require 'uri'
require 'net/http'

module AnkiIRead
  class App

    def initialize(uri)
      if uri.is_a? String
        uri = URI(uri)
      end

      unless uri.kind_of? URI::HTTP
        raise WrongURISchemeError
      end

      @uri = uri
    end

    def run
      response = Net::HTTP.get_response(@uri)

      unless response.is_a? Net::HTTPSuccess
        raise ResponseIsNotSuccessError
      end

      unless response.content_type == "text/html"
        raise ResponseIsNotHTMLError
      end

      @page_source = response.body
    end

  end
end
