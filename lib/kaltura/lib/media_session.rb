require 'kaltura'

include Kaltura

module MediaSession
  include Logging

  ENV = 'test'

  def self.fetch
    logger.info("Fetching session ...")

    config_file = YAML.load_file("#{Rails.root}/config/kaltura_account.yml")
    partner_id = config_file[ENV]["partner_id"]
    service_url = config_file[ENV]["service_url"]
    administrator_secret = config_file[ENV]["administrator_secret"]
    timeout = config_file[ENV]["timeout"]

    service_url.gsub(/http:/, "https:/")

    config = Kaltura::KalturaConfiguration.new()
    config.service_url = service_url
    config.timeout = timeout

    client = Kaltura::KalturaClient.new(config)
    client.ks = client.session_service.start(administrator_secret, '', Kaltura::KalturaSessionType::ADMIN, partner_id)

    client
  end

end
