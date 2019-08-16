# frozen_string_literal: true

# Setup
if ENV['RACK_ENV'] != 'production'
  require 'dotenv'
  Dotenv.load
end

require 'sidekiq'

ENV['RACK_ENV'] ||= 'development'
ENV['KARAFKA_ENV'] ||= ENV['RACK_ENV']
Bundler.require(:default, ENV['KARAFKA_ENV'])
Karafka::Loader.load(Karafka::App.root)

class KarafkaApp < Karafka::App
  setup do |config|
    config.root_dir = File.dirname(__FILE__)
    config.kafka.seed_brokers = ENV['KAFKA_SEED_BROKERS'].try(:split, ',')
    config.client_id = ENV['KAFKA_CLIENT_ID']
    config.backend = :inline
    config.batch_fetching = true
    config.shutdown_timeout = 20

    if ENV['KAFKA_TOPIC_PREFIX']
      config.topic_mapper = KarafkaTopicMapper.new ENV['KAFKA_TOPIC_PREFIX'].to_s
      config.consumer_mapper = proc { |name| "#{ENV['KAFKA_TOPIC_PREFIX']}#{name}" }
    end

    config.kafka.start_from_beginning = false

    ENV['KAFKA_SSL_CERT_FROM_SYSTEM'] &&
      config.kafka.ssl_ca_certs_from_system = true

    config.kafka.sasl_scram_username = ENV['KAFKA_USERNAME']
    config.kafka.sasl_scram_password = ENV['KAFKA_PASSWORD']
    config.kafka.sasl_scram_mechanism = ENV['KAFKA_MECHANISM']

    if ENV['KAFKA_TRUSTED_CERT']
      tmp_ca_file = CertificateBuilder.call(
        'ca_certs', ENV.fetch("KAFKA_TRUSTED_CERT"), config.kafka.ssl_ca_cert_file_path
      )

      config.kafka.ssl_ca_cert_file_path = tmp_ca_file
    end

    config.kafka.ssl_client_cert = ENV['KAFKA_CLIENT_CERT']
    config.kafka.ssl_client_cert_key = ENV['KAFKA_CLIENT_CERT_KEY']
  end

  Karafka.monitor.subscribe(Karafka::Instrumentation::Listener)

  consumer_groups.draw do
    consumer_group :image_dealers do
      topic :spic_images_queuing do
        consumer ImagesQueuingConsumer
      end
    end
  end
end

Dir[File.dirname(__FILE__) + '/config/initializers/*.rb'].each do |file|
  require file
end

KarafkaApp.boot!
