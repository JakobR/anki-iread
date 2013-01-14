
module AnkiIRead

  class WrongURISchemeError < StandardError
  end

  class RequestUnsuccessfulError < StandardError
  end

  class ResponseIsNotHTMLError < StandardError
  end

  class UnsupportedMIMETypeError < StandardError
  end

end
