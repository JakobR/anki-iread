
require 'uri'
require 'net/http'
require 'html/pipeline'

module AnkiIRead
  class App

    attr_reader :uri
    attr_reader :media_folder
    attr_reader :page_source
    attr_reader :html_output

    # A lambda with two parameters:
    # 1. the message that is to be logged
    # 2. a boolean which is true iff the message should only be shown in verbose mode
    attr_accessor :logger

    def initialize(the_uri, the_media_folder)
      if the_uri.is_a? String
        the_uri = URI(the_uri)
      end

      unless the_uri.kind_of? URI::HTTP
        raise WrongURISchemeError, "Supports only HTTP and HTTPS URIs.\nDid you include the http:// or https:// scheme in the <url> parameter?"
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
        raise ResponseIsNotHTMLError, "Server didn't respond with 'text/html' contents."
      end

      @page_source = response.body

      # Without this line, sometimes this error occurs when writing the output:
      # "output error : unknown encoding ASCII-8BIT"
      # TODO: Fix this properly!
      @page_source.force_encoding 'UTF-8'

      pipeline = HTML::Pipeline.new [
        ImageToAnkiFilter
      ], {
        uri: uri,
        media_folder: media_folder,
        logger: logger || lambda { |_,_| } # Don't log anything by default
      }

      @html_output = pipeline.to_html(page_source)
    end # run

  end
end
