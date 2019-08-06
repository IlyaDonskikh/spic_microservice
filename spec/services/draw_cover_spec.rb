RSpec.describe SharingPicturesConsumer do
  it 'should create file jpg' do
    cover = DrawCover.call

    expect(cover.file).to eq('file.jpg')
  end
end
