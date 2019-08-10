RSpec.describe Project::TestBuddy::DefaultTemplate::DrawCover do
  before :all do
    @sharing_type = DrawCover::SHARING_TYPES[0]
    @resource_type = 'test'
    @resource_id = 1
  end

  it 'should fail if has template body errors' do
    attrs = default_request_attrs.merge(template_body: wrong_template_body)

    obj = Project::TestBuddy::DefaultTemplate::DrawCover.call(attrs)

    expect(obj.message).to eq('exists_surname')
    expect(obj.failure?).to be(true)
  end

  it 'should create a file' do
    attrs = default_request_attrs.merge(template_body: template_body)

    obj = Project::TestBuddy::DefaultTemplate::DrawCover.call(attrs)

    expect(File).to exist(obj.file_url)
  end

  private

    def default_request_attrs
      {
        project: @project,
        template: @template,
        sharing_type: @sharing_type,
        resource_type: @resource_type,
        resource_id: @resource_id
      }
    end

    def template_body
      {
        'title' => 'Spic',
        'tagline' => 'Spic Microservice',
        'background_url' => background_url,
        'info' => { 'core_gems' => %w(Karafka MiniMagic ImgKit Carrierwave) },
        'author' => [
          { 'name' => 'Ilia', 'surname' => 'Donskikh' }
        ]
      }
    end

    def wrong_template_body
      template_body.merge(
        'author' => [
          { 'name' => 'Ilia', 'surname' => 'Donskikh' },
          { 'name' => 'Ilia', 'surname1' => 'Donskikh' }
        ]
      )
    end

    def background_url
      'https://doniv-shared-pictures.s3.eu-central-1.amazonaws.com/spic/spic_ms_background.jpg'
    end
end
