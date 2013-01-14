
module AnkiIRead

  class Error < StandardError
  end

  class WrongURISchemeError < AnkiIRead::Error
  end

  class RequestUnsuccessfulError < AnkiIRead::Error
  end

  class ResponseIsNotHTMLError < AnkiIRead::Error
  end

  class UnsupportedMIMETypeError < AnkiIRead::Error
  end

end
