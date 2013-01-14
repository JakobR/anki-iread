
require 'net/http'
require 'html/pipeline'
require 'mime/types'

module AnkiIRead
  class ImageToAnkiFilter < HTML::Pipeline::Filter

    def call
      doc.search('img').each do |element|

        unless element['src']
          log 'img without src attribute!', false
          exit 1 # uhhhh... really?
        end

        target_uri = context[:uri] + element['src']

        log "Downloading image: #{target_uri}"

        response = Net::HTTP.get_response(target_uri)

        unless response.is_a? Net::HTTPSuccess
          raise RequestUnsuccessfulError, "GET request for #{target_uri} returned with error code #{response.code}."
        end

        type = MIME::Types[response.content_type].first
        unless type && type.media_type == "image"
          raise UnsupportedMIMETypeError, "The file at #{target_uri} (referenced by an <img> tag) is not an image!"
        end

        extension = type.extensions.first
        unless extension
          raise UnsupportedMIMETypeError, "There is no known file extension for MIME type '#{type}'."
        end

        filename = create_image_file(response.body, extension)
        log " => filename: #{filename}"

        element['src'] = filename
      end

      doc
    end # call


    private

    def create_image_file(contents, extension)
      digest = Digest::SHA1.hexdigest(contents)
      counter = 0

      loop do
        counter_str = (counter > 0) ? "-#{counter}" : ''
        filename = "iread-#{digest}#{counter_str}.#{extension}"
        full_path = ::File.expand_path(filename, context[:media_folder])
        log " => trying full path: #{full_path}"

        # Don't overwrite existing files
        # Don't save duplicates
        if File.exists? full_path
          if FileUtils.compare_file_to_string(full_path, contents)
            log " => file exists, ok"
            return filename
          end
        else
          log " => ok"
          File.write(full_path, contents)
          on_file_creation full_path
          return filename
        end

        counter += 1
      end
    end # create_image_file

    def log(message, verbose=true)
      context[:logger].call(message, verbose) if context[:logger]
    end

    def on_file_creation(file_name)
      context[:on_file_creation].call(file_name) if context[:on_file_creation]
    end
  end
end
