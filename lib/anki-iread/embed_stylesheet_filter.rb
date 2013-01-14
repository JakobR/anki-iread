
require 'net/http'
require 'html/pipeline'
require 'base64'

module AnkiIRead
  class EmbedStylesheetFilter < HTML::Pipeline::Filter

    def call
      doc.search('link').each do |element|

        next unless element['rel'] == 'stylesheet'
        next unless element['href']

        target_uri = context[:uri] + element['href']
        log "Embedding stylesheet: #{target_uri}"
        element['href'] = target_to_data_uri(target_uri)
      end

      doc
    end # call


    private

    def target_to_data_uri(target_uri)

      response = Net::HTTP.get_response(target_uri)

      unless response.is_a? Net::HTTPSuccess
        raise RequestUnsuccessfulError, "GET request for #{target_uri} returned with error code #{response.code}."
      end

      base64_data = Base64.strict_encode64(response.body)

      "data:#{response.content_type};base64,#{base64_data}"
    end # target_to_data_uri

    def log(message, verbose=true)
      context[:logger].call(message, verbose) if context[:logger]
    end

  end
end
