
require 'uri'
require 'net/http'
require 'html/pipeline'

module AnkiIRead
  class App

    attr_reader :uri
    attr_reader :media_folder
    attr_reader :page_source
    attr_reader :html_output

    def initialize(the_uri, the_media_folder)
      if the_uri.is_a? String
        the_uri = URI(the_uri)
      end

      unless the_uri.kind_of? URI::HTTP
        raise WrongURISchemeError
      end

      @uri = the_uri
      @media_folder = the_media_folder
    end # initialize

    def run
      response = Net::HTTP.get_response(uri)

      unless response.is_a? Net::HTTPSuccess
        raise RequestUnsuccessfulError, "GET request for #{uri} returned with error code #{response.code}."
      end

      unless response.content_type == "text/html"
        raise ResponseIsNotHTMLError
      end

      @page_source = response.body

      pipeline = HTML::Pipeline.new [
        ImageToAnkiFilter
      ], {
        uri: uri,
        media_folder: media_folder
      }

      @html_output = pipeline.to_html(page_source)
    end # run

  end
end
