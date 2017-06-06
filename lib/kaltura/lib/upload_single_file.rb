# encoding: UTF-8

require 'rest-client'
require 'shoulda'
require 'yaml'
require 'logger'
require 'kaltura'

include Kaltura

class UploadSingleFile

  USER_OWNER_ID = "johnathb"
  KALTURA_NAME = "Uploaded from LRC: #{Time.now.to_s}"
  KALTURA_DESC = "Uploaded from LRC: #{Time.now.to_s}"
  KALTURA_TAGS = "lrc"
  UPLOAD_MODE = "url" # Set this according to upload method 'url' or 'file'

  def initialize(file_path, media_url, type)
    @logger ||= fetch_or_create_log
    @logger.info "-------- Starting upload session --------"

    @file_location = UPLOAD_MODE == 'url' ? media_url : file_path
    @file_type = type
    @client = MediaSession.fetch(@logger)

    setup_media_upload
  end

private

  def setup_media_upload
    @logger.info "-------- Processing upload of file at: #{@file_location} --------"
    @logger.info "File metadata: Owner=#{USER_OWNER_ID} Name=#{KALTURA_NAME} Description=#{KALTURA_DESC}"

    media = UPLOAD_MODE == 'url' ? upload_media_by_url : upload_media_by_file

    unless media.nil?
      media.add_um_required_metadata(@logger)
      @logger.info "File uploaded:"
      @logger.info "#{media.id} :: #{media.download_url}"
    else
      @logger.info "FILE NOT FOUND: #{@file_location}"
    end
  end

  def upload_media_by_url
    media_entry = fetch_media_entry

    unless @file_location.nil?
      @logger.info "Uploading file by URL..."
      entry = @client.media_service.add_from_url(media_entry, @file_location)
      entry
    else
      nil
    end
  end

  def upload_media_by_file
    media_entry = fetch_media_entry

    if File.exists?(@file_location)
      file_contents = File.open(@file_contents)
      @logger.info "Uploading file via local storage... #{file}"
      upload = @client.media_service.upload(@file_contents)
      @logger.info "Adding media entry for #{file}"
      entry = @client.media_service.add_from_uploaded_file(media_entry, upload)
      entry
    else
      nil
    end
  end

  def fetch_media_entry
    entry = KalturaMediaEntry.new
    entry.media_type = media_type
    entry.source_type = UPLOAD_MODE == 'url' ? Kaltura::KalturaSourceType::URL : Kaltura::KalturaSourceType::FILE
    entry.name = KALTURA_NAME
    entry.description = KALTURA_DESC
    entry.tags = KALTURA_TAGS
    entry.user_id = USER_OWNER_ID
    entry.creator_id = USER_OWNER_ID
    entry
  end

  def media_type
    type = ''

    case @file_type
    when 'image'
      type = Kaltura::KalturaMediaType::IMAGE
    when 'audio'
      type = Kaltura::KalturaMediaType::AUDIO
    when 'video'
      type = Kaltura::KalturaMediaType::VIDEO
    end

    type
  end



  def fetch_or_create_log
    log_file = "#{Rails.root}/log/kaltura.log"
    f = File.exists?(log_file) ? File.open(log_file, File::WRONLY | File::APPEND) : File.new(log_file, 'w')
    logger ||= Logger.new(f)
    logger.formatter = Logger::Formatter.new
    logger
  end

end
