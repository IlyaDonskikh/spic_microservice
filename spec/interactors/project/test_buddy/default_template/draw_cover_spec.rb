RSpec.describe Project::TestBuddy::DefaultTemplate::DrawCover do
  before :all do
    @sharing_type = :facebook
    @resource_type = 'test'
    @resource_id = 1
  end

  it 'should fail if has template body errors' do
    attrs = default_request_attrs.merge(template_body: wrong_template_body)

    obj = Project::TestBuddy::DefaultTemplate::DrawCover.call(attrs)

    expect(obj.message).to eq('exists_lastname')
    expect(obj.failure?).to be(true)
  end

  it 'should create a facebook file' do
    attrs = default_request_attrs.merge(template_body: template_body)

    obj = Project::TestBuddy::DefaultTemplate::DrawCover.call(attrs)

    expect(File).to exist(obj.file_url)
  end

  it 'should create a vkontakte file' do
    @sharing_type = :vkontakte
    attrs = default_request_attrs.merge(template_body: template_body)

    obj = Project::TestBuddy::DefaultTemplate::DrawCover.call(attrs)

    expect(File).to exist(obj.file_url)
  end

  private

    def default_request_attrs
      {
        project: @project,
        template: @template,
        sharing_type: @sharing_type.to_s,
        resource_type: @resource_type,
        resource_id: @resource_id
      }
    end

    def template_body
      {
        'title' => 'Spic Microservice',
        'tagline' => 'Smart way to make sharing content',
        'background_url' => background_url,
        'info' => template_body_info_data,
        'author' => [
          { 'firstname' => 'Ilia', 'lastname' => 'Donskikh' }
        ]
      }
    end

    def wrong_template_body
      template_body.merge(
        'author' => [
          { 'firstname' => 'Ilia', 'lastname' => 'Donskikh' },
          { 'firstname' => 'Ilia', 'lastname1' => 'Donskikh' }
        ]
      )
    end

    def template_body_info_data
      {
        'core_gems' => {
          'title' => 'Core Gems:',
          'text' => 'Karafka, MiniMagic, ImgKit, Carrierwave).' },
        'github_address' => {
          'title' => 'Github Address:',
          'text' => 'ilyadonskikh/spic_microservice' }
      }
    end

    def background_url
      'https://doniv-shared-pictures.s3.eu-central-1.amazonaws.com/spic/spic_ms_background.jpg'
    end
end
