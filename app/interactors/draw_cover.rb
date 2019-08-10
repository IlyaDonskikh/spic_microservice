class DrawCover
  include Interactor

  ## Const
  REQUIRED_FILEDS = %w(project template sharing_type resource_type resource_id).freeze
  SHARING_TYPES = %w(vkontakte facebook).freeze
  DIMENSIONS_COVER = {
    vkontakte: { width: 510, height: 228 },
    facebook: { width: 600, height: 315 }
  }.freeze

  ## Etc.
  def call
    extend_context
    validate

    create_and_process_file
  end

  private

    def extend_context; end

    def validate
      REQUIRED_FILEDS.each do |field|
        context.fail! message: "exists_#{field}" unless context[field]
      end

      unless SHARING_TYPES.include?(context.sharing_type)
        context.fail! message: "include_sharing_type"
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
      width = DIMENSIONS_COVER[context.sharing_type.to_sym][:width] * 2
      kit = IMGKit.new(html, quality: 100, width: width)

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

    def asset_path(filename)
      File.join(
        KarafkaApp.config.root_dir,
        'app/assets/images',
        context.project.to_s,
        context.template.to_s,
        context.sharing_type.to_s,
        filename
      )
    end

    def store_dir
      File.join(
        context.project, context.template, context.resource_type, context.resource_id.to_s
      )
    end

    def assing_project_attrs_by_class_name
      attrs = self.class.name.to_s.split('::')

      context.project = attrs[1].to_s.to_snakecase
      context.template = attrs[2].to_s.gsub('Template', '').to_snakecase
    end
end
