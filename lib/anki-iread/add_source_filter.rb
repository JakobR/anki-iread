
require 'html/pipeline'

module AnkiIRead
  class AddSourceFilter < HTML::Pipeline::Filter

    def call
      doc << Nokogiri::HTML::DocumentFragment.parse(<<-HTML)
\n\n
<hr class="anki-iread">
Source: #{context[:uri]}
      HTML

      doc
    end # call

  end
end
