RSpec.describe DrawCover do
  before :all do
    @project = 'test_buddy'
    @template = 'default'
    @sharing_type = DrawCovers::SHARING_TYPES[0]
  end

  it 'should create file jpg' do
    cover = DrawCover.call(
      project: @project,
      template: @template,
      sharing_type: @sharing_type
    )

    p cover.message

    expect(cover.file).to eq('file.jpg')
  end
end
