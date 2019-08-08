require 'fog/aws'
require 'carrierwave'

CarrierWave.configure do |config|
  config.fog_provider = 'fog/aws'
  config.fog_credentials = {
    provider:              'AWS',
    aws_access_key_id:     ENV['AWS_ACCESS_KEY_ID'],
    aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
    use_iam_profile:       false,
    region:                ENV['AWS_S3_REGION']
  }
  config.fog_directory  = ENV['S3_BUCKET']
  config.fog_public     = false
  config.fog_attributes = { cache_control: "public, max-age=#{365.days.to_i}" }

  config.storage = ENV['STORAGE_TYPE'].try(:to_sym)
  config.storage = :file if !config.storage || ENV['KARAFKA_ENV'] == 'test'

  if config.storage == CarrierWave::Storage::File
    folder_name = ENV['KARAFKA_ENV'] == 'test' ? 'spec' : 'public'

    config.asset_host = File.join(KarafkaApp.config.root_dir, folder_name)
    config.root = Proc.new { File.join(KarafkaApp.config.root_dir, folder_name) }
  end
end
