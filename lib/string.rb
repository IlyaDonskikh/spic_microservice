class String
  def to_snakecase
    gsub(/::/, '/').gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2'.freeze)
                   .gsub(/([a-z\d])([A-Z])/, '\1_\2'.freeze)
                   .tr("-", "_")
                   .downcase
  end

  def camelize
    split('_').collect(&:capitalize).join
  end
end
