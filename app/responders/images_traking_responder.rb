class ImagesTrakingResponder < ApplicationResponder
  topic :spic_images_tracking

  def respond(data)
    respond_to :spic_images_tracking, data
  end
end
