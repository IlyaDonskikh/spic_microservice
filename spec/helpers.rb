module Helpers
  def remove_uploads_test_dir
    image_dir = File.join(KarafkaApp.config.root_dir, 'spec', 'uploads')

    return unless File.exists?(image_dir)

    FileUtils.remove_dir(image_dir)
  end

  def stub_kafka_responders
    allow_any_instance_of(Project::TestBuddy::DefaultTemplate::DrawCover)
      .to receive(:produce_kafka_message)
  end


  def picture_template_body
    {
      'title' => 'Spic Microservice',
      'tagline' => 'Smart way to make sharing content',
      'background_url' => picture_template_body_background_url,
      'info' => picture_template_body_info_data,
      'author' => [
        { 'firstname' => 'Ilia', 'lastname' => 'Donskikh' }
      ]
    }
  end

  def picture_template_body_info_data
    {
      'core_gems' => {
        'title' => 'Core Gems:',
        'text' => 'Karafka, MiniMagic, ImgKit, Carrierwave).' },
      'github_address' => {
        'title' => 'Github Address:',
        'text' => 'ilyadonskikh/spic_microservice' }
    }
  end

  def picture_template_body_background_url
    'https://doniv-shared-pictures.s3.eu-central-1.amazonaws.com/spic/spic_ms_background.jpg'
  end
end
