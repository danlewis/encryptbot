module Encryptbot
  module Error

    class EncryptbotError < StandardError

      def initialize(msg = "")
        super(msg)
      end

    end

    # Exception raised when error adding certificate to Heroku
    class HerokuCertificateError < EncryptbotError; end
    # Exception raised due to configuration not been setup
    class SetupError < EncryptbotError; end
    # Exception raised when route 53 fails to update
    class Route53DNSError < EncryptbotError; end
    # Exception raised when unknown error
    class UnknownServiceError < EncryptbotError; end
    # Exception raised as order was failed - this happens when the DNS Challenge failed
    class InvalidOrderError < EncryptbotError; end
    # Exception raised due to a domain failing authorization
    class DomainAuthorizationFailedError < EncryptbotError; end
  end
end
