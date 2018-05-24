require 'platform-api'

module Encryptbot
  class Heroku

    attr_accessor :app, :token

    def initialize
      @app = Encryptbot.configuration.heroku_app
      @token = Encryptbot.configuration.heroku_token
    end

    def add_certificate(certificate, private_key)
      # list certificate to check if one already exists
      sni_endpoints = platform.sni_endpoint.list(@app)

      begin
        if sni_endpoints.any?
          # update existing ssl certificate
          platform.sni_endpoint.update(@app, sni_endpoints[0]["name"], {
            certificate_chain: certificate,
            private_key: private_key
          })
        else
          # add new ssl certificate
          platform.sni_endpoint.create(@app, {
            certificate_chain: certificate,
            private_key: private_key
          })
        end
      rescue => e
        raise Encryptbot::Error::HerokuCertificateError, e
      end
    end

    private

    def platform
      @platform ||= PlatformAPI.connect_oauth(@token)
    end

  end
end