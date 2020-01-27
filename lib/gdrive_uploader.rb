#!/usr/bin/env ruby

# frozen_string_literal: true

require_relative './gdrive_uploader/system_runner'

# Upload file to gdrive
class GdriveUploader
  def initialize(runner)
    @system_runner = runner
  end

  def check_file_validity(file_path)
    abort("Can't find file at #{file_path}") unless File.exist?(file_path)
  end

  def upload(file_path, filename, directory_id)
    check_file_validity(file_path)

    # p "uploading file #{file_path} with filename #{filename}"
    command = "gdrive upload --share -p \"#{directory_id}\" --name \"#{filename}\" \"#{file_path}\""
    command += " |  grep -i https | cut -d' ' -f7"
    share_link = @system_runner.run_with_output command
    share_link
  end

  def update(file_path, filename, file_id)
    check_file_validity(file_path)

    # p "updating #{filename} using file #{file_path} with file id #{file_id}"
    command = "gdrive update --name \"#{filename}\" \"#{file_id}\" \"#{file_path}\""
    @system_runner.run command
  end

  def get_file_id(directory_id, filename_prefix)
    ## Get FILEID of the file with same filename_prefix if exists
    command = "gdrive list -q \"name contains '#{filename_prefix}' and '#{directory_id}' in parents\" "
    command += "--order \"modifiedTime desc\" -m 1 --no-header | awk '{print $1;}'"
    file_id = @system_runner.run_with_output command
    file_id
  end
end
