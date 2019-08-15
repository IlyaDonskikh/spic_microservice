RSpec.describe DrawCover do
  before :all do
    @project = 'test_buddy'
    @template = 'default'
    @sharing_type = :facebook
    @resource_type = 'test'
    @resource_id = 1
  end

  before :each do
    stub_kafka_responders # rspec helpers
  end

  it 'should fail if has template body errors' do
    attrs = default_request_attrs.merge(template_body: wrong_template_body)

    obj = DrawCover.call(attrs)

    expect(obj.message).to eq('template_render')
    expect(obj.failure?).to be(true)
  end

  it 'should fail if project has a wrong name' do
    attrs = default_request_attrs.merge(
      project: 'HeСalledMeWrong1'
    )

    obj = DrawCover.call(attrs)

    expect(obj.message).to eq('exists_template_files')
    expect(obj.failure?).to be(true)
  end

  it 'should fail if template has a wrong name' do
    attrs = default_request_attrs.merge(
      template: 'HeСalledMeWrong1'
    )

    obj = DrawCover.call(attrs)

    expect(obj.message).to eq('exists_template_files')
    expect(obj.failure?).to be(true)
  end

  it 'should create a facebook file' do
    obj = DrawCover.call(default_request_attrs)

    expect(obj.file_url).not_to be_nil
    expect(File).to exist(obj.file_url)
  end

  it 'should create a vkontakte file' do
    @sharing_type = :vkontakte

    obj = DrawCover.call(default_request_attrs)

    expect(obj.file_url).not_to be_nil
    expect(File).to exist(obj.file_url)
  end

  private

    def default_request_attrs
      attrs = {
        project: @project,
        template: @template,
        sharing_type: @sharing_type.to_s,
        resource_type: @resource_type,
        resource_id: @resource_id
      }

      attrs.merge(template_body: template_body)
    end

    def template_body
      picture_template_body # rspec helpers
    end

    def wrong_template_body
      template_body.merge(
        'author' => nil
      )
    end
end
