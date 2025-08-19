#!/usr/bin/env ruby

require 'json'
require 'net/http'
require 'uri'

def check_url_exists(url)
  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true if uri.scheme == 'https'
  http.open_timeout = 10
  http.read_timeout = 10

  request = Net::HTTP::Head.new(uri.request_uri)
  response = http.request(request)

  response.code.to_i == 200
rescue => e
  false
end

def validate_artifacts
  artifacts_dir = 'definitions/artifacts'
  json_files = Dir.glob(File.join(artifacts_dir, '*.json'))

  json_files.sort.each do |file|
    begin
      content = File.read(file)
      data = JSON.parse(content)

      filename = File.basename(file)
      md_section = data.dig('$md')

      if md_section.nil?
        puts "[WARN] #{filename.ljust(40)} - No $md section found"
        next
      end

      icon_url = md_section['icon']

      if icon_url.nil? || icon_url.empty?
        puts "[WARN] #{filename.ljust(40)} - No icon field"
      else
        if check_url_exists(icon_url)
          puts "[INFO] #{filename.ljust(40)} - #{icon_url}"
        else
          puts "[ERROR] #{filename.ljust(40)} - #{icon_url} (URL not accessible)"
        end
      end

    rescue JSON::ParserError => e
      puts "[ERROR] #{File.basename(file).ljust(40)} - Invalid JSON: #{e.message}"
    rescue => e
      puts "[ERROR] #{File.basename(file).ljust(40)} - Error: #{e.message}"
    end
  end
end

puts "Validating artifact icons...\n\n"
validate_artifacts
puts "\nValidation complete."
