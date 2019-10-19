RSpec.describe DrawCover do
  let(:project) { 'test_buddy' }
  let(:template) { 'default' }
  let(:sharing_type) { :facebook }
  let(:resource_type) { 'test' }
  let(:resource_id) { 1 }
  let(:template_body) { picture_template_body } # rspec helpers

  before :each do
    stub_kafka_responders # rspec helpers
  end

  it 'should create a file' do
    obj = DrawCover.call(request_attrs)

    expect(obj.file_url).not_to be_nil
    expect(File).to exist(obj.file_url)
  end

  context 'template body has erros' do
    before :each do
      @attrs = request_attrs.merge(template_body: wrong_template_body)
    end

    it 'should fail' do
      obj = DrawCover.call(@attrs)

      expect(obj.message).to eq('template_render')
      expect(obj.failure?).to be(true)
    end
  end

  context 'project has wrong name' do
    let(:project) { 'HeСalledMeWrong1' }

    it 'should fail' do
      obj = DrawCover.call(request_attrs)

      expect(obj.message).to eq('exists_template_files')
      expect(obj.failure?).to be(true)
    end
  end

  context 'template has wrong name' do
    let(:template) { 'HeСalledMeWrong1' }

    it 'should fail' do
      obj = DrawCover.call(request_attrs)

      expect(obj.message).to eq('exists_template_files')
      expect(obj.failure?).to be(true)
    end
  end

  context 'vkontakte file' do
    let(:sharing_type) { :vkontakte }

    it 'should create a file' do
      obj = DrawCover.call(request_attrs)

      expect(obj.file_url).not_to be_nil
      expect(File).to exist(obj.file_url)
    end
  end

  private

    def request_attrs
      attrs = {
        project: project,
        template: template,
        sharing_type: sharing_type.to_s,
        resource_type: resource_type,
        resource_id: resource_id
      }

      attrs.merge(template_body: template_body)
    end

    def wrong_template_body
      template_body.merge(
        'author' => nil
      )
    end
end
