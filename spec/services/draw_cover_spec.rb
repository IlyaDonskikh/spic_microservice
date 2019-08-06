RSpec.describe SharingPicturesConsumer do
  it "should create file jpg" do
    p '22'
    cover = DrawCover.call

    expect(nil).to eq('file.jpg')
  end
end
