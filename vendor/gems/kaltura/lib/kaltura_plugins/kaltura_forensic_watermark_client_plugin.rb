# ===================================================================================================
#                           _  __     _ _
#                          | |/ /__ _| | |_ _  _ _ _ __ _
#                          | ' </ _` | |  _| || | '_/ _` |
#                          |_|\_\__,_|_|\__|\_,_|_| \__,_|
#
# This file is part of the Kaltura Collaborative Media Suite which allows users
# to do with audio, video, and animation what Wiki platfroms allow them to do with
# text.
#
# Copyright (C) 2006-2017  Kaltura Inc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http:#www.gnu.org/licenses/>.
#
# @ignore
# ===================================================================================================
require 'kaltura_client.rb'

module Kaltura

	class KalturaDeliveryProfileForensicWatermark < KalturaDeliveryProfile
		# The URL used to pull manifest from the server, keyed by dc id, asterisk means all dcs
		attr_accessor :internal_url
		# The key used to encrypt the URI (256 bits)
		attr_accessor :encryption_key
		# The iv used to encrypt the URI (128 bits)
		attr_accessor :encryption_iv
		# The regex used to match the encrypted part of the URI (according to the 'encrypt' named group)
		attr_accessor :encryption_regex


		def from_xml(xml_element)
			super
			if xml_element.elements['internalUrl'] != nil
				self.internal_url = KalturaClientBase.object_from_xml(xml_element.elements['internalUrl'], 'KalturaKeyValue')
			end
			if xml_element.elements['encryptionKey'] != nil
				self.encryption_key = xml_element.elements['encryptionKey'].text
			end
			if xml_element.elements['encryptionIv'] != nil
				self.encryption_iv = xml_element.elements['encryptionIv'].text
			end
			if xml_element.elements['encryptionRegex'] != nil
				self.encryption_regex = xml_element.elements['encryptionRegex'].text
			end
		end

	end

	class KalturaForensicWatermarkAdvancedFilter < KalturaSearchItem
		attr_accessor :watermark_id

		def watermark_id=(val)
			@watermark_id = val.to_i
		end

		def from_xml(xml_element)
			super
			if xml_element.elements['watermarkId'] != nil
				self.watermark_id = xml_element.elements['watermarkId'].text
			end
		end

	end


end
