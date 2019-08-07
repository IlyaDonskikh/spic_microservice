class DrawCover
  include Interactor

  def call
    context.file = 'hello'
  end
end
