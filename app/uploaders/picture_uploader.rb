class PictureUploader < CarrierWave::Uploader::Base
  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:

  def self.fog_public
    true
  end

  def store_dir
    "uploads/#{model[:store_dir]}"
  end

  def filename
    model[:filename]
  end

  # Process files as they are uploaded:
  process :cover_version

  def cover_version
    sharing_type = model[:sharing_type].to_sym
    size = DrawCover::DIMENSIONS_COVER[sharing_type]

    resize_to_fit(size[:width] * 2, size[:height] * 2)
  end
end
