#!/usr/bin/env ruby

# frozen_string_literal: true

require_relative 'test_helper'
require_relative '../lib/gdrive_uploader.rb'

# Test for gdrive uploader
class GdriveUploaderTest < Test::Unit::TestCase
  def setup
    @system_runner = TestSystemRunner.new
  end

  def test_get_file_id
    random_id = 'random_id'
    random_filename = 'last_daily_version.txt'
    app_id = GdriveUploader.new(@system_runner).get_file_id(random_id, random_filename)
    assert_not_nil(app_id, 'app id is nil')

    expected_command = "gdrive list -q \"name contains '#{random_filename}' and '#{random_id}' in parents\" "
    expected_command += "--order \"modifiedTime desc\" -m 1 --no-header | awk '{print $1;}'"
    assert @system_runner.running?(expected_command)
  end

  def test_update
    file_name = 'random_file'
    random_id = 'random_id'

    uploader = GdriveUploader.new(@system_runner)
    uploader.stubs(:check_file_validity).returns(true)
    uploader.update(file_name, file_name, random_id)
    expected_command = "gdrive update --name \"#{file_name}\" \"#{random_id}\" \"#{file_name}\""
    assert @system_runner.running?(expected_command)
  end

  def test_upload
    file_name = 'random_file'
    random_id = 'random_id'

    uploader = GdriveUploader.new(@system_runner)
    uploader.stubs(:check_file_validity).returns(true)
    uploader.expects(:share_file).once
    uploader.expects(:get_share_link).once
    uploader.upload(file_name, file_name, random_id)

    expected_command = "gdrive upload -p \"#{random_id}\""
    expected_command += " --name \"#{file_name}\" \"#{file_name}\""
    assert @system_runner.running?(expected_command)
  end

  def test_upload_or_update_should_call_upload
    uploader = GdriveUploader.new(@system_runner)
    uploader.stubs(:check_file_validity).returns(true)
    uploader.stubs(:get_file_id).returns('')

    uploader.expects(:upload).once
    uploader.upload_or_update('', '', '')
  end

  def test_upload_or_update_should_call_update
    uploader = GdriveUploader.new(@system_runner)
    uploader.stubs(:check_file_validity).returns(true)
    uploader.stubs(:get_file_id).returns('some_id')

    uploader.expects(:update).once
    uploader.upload_or_update('', '', '')
  end

  def test_check_file_validity
    assert_raises do
      GdriveUploader.new(@system_runner).check_file_validity('some_random_file.txt')
    end
  end

  def test_download
    file_path = 'somepath'
    file_name = 'somename'
    file_id = 'some_id'
    uploader = GdriveUploader.new(@system_runner)
    uploader.stubs(:get_file_id).returns(file_id)
    uploader.download(file_path: file_path,
                      file_name: file_name,
                      directory_id: 'dir_id')
    expected_command = "gdrive download -f -r --path \"#{file_path}\" \"#{file_id}\""
    assert @system_runner.running?(expected_command)
  end

  def test_share_file
    directory_id = 'some_dir_id'
    file_name = 'somename'
    file_id = 'some_id'
    domain = 'some_domain'
    uploader = GdriveUploader.new(@system_runner)
    uploader.stubs(:get_file_id).returns(file_id)
    uploader.share_file(directory_id, file_name, domain)

    expected_command = 'gdrive share'
    expected_command += " --type domain --domain \"#{domain}\""
    expected_command += " \"#{file_id}\""

    assert @system_runner.running?(expected_command)
  end

  def test_get_share_link_correct_link
    file_id = 'somerandomthings'
    uploader = GdriveUploader.new(@system_runner)
    expected = "https://drive.google.com/file/d/#{file_id}/view?usp=sharing"
    actual = uploader.get_share_link(file_id)
    assert_equal expected, actual
  end

  def test_get_share_link_empty_link
    file_id = ''
    uploader = GdriveUploader.new(@system_runner)
    expected = ''
    actual = uploader.get_share_link(file_id)
    assert_equal expected, actual
  end
end
