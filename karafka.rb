# frozen_string_literal: true


# Setup
require 'dotenv'
Dotenv.load('.env.development')
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
    # Uncomment this for Rails app integration
    # config.logger = Rails.logger
  end

  after_init do |config|
    # Put here all the things you want to do after the Karafka framework
    # initialization
  end

  # Comment out this part if you are not using instrumentation and/or you are not
  # interested in logging events for certain environments. Since instrumentation
  # notifications add extra boilerplate, if you want to achieve max performance,
  # listen to only what you really need for given environment.
  Karafka.monitor.subscribe(Karafka::Instrumentation::Listener)

  consumer_groups.draw do
    topic :sharing_pictures do
      consumer SharingPicturesConsumer
    end
  end
end

KarafkaApp.boot!
