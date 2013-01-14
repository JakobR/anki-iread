
require 'stringio'
require 'fileutils'

module FileUtils
  extend self

  def compare_file_to_string(filename, string)
    File.open(filename, 'r') do |f_io|
      StringIO.open(string, 'r') do |s_io|
        FileUtils.compare_stream(f_io, s_io)
      end
    end
  end

end
