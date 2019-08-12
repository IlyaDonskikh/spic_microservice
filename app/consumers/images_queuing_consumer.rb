class ImagesQueuingConsumer < ApplicationConsumer
  def consume
    ConsumerContentRouter.call(
      project: params['project'],
      template: params['template'],
      content: params
    )
  end
end
