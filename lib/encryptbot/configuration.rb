module Encryptbot
  class Configuration
    attr_accessor :heroku_app, :heroku_token,
    :cloudflare_api_key, :cloudflare_email,
    :dyn_customer_name, :dyn_username, :dyn_password,
    :acme_email, :domains, :test_mode,
    :slack_webhook, :slack_bot_username

    def initialize
      @heroku_app = nil
      @heroku_token = nil
      @cloudflare_api_key = nil
      @cloudflare_email = nil
      @dyn_customer_name = nil
      @dyn_username = nil
      @dyn_password = nil
      @acme_email = nil
      @slack_webhook = nil
      @slack_bot_username = "encryptbot"
      @test_mode = false # use lets encrypt staging
      @domains = [] #[{domain: "*.domain.com", service: "cloudflare"}, {domain: "*.domain.com", service: "dyn"}]
    end

    def valid?
      heroku_app && heroku_token && acme_email && domains.any? &&
      (cloudflare_api_key || dyn_customer_name)
    end

  end
end