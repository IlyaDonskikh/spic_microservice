require 'carrierwave'

CarrierWave.configure do |config|
  config.root = Proc.new { File.join(KarafkaApp.config.root_dir, 'public') }

  if ENV['KARAFKA_ENV'] == 'test'
    config.asset_host = File.join(KarafkaApp.config.root_dir, 'spec')
    config.root = Proc.new { File.join(KarafkaApp.config.root_dir, 'spec') }
  else
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
  end
end
