require 'imgkit'

IMGKit.configure do |config|
  config.wkhtmltoimage = Rails.root.join('bin', 'wkhtmltoimage-amd64').to_s if ENV['KARAFKA_ENV'] == 'production'
end
