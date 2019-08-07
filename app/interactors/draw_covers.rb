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
        partner_name: context.partner_name,
        template_name: context.template_name
      )
    end
  end

  private

    def setup_context; end

    def validate; end
end
