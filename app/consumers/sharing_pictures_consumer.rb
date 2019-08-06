class SharingPicturesConsumer < ApplicationConsumer
  def consume
    DrawCover.call params
  end
end
