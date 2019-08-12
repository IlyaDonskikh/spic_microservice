class ImageWorker < ApplicationWorker
  def perform(params)
    ConsumerContentRouter.call(
      project: params['project'],
      template: params['template'],
      content: params
    )
  end
end
