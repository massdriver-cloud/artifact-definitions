#! /usr/bin/env ruby

require 'json'
require 'base64'
require 'fileutils'

def process_artifact(json_path)
  dir_name = File.basename(json_path, '.json')
  dir_path = File.join(File.dirname(json_path), dir_name)

  return unless Dir.exist?(dir_path)

  json = JSON.parse(File.read(json_path))
  json['$md'] ||= {}
  json['$md']['ui'] ||= {}

  # Process icon
  if File.exist?(File.join(dir_path, 'icon.png'))
    github_base_path = "https://raw.githubusercontent.com/massdriver-cloud/artifact-definitions/refs/heads/main/definitions/artifacts/#{dir_name}/icon.png"
    json['$md']['icon'] = github_base_path
  end

  # Process markdown files
  json['$md']['ui']['instructions'] = []
  Dir.glob(File.join(dir_path, '*.md')).each do |md_file|
    label = File.basename(md_file, '.md')
    content = Base64.strict_encode64(File.read(md_file))

    json['$md']['ui']['instructions'] << {
      'label' => label,
      'content' => content
    }
  end

  # Process template files
  json['$md']['export'] = []
  Dir.glob(File.join(dir_path, '*.tmpl')).each do |tmpl_file|
    filename = File.basename(tmpl_file)
    parts = filename.split('.')

    # Extract download button text and file format
    download_button_text = parts[0]
    file_format = parts[1]
    template_language = parts[2]


    content = Base64.strict_encode64(File.read(tmpl_file))

    json['$md']['export'] << {
      'downloadButtonText' => download_button_text,
      'fileFormat' => file_format,
      'template' => content,
      'templateLang' => template_language
    }
  end

  # Write back the modified JSON
  File.write(json_path, JSON.pretty_generate(json))
end

# Process all JSON files in the artifacts directory
artifacts_dir = File.join('definitions', 'artifacts')
Dir.glob(File.join(artifacts_dir, '*.json')).each do |json_file|
  process_artifact(json_file)
end
