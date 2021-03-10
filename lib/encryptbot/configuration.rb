module Encryptbot
  class Configuration
    attr_accessor :heroku_app, :heroku_token,
    :route53_hosted_zone_id, :route53_acme_record_name,
    :route53_access_key_id, :route53_secret_access_key,
    :acme_email, :domains, :test_mode

    def initialize
      @heroku_app = nil
      @heroku_token = nil
      @route53_hosted_zone_id = nil
      @route53_acme_record_name = nil
      @route53_access_key_id = nil
      @route53_secret_access_key = nil
      @acme_email = nil
      @test_mode = false # use lets encrypt staging
      @domains = [] #["*.domain1.com","*.domain2.com"]
    end

    def valid?
      heroku_app && heroku_token && acme_email && domains.any? && route53_access_key_id
    end

  end
end
