# Route 53 acts a single service for domains to be verified, hence the domain is not used
require "aws-sdk-route53"

module Encryptbot
  module Services
    class Route53

      attr_accessor :domain, :dns_entry, :client, :hosted_zone_id, :aws_acme_record_name

      def initialize(domain, dns_entry)
        @dns_entry = dns_entry
        @hosted_zone_id = Encryptbot.configuration.route53_hosted_zone_id
        @acme_name = Encryptbot.configuration.route53_acme_record_name
        @client = Aws::Route53::Client.new({
          region: "global",
          credentials: Aws::Credentials.new(
            Encryptbot.configuration.route53_access_key_id,
            Encryptbot.configuration.route53_secret_access_key
        )})
      end

      def add_challenge
        begin
          response = @client.change_resource_record_sets({
            change_batch: {
              changes: [
                action: "UPSERT",
                resource_record_set: {
                  name: @aws_acme_record_name,
                  resource_records: [
                    {
                      value: "\"#{@dns_entry[:content]}\"",
                    },
                  ],
                  ttl: 0,
                  type: "TXT",
                }
              ],
              comment: "ACME Challege update",
            },
            hosted_zone_id: @hosted_zone_id
          })
          change_id = response.change_info.id
          change_status = response.change_info.status
          while change_status == "PENDING"
            sleep(10)
            change_status = @client.get_change({id: change_id}).change_info.status
          end
          change_status == "NSYNC"

        rescue => e
          raise Encryptbot::Error::Route53DNSError, e
        end

      end
    end
  end
end