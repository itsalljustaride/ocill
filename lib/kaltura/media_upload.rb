
module MediaUpload

  # Load files under lib folder
  Dir[File.dirname(__FILE__) + '/lib/*.rb'].each {|file| require file }

end
