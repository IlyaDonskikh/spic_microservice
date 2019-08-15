require 'imgkit'

IMGKit.configure do |config|
  wkhtmltoimage_path =
    File.join(
      KarafkaApp.config.root_dir,
      'bin',
      'wkhtmltoimage-amd64'
    ).to_s

  config.wkhtmltoimage = wkhtmltoimage_path if ENV['KARAFKA_ENV'] == 'production'
end
