RSpec.describe DrawCover do
  before :all do
    @project = 'test_buddy'
    @template = 'default'
    @sharing_type = DrawCovers::SHARING_TYPES[0]
    @resource_type = 'test'
    @resource_id = 1
  end

  it 'should create a file' do
    cover = DrawCover.call(
      project: @project,
      template: @template,
      sharing_type: @sharing_type,
      resource_type: @resource_type,
      resource_id: @resource_id
    )

    expect(File).to exist(cover.file_url)
  end
end
