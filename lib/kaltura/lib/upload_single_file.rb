# encoding: UTF-8

require 'rest-client'
require 'shoulda'
require 'yaml'
require 'kaltura'

include Kaltura

class UploadSingleFile
  include Logging

  USER_OWNER_ID = "johnathb"
  KALTURA_NAME = "Uploaded from LRC: #{Time.now.to_s}"
  KALTURA_DESC = "Uploaded from LRC: #{Time.now.to_s}"
  KALTURA_TAGS = "lrc"
  UPLOAD_MODE = "url" # Set this according to upload method 'url' or 'file'

  def initialize(file_path, media_url, type)
    logger.info "-------- Starting KALTURA upload session --------"

    @file_location = UPLOAD_MODE == 'url' ? media_url : file_path
    @file_type = type
    @client = MediaSession.fetch
    @media_id = setup_media_upload
  end

  def fetch_media_id
    @media_id
  end

private

  def setup_media_upload
    logger.info "-------- Processing upload of #{@file_type} file at: #{@file_location} --------"
    logger.info "File metadata: Owner=#{USER_OWNER_ID} Name=#{KALTURA_NAME} Description=#{KALTURA_DESC}"

    media_url = nil
    media_id = nil

    begin

      media_entry = fetch_media_entry
      media = UPLOAD_MODE == 'url' ? upload_media_by_url(media_entry) : upload_media_by_file(media_entry)

      unless media.nil?
        media_id = media.id
        media.add_um_required_metadata
        logger.info "File uploaded - ID: #{media_id} :: URL: #{media.download_url}"
      else
        logger.info "FILE NOT FOUND: #{@file_location}"
      end

    rescue StandardError => e
      logger.error e.message
    end

    media_id
  end

  def upload_media_by_url(media_entry)
    unless @file_location.nil?
      logger.info "Uploading file by URL..."
      entry = @client.media_service.add_from_url(media_entry, @file_location)
      entry
    else
      nil
    end
  end

  def upload_media_by_file(media_entry)
    if File.exists?(@file_location)
      file_contents = File.open(@file_contents)
      logger.info "Uploading file via local storage..."
      upload = @client.media_service.upload(@file_contents)
      logger.info "Adding media entry..."
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

end
