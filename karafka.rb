# frozen_string_literal: true

# Setup
require 'dotenv'
Dotenv.load

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
  end

  after_init do |config|
    # Put here all the things you want to do after the Karafka framework
    # initialization
  end

  Karafka.monitor.subscribe(Karafka::Instrumentation::Listener)

  consumer_groups.draw do
    topic :sharing_pictures do
      consumer SharingPicturesConsumer
    end
  end
end

Dir[File.dirname(__FILE__) + '/config/initializers/*.rb'].each do |file|
  require file
end

KarafkaApp.boot!
