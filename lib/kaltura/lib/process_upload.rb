class ProcessUpload
  include Logging

  def initialize(file_location, url, media_type, model)
    @file_location = file_location
    @url = url
    @model = model
    @media_type = media_type
    @media_id = model.media_id
  end

  def run
    # Delete file if there is already an entry
    DeleteSingleFile.new(@model.media_id, @media_type).delete unless @media_id.nil?
    # Upload file
    media_id = UploadSingleFile.new(@file_location, @url, @media_type).fetch_media_id
    unless media_id.nil?
      @model.media_id = media_id
      @model.media_type = @media_type
      @model.save!
    else
      logger.error "Not able to save #{@file_location} in uploader"
    end
  end
end
