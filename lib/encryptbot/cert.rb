require "platform-api"
require "acme-client"
require "encryptbot/heroku"
require "encryptbot/exceptions"
require "resolv"

module Encryptbot
  class Cert

    attr_reader :domains, :account_email, :test_mode

    def initialize
      @domains = Encryptbot.configuration.domains
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
      order = client.new_order(identifiers: @domains)

      puts "Start Authorization"
      # authorization of domains
      order.authorizations.each do |authorization|
        dns_challenge = authorization.dns
        domain = authorization.domain
        puts "Start Authorization of #{domain}"
        dns_entry = {
          name: dns_challenge.record_name,
          type: dns_challenge.record_type,
          content: dns_challenge.record_content
        }

        Encryptbot::Services::Route53.new(domain, dns_entry).add_challenge

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
        puts "Completed authorization of #{domain}. Status: #{dns_challenge.status}"

      end # end auth loop

      if order.status == "invalid"
        raise Encryptbot::Error::InvalidOrderError, "Certificate order was invalid. DNS Challenge failed."
      end

      # Generate certificate
      puts "Generate Certificate"
      csr = Acme::Client::CertificateRequest.new(names: @domain_names)
      order.finalize(csr: csr)
      sleep(1) while order.status == "processing"

      # add certificate to heroku
      puts "Adding Certificate to heroku"
      certificate = order.certificate
      private_key = csr.private_key.to_pem
      Encryptbot::Heroku.new.add_certificate(order.certificate, private_key)
      puts "Completed"
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
