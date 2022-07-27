require 'json'
require 'yml_reader'

module GlobalHelper
  def parse_number(string)
    string.gsub!(/\d+/, '')
  end

  def download_file(url, custom_filename = nil)
    download = URI.open url
    default_filename = download.meta['content-disposition'].split(' ').last.gsub('filename=', '')
    expected_file_size = download.meta['content-length']
    full_path = custom_filename.nil? ? "#{$download_path}#{default_filename}" : "#{$download_path}#{custom_filename}"
    actual_file_size = IO.copy_stream download, full_path

    if expected_file_size.to_i != actual_file_size.to_i # this means download is failed / corrupt
      File.delete(full_path) if File.exist?(full_path)
      raise IOError, "Download failed / corrupt. Expected #{expected_file_size} bytes but got #{actual_file_size}"
    end

    full_path
  end

  def read_pdf(file, level)
    io     = File.open(file)
    reader = PDF::Reader.new(io)

    case level
    when 'page'
      reader.page_count
    when 'info'
      reader.info
    when 'text'
      reader.pages.first.text
    end
  end

  def validate_json(response)
    JSON.parse(response)
    true
  rescue JSON::ParserError, TypeError
    false
  end

  def check_es(details, contact_data)
    return unless details.include? 'default_es'

    "?person_name=#{contact_data['person']['display_name']}".gsub!(/\s/, '+')
  end
end
