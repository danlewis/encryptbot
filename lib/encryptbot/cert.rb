require "platform-api"
require "acme-client"
require "encryptbot/heroku"
require "encryptbot/exceptions"
require "encryptbot/slack"
require "resolv"

module Encryptbot
  class Cert

    attr_reader :domain_list, :domain_names, :account_email, :test_mode

    def initialize
      @domain_list = Encryptbot.configuration.domains
      @domain_names = @domain_list.map{|d| d[:domain] }
      @account_email = Encryptbot.configuration.acme_email
      @test_mode = Encryptbot.configuration.test_mode
    end

    # Add certificate
    def add
      unless Encryptbot.configuration.valid?
        raise Encryptbot::Error::SetupError, "Encryptbot is configured incorrectly. Check all required variables have been set."
      end

      # setup ACME client
      private_key = OpenSSL::PKey::RSA.new(4096)
      client = Acme::Client.new(
        private_key: private_key,
        directory: @test_mode ? "https://acme-staging-v02.api.letsencrypt.org/directory" : "https://acme-v02.api.letsencrypt.org/directory"
      )
      account = client.new_account(
        contact: "mailto:#{@account_email}",
        terms_of_service_agreed: true
      )

      # create order
      order = client.new_order(identifiers: @domain_names)

      # authorization of domains
      order.authorizations.each do |authorization|
        dns_challenge = authorization.dns
        domain = authorization.domain
        dns_entry = {
          name: dns_challenge.record_name,
          type: dns_challenge.record_type,
          content: dns_challenge.record_content
        }
        case @domain_list.detect{|t| t[:domain].gsub("*.", "") == domain }[:service]
        when "cloudflare"
          Encryptbot::Services::Cloudflare.new(domain, dns_entry).add_challenge
        when "dyn"
          Encryptbot::Services::Dyn.new(domain, dns_entry).add_challenge
        else
          raise Encryptbot::Error::UnknownServiceError, "#{domain} service unknown"
        end
        # check if the DNS service has updated
        sleep(8)

        attempts = 3
        while !ready_for_challenge(domain, dns_challenge) && attempts > 0
          sleep(8)
          attempts -= 1
        end

        # request verifification
        dns_challenge.request_validation

        # check if dns challange was accepted
        while dns_challenge.status == "pending"
          sleep(2)
          dns_challenge.reload
        end

      end # end auth loop

      if order.status == "invalid"
        raise Encryptbot::Error::InvalidOrderError, "Certificate order was invalid. DNS Challenge failed."
      end

      # Generate certificate
      csr = Acme::Client::CertificateRequest.new(names: @domain_names)
      order.finalize(csr: csr)
      sleep(1) while order.status == "processing"

      # add certificate to heroku
      certificate = order.certificate
      private_key = csr.private_key.to_pem
      Encryptbot::Heroku.new.add_certificate(order.certificate, private_key)
    end

    # Check if TXT value has been set correctly
    def ready_for_challenge(domain, dns_challenge)
      record = "#{dns_challenge.record_name}.#{domain}"
      challenge_value = dns_challenge.record_content
      txt_value = Resolv::DNS.open do |dns|
        records = dns.getresources(record, Resolv::DNS::Resource::IN::TXT);
        records.empty? ? nil : records.map(&:data).join(" ")
      end
      txt_value == challenge_value
    end

  end

end