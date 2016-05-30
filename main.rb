#!/usr/bin/env ruby

# usage
# uploader.rb storage_account access_key container_name uploading_folder

puts "storage_account: #{storage_account = ARGV[0]}"
puts "access_key: #{access_key = ARGV[1]}"
puts "container_name: #{container_name = ARGV[2]}"
puts "uploading_folder: #{uploading_folder = ARGV[3]}"

require 'find'
require 'pathname'
require 'open3'

uploading_folder = Pathname.new uploading_folder

Find.find(uploading_folder) do |file|
  file = Pathname.new(file)

  # ignore directory
  next if file.directory?

  # ignore path start with '.'
  next if file.to_s.start_with? '.'
  next if file.basename.to_s.start_with? '.'
  puts relative_path = file.relative_path_from(uploading_folder)
  next if relative_path.to_s.start_with? '.'

  puts "UPLOADING #{relative_path}"

  upload_cmd = "azure storage blob upload --account-name #{storage_account} --account-key #{access_key} --container #{container_name} --file #{file} --blob #{relative_path}"
  puts upload_cmd
  stdout, stderr, status = Open3.capture3 upload_cmd
  if status.exitstatus == 0
    puts 'OK'
  else
    puts 'ERR'
    puts stderr
  end
end
