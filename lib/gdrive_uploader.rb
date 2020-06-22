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

  def upload(file_path, file_name, directory_id, domain = '')
    check_file_validity(file_path)

    # p "uploading file #{file_path} with filename #{file_name}"
    upload_command = "gdrive upload -p \"#{directory_id}\""
    upload_command += " --name \"#{file_name}\" \"#{file_path}\""
    @system_runner.run_with_output upload_command

    file_id = share_file(directory_id, file_name, domain)
    share_link = get_share_link(file_id)
    share_link
  end

  def update(file_path, file_name, file_id)
    check_file_validity(file_path)

    # p "updating #{file_name} using file #{file_path} with file id #{file_id}"
    command = "gdrive update --name \"#{file_name}\" \"#{file_id}\" \"#{file_path}\""
    @system_runner.run command
  end

  def upload_or_update(file_path, file_name, directory_id, domain = '')
    file_id = get_file_id(directory_id, file_name)
    if file_id.empty?
      upload(file_path, file_name, directory_id, domain)
    else
      update(file_path, file_name, file_id)
    end
  end

  def get_file_id(directory_id, file_name_prefix)
    ## Get FILEID of the file with same file_name_prefix if exists
    command = "gdrive list -q \"name contains '#{file_name_prefix}' and '#{directory_id}' in parents\" "
    command += "--order \"modifiedTime desc\" -m 1 --no-header | awk '{print $1;}'"
    file_id = @system_runner.run_with_output command
    file_id
  end

  def download(file_path: '.', file_name:, directory_id: 'root')
    file_id = get_file_id(directory_id, file_name)
    abort "#{file_name} not found in directory id #{directory_id}" unless file_id

    command = "gdrive download -f -r --path \"#{file_path}\" \"#{file_id}\""
    @system_runner.run command
  end

  def share_file(directory_id, file_name, domain = '')
    file_id = get_file_id(directory_id, file_name)
    unless file_id.to_s.empty?
      share_command = 'gdrive share'
      unless domain.to_s.empty?
        share_command += " --type domain --domain \"#{domain}\""
      end
      share_command += " \"#{file_id}\""
      @system_runner.run_with_output share_command
    end
    file_id
  end

  def get_share_link(file_id)
    share_link = ''
    unless file_id.to_s.empty?
      share_link = "https://drive.google.com/file/d/#{file_id}/view?usp=sharing"
    end
    share_link
  end
end
