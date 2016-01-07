module AppEnv
  def self.development?
    ENV['RACK_ENV'] && ENV['RACK_ENV'] == 'development'
  end

  def self.production?
    ENV['RACK_ENV'] && ENV['RACK_ENV'] == 'production'
  end

  def self.test?
    ENV['RACK_ENV'] && ENV['RACK_ENV'] == 'test'
  end

  def self.protocol
    AppEnv.development? ? 'http' : 'https'
  end
end
