class DrawCover
  include Interactor

  ## Const
  REQUIRED_FILEDS = %w(project template sharing_type)

  ## Etc.
  def call
    validate

    p read_template
  end

  private

    def validate
      REQUIRED_FILEDS.each do |field|
        context.fail! message: "exists_#{field}" unless context[field]
      end

      context.fail! message: "template_error" unless File.file?(template_file)
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

    def read_template
      file = File.read(template_file)
      erb = ERB.new file

      erb.result(binding)
    end
end
