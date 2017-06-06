require 'Kaltura'

include Kaltura

class KalturaMediaEntry < KalturaPlayableEntry

  # def initialize
  #   super
  # end

  def add_um_required_metadata(logger)
    @logger =  logger
    @client = MediaSession.fetch(logger)
    config_file = YAML.load_file("#{Rails.root}/config/kaltura_metadata.yml")

    meta_entry_filter = Kaltura::KalturaMetadataBaseFilter.new
    meta_entry_filter.object_id_equal = self.id
    meta_filter_pager = Kaltura::KalturaFilterPager.new
    meta_filter_pager.page_size = 1

    profile_id = config_file["production"]["profile_id"]
    stewardship = config_file["production"]["stewardship"]
    rights = config_file["production"]["rights"]
    credits = config_file["production"]["credits"]
    creation_date = config_file["production"]["creation_date"]
    department_id = config_file["production"]["department_id"]
    shortcode = config_file["production"]["shortcode"]
    authorized_signer_uniqname = config_file["production"]["authorized_signer_uniqname"]

    meta = Nokogiri::XML::Builder.new do |xml|
      xml.metadata {
        xml.send(:"Stewardship", stewardship)
        xml.send(:"Rights", rights)
        xml.send(:"Credits", credits)
        xml.send(:"CreationDate", creation_date || Time.now.to_i.to_s)
        # xml.send(:"DepartmentID", department_id)
        # xml.send(:"Shortcode", shortcode)
        # xml.send(:"AuthorizedSignerUniqname", authorized_signer_uniqname)
        # xml.send(:"entitledUsersEdit", "johnathb" )
        # xml.send(:"entitledUsersPublish", "johnathb@umich.edu" )
      }
    end

    um_required_metadata = meta.doc.root.to_xml

    media_meta = @client.metadata_service.list(meta_entry_filter, meta_filter_pager)

    if media_meta.total_count > 0
      media_meta_id = media_meta.objects.first.id
      @client.metadata_service.update(media_meta_id, um_required_metadata)
    else
      @client.metadata_service.add(profile_id, Kaltura::KalturaMetadataObjectType::ENTRY, self.id, um_required_metadata)
    end
  end
end
