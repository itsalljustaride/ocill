class DeleteSingleFile
  include Logging

  def initialize(media_id, media_type)
    logger.info "-------- Starting KALTURA deletion session --------"
    @client = MediaSession.fetch
    @media_id = media_id
    @media_type = media_type
  end

  def delete
    logger.info "-------- Processing deletion of #{@media_type} file ID: #{@media_id}"
    @client.media_service.delete(@media_id)
  rescue StandardError => e
    logger.error e.message
  end

end
