
require 'net/http'
require 'html/pipeline'
require 'mime/types'

module AnkiIRead
  class ImageToAnkiFilter < HTML::Pipeline::Filter

    def call
      doc.search('img').each do |element|

        unless element['src']
          $stderr.puts 'img without src attribute!'
          exit 1 # uhhhh... really?
        end

        target_uri = context[:uri] + element['src']

        $stderr.puts "Downloading image: #{target_uri}"

        response = Net::HTTP.get_response(target_uri)

        unless response.is_a? Net::HTTPSuccess
          raise RequestUnsuccessfulError, "GET request for #{target_uri} returned with error code #{response.code}."
        end

        type = MIME::Types[response.content_type].first
        unless type && type.media_type == "image"
          $stderr.puts ' => ERROR'
          $stderr.puts ' => URL referenced by <img> tag is not an image!'
          exit 1 # ...
        end

        extension = type.extensions.first
        unless extension
          $stderr.puts ' => ERROR'
          $stderr.puts ' => No valid file extension available!'
          exit 1 # ...
        end

        filename = create_image_file(response.body, extension)
        $stderr.puts " => filename: #{filename}"

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
        $stderr.puts " => trying full path: #{full_path}"

        # Don't overwrite existing files
        # Don't save duplicates
        if File.exists? full_path
          if FileUtils.compare_file_to_string(full_path, contents)
            $stderr.puts " => file exists, ok"
            return filename
          end
        else
          $stderr.puts " => ok"
          File.write(full_path, contents)
          return filename
        end

        counter += 1
      end
    end # create_image_file

  end
end
