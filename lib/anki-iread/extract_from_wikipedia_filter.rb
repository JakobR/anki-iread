
require 'html/pipeline'

module AnkiIRead
  class ExtractFromWikipediaFilter < HTML::Pipeline::Filter

    def self.is_applicable_to(uri)
      uri.host.end_with? "wikipedia.org" and
      uri.path.start_with? "/wiki/"
    end

    def call
      return doc unless ExtractFromWikipediaFilter.is_applicable_to context[:uri]

      log "This is a Wikipedia article... extracting content."

      # Remove elements
      [
        'span.editsection',
        'comment()'
      ].each do |selector|
        doc.css(selector).remove
      end

      doc
    end # call


    private

    def log(message, verbose=true)
      context[:logger].call(message, verbose) if context[:logger]
    end

  end
end