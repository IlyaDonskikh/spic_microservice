class PictureResponder < ApplicationResponder
  topic :sharing_picture_completed

  def respond(id, type, file_url, cover_type)
    #  respond_to :sharing_picture_completed, {
    #    object_id: id,
    #    object_type: type,
    #    file_url: file_url,
    #    picture_type: picture_type
    #  }
  end
end
