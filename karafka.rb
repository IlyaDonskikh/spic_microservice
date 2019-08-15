# frozen_string_literal: true

# Setup
require 'dotenv'
Dotenv.load

require 'sidekiq'

ENV['RACK_ENV'] ||= 'development'
ENV['KARAFKA_ENV'] ||= ENV['RACK_ENV']
Bundler.require(:default, ENV['KARAFKA_ENV'])
Karafka::Loader.load(Karafka::App.root)

class KarafkaApp < Karafka::App
  setup do |config|
    config.kafka.seed_brokers = ENV['KAFKA_SEED_BROKERS'].try(:split, ',')
    config.client_id = ENV['KAFKA_CLIENT_ID']
    config.backend = :inline
    config.batch_fetching = true
    config.root_dir = File.dirname(__FILE__)


    if ENV['KAFKA_TRUSTED_CERT']
      tmp_ca_file = Tempfile.new('kafka_ca_certs')
      tmp_ca_file.write(ENV.fetch("KAFKA_TRUSTED_CERT"))
      tmp_ca_file.close
      config.kafka.ssl_ca_cert_file_path = tmp_ca_file.path
    end

    ENV['KAFKA_CLIENT_CERT'] &&
      config.kafka.ssl_client_cert = ENV['KAFKA_CLIENT_CERT']
    ENV['KAFKA_CLIENT_CERT_KEY'] &&
      config.kafka.ssl_client_cert_key = ENV['KAFKA_CLIENT_CERT_KEY']
  end

  Karafka.monitor.subscribe(Karafka::Instrumentation::Listener)

  consumer_groups.draw do
    topic :spic_images_queuing do
      consumer ImagesQueuingConsumer
    end
  end
end

Dir[File.dirname(__FILE__) + '/config/initializers/*.rb'].each do |file|
  require file
end

KarafkaApp.boot!
