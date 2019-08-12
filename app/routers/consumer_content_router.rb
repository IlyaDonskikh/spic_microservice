require 'dry-initializer'

class ConsumerContentRouter
  extend Dry::Initializer

  option :project
  option :template
  option :content

  ## Etc.
  def self.call(args)
    router = new(args)

    router.send :route!
  end

  private

    def route!
      template = self.template.capitalize
      project = self.project.camelize
      class_name = "Project::#{project}::#{template}Template::DrawCover"

      class_name.constantize.call(content)
    end
end
