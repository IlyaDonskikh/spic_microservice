class DrawCover
  include Interactor

  ## Const
  REQUIRED_FILEDS = %w(project template sharing_type resource_type resource_id).freeze
  SHARING_TYPES = %w(facebook vkontakte).freeze
  DIMENSIONS_COVER = {
    facebook: { width: 600, height: 315 },
    vkontakte: { width: 510, height: 228 }
  }.freeze

  ## Etc.
  def call
    extend_context
    validate

    create_and_process_file

    produce_kafka_message
  end

  private

    def extend_context; end

    def validate
      REQUIRED_FILEDS.each do |field|
        fail! message: "exists_#{field}" unless context[field]
      end

      !SHARING_TYPES.include?(context.sharing_type) &&
        fail!(message: 'include_sharing_type')

      fail! message: 'exists_template_body' unless context.template_body.is_a?(Hash)
      fail! message: 'exists_template_files' unless File.file?(template_file)
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
    rescue
      fail! message: 'template_render'
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

    def produce_kafka_message
      return unless context.file_url

      data = {
        project: context.project,           template: context.template,
        resource_id: context.resource_id,   resource_type: context.resource_type,
        file_url: context.file_url,         sharing_type: context.sharing_type
      }

      ImagesTrakingResponder.call(data)
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
        context.project,
        context.template,
        context.resource_type.to_s.downcase,
        context.resource_id.to_s
      )
    end

    def assing_project_attrs_by_class_name
      attrs = self.class.name.to_s.split('::')

      context.project = attrs[1].to_s.to_snakecase
      context.template = attrs[2].to_s.gsub('Template', '').to_snakecase
    end

    def fail!(payload = {})
      message = "#{self.class} #{context} Error: #{payload}"
      Karafka.logger.error message

      context.fail! payload
    end
end
