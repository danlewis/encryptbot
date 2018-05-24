require "encryptbot/slack"

module Encryptbot
  module Error

    class EncryptbotError < StandardError

      def initialize(msg = "")
        Encryptbot::Slack.post_message("Unable to autorenew SSL certificate. #{self.class.name} #{msg}")
        super(msg)
      end

    end

    # Exception raised when error adding certificate to Heroku
    class HerokuCertificateError < EncryptbotError; end
    # Exception raised due to configuration not been setup
    class SetupError < EncryptbotError; end
    # Exception raised when adding TXT record to Cloudflare
    class CloudflareDNSError < EncryptbotError; end
    # Exception raised when adding TXT record to Dyn
    class DynDNSError < EncryptbotError; end
    class UnknownServiceError < EncryptbotError; end
    # Exception raised as order was failed - this happens when the DNS Challenge failed
    class InvalidOrderError < EncryptbotError; end
  end
end