require "encryptbot/configuration"
require "encryptbot/cert"
require "encryptbot/version"
require "encryptbot/services/cloudflare"
require "encryptbot/services/dyn"

if defined?(Rails)
  require "encryptbot/railtie"
end

module Encryptbot

  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration) if block_given?
  end

end
