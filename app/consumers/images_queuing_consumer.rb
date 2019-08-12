class ImagesQueuingConsumer < ApplicationConsumer
  def consume
    ImageWorker.perform_async(params)
  rescue Karafka::Errors::ParserError => error
    Karafka.logger.error "Consumer Parse Error: #{params} #{error}"
  rescue TypeError => error
    Karafka.logger.error "Consumer Type Error: #{params} #{error}"
  end
end
