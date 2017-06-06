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

  def initialize(file_path, type, media_url)
    @logger ||= fetch_or_create_log
    @logger.info "-------- Starting upload session --------"
    @input_file = file_path
    @media_url = media_url
    @client = MediaSession.fetch(@logger)

    setup_media_upload
  end

  def setup_media_upload
    @logger.info "-------- Processing upload of file at: #{@input_file} --------"
    @logger.info "File metadata: Owner=#{USER_OWNER_ID} Name=#{KALTURA_NAME} Description=#{KALTURA_DESC}"

    media = upload_media_by_url(@input_file, KALTURA_NAME, KALTURA_DESC, KALTURA_TAGS)
    # media = upload_media_by_file(@input_file, KALTURA_NAME, KALTURA_DESC, KALTURA_TAGS)

    unless media.nil?
      media.add_um_required_metadata(@logger)
      @logger.info "#{media.id} :: #{media.download_url}"
    else
      @logger.info "FILE NOT FOUND"
    end
  end

  def upload_media_by_url(file, name, desc, tags)
    # media_entry = Kaltura::KalturaMediaEntry.new
    media_entry = KalturaMediaEntry.new
    media_entry.media_type = Kaltura::KalturaMediaType::IMAGE
    media_entry.source_type = Kaltura::KalturaSourceType::URL
    media_entry.name = name
    media_entry.description = desc
    media_entry.tags = tags
    media_entry.user_id = USER_OWNER_ID
    media_entry.creator_id = USER_OWNER_ID

    unless @media_url.nil?
      @logger.info "Adding media entry..."
      entry = @client.media_service.add_from_url(media_entry, @media_url)
      entry
    else
      nil
    end
  end

  def upload_media_by_file
    media_entry = KalturaMediaEntry.new
    media_entry.media_type = Kaltura::KalturaMediaType::IMAGE
    media_entry.source_type = Kaltura::KalturaSourceType::FILE
    media_entry.name = name
    media_entry.description = desc
    media_entry.tags = tags
    media_entry.user_id = USER_OWNER_ID
    media_entry.creator_id = USER_OWNER_ID

    if File.exists?(file)
      file_contents = File.open(file)
      @logger.info "Uploading file... #{file}"
      upload = @client.media_service.upload(file_contents)
      @logger.info "Adding media entry for #{file}"
      entry = @client.media_service.add_from_uploaded_file(media_entry, upload)
      entry
    else
      nil
    end
  end

private

  def fetch_or_create_log
    log_file = "#{Rails.root}/log/kaltura.log"
    f = File.exists?(log_file) ? File.open(log_file, File::WRONLY | File::APPEND) : File.new(log_file, 'w')
    logger ||= Logger.new(f)
    logger.formatter = Logger::Formatter.new
    logger
  end

end
