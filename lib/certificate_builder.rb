class CertificateBuilder
  def self.call(name, content, current_certificate_path = nil)
    return current_certificate_path if File.exists?(current_certificate_path.to_s)

    tmp_ca_file = Tempfile.new(name, "#{KarafkaApp.config.root_dir}/tmp/")
    tmp_ca_file.write(content)
    tmp_ca_file.close

    tmp_ca_file.path
  end
end
