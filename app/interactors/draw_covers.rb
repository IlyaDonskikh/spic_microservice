class DrawCovers
  include Interactor

  ## Const
  SHARING_TYPES = %w(vkontakte facebook).freeze

  def call
    setup_context
    validate

    SHARING_TYPES.each do |sharing_type|
      DrawCover.call(
        sharing_type: sharing_type,
        project_name: context.project_name,
        template_name: context.template_name
      )
    end
  end

  private

    def setup_context; end

    def validate; end

    def assing_project_attrs_by_class_name
      attrs = self.class.name.to_s.split('::')

      context.project_name = attrs[1].to_s.to_snakecase
      context.template_name = attrs[2].to_s.gsub('Template', '').to_snakecase
    end
end
