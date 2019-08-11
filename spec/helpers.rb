module Helpers
  def remove_uploads_test_dir
    image_dir = File.join(KarafkaApp.config.root_dir, 'spec', 'uploads')

    return unless File.exists?(image_dir)

    # FileUtils.remove_dir(image_dir)
  end
end
