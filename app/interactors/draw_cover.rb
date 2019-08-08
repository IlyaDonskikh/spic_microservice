class DrawCover
  include Interactor

  ## Const
  REQUIRED_FILEDS = %w(project template sharing_type resource_type resource_id)
  DIMENSIONS_COVER = {
    vkontakte: { width: 510, height: 228 },
    facebook: { width: 600, height: 315 }
  }.freeze

  ## Etc.
  def call
    validate

    create_and_process_file
  end

  private

    def validate
      REQUIRED_FILEDS.each do |field|
        context.fail! message: "exists_#{field}" unless context[field]
      end

      context.fail! message: "template_error" unless File.file?(template_file)
    end

    def create_and_process_file
      jpeg = create_jpeg_by read_template
      file = save_to_file jpeg

      upload(file)
    ensure
      file&.unlink
    end

    def create_jpeg_by(html)
      kit = IMGKit.new(html, quality: 100, width: 100)

      kit.to_jpg
    end

    def save_to_file(jpeg)
      file = Tempfile.new(filename.split('.'), encoding: 'ascii-8bit')
      file.write(jpeg)
      file.flush

      file
    end

    def read_template
      file = File.read(template_file)
      erb = ERB.new file

      erb.result(binding)
    end

    def upload(file)
      uploader = PictureUploader.new(
        store_dir: store_dir,
        sharing_type: context.sharing_type,
        filename: filename
      )

      uploader.store! file

      context.file_url = uploader.url
    end

    def filename
      "#{context.sharing_type}.jpg"
    end

    def template_file
      File.join(
        KarafkaApp.config.root_dir,
        'app',
        'templates',
        context.project.to_s,
        context.template.to_s,
        "#{context.sharing_type}.html.erb"
      )
    end

    def store_dir
      File.join(
        context.project, context.template, context.resource_type, context.resource_id.to_s
      )
    end
end
