class ImagesQueuingConsumer < ApplicationConsumer
  def consume
    DrawCovers.call(
      object_info: params['object_info'],
      attrs: params['content'],
      settings: params['settings']
    )
  end
end
