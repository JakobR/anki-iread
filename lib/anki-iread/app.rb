
require 'uri'

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
    end

  end
end
