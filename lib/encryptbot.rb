require "encryptbot/configuration"
require "encryptbot/cert"
require "encryptbot/version"
require "encryptbot/services/route53"

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
