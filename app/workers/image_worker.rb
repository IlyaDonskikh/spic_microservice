class ImageWorker < ApplicationWorker
  def perform(params)
    DrawCover.call(params)
  end
end
