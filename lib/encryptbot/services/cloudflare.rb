# a=Encryptbot::Services::Cloudflare.new("*.domain.com", {type: "TXT", name: "_acme-challenge.adventist.place", content: "test-3"});a.add_challenge
require "faraday"
require "json"

module Encryptbot
  module Services
    class Cloudflare

      attr_accessor :domain, :api_key, :api_email, :zone_id, :dns_entry, :dns_record_id, :dns_record

      def initialize(domain, dns_entry)
        @domain = domain.to_s.gsub("*.", "") # cleanup wildcard by removing *. infront
        @api_key = Encryptbot.configuration.cloudflare_api_key
        @api_email = Encryptbot.configuration.cloudflare_email
        @dns_entry = dns_entry # {content: "txt-record-content", type: "TXT", name: "_acme-challenge.domain.com"}
        @dns_record = "#{dns_entry[:name]}.#{@domain}"
      end

      def add_challenge
        begin
          get_zone_id
          setup_dns_record
        rescue => e
          raise Encryptbot::Error::CloudflareDNSError, e
        end
      end

      def get_zone_id
        response = get("/zones?name=#{@domain}")
        if response["result"].any?
          @zone_id = response["result"].first["id"]
        end
      end

      def setup_dns_record
        find_dns_record
        return false if @zone_id.nil?

        if @dns_record_id
          update_dns_record
        else
          add_dns_record
        end
      end

      def find_dns_record
        response = get("/zones/#{@zone_id}/dns_records?name=#{@dns_record}&type=#{@dns_entry[:type]}")
        if response["result"].any?
          @dns_record_id = response["result"].first["id"]
        end
      end

      def add_dns_record
        response = post("/zones/#{@zone_id}/dns_records", {
          type: @dns_entry[:type],
          name: @dns_record,
          content: @dns_entry[:content],
          ttl: 120
        })
        response["success"]
      end

      def update_dns_record
        response = put("/zones/#{@zone_id}/dns_records/#{@dns_record_id}", {
          type: @dns_entry[:type],
          name: @dns_record,
          content: @dns_entry[:content],
          ttl: 120
        })
        response["success"]
      end

      private

      def post(endpoint_path, payload)
        response = connection.post "https://api.cloudflare.com/client/v4#{endpoint_path}", payload.to_json
        format_response(response)
      end

      def put(endpoint_path, payload)
        response = connection.put "https://api.cloudflare.com/client/v4#{endpoint_path}", payload.to_json
        format_response(response)
      end

      def get(endpoint_path)
        response = connection.get "https://api.cloudflare.com/client/v4#{endpoint_path}"
        format_response(response)
      end

      def connection
        @connection ||= begin
          headers = {
            "X-Auth-Key" => @api_key,
            "X-Auth-Email" => @api_email,
            "Content-Type" => "application/json"
          }
          Faraday.new(url: "https://api.cloudflare.com", headers: headers)
        end
      end

      def format_response(response)
        if response.success?
          JSON.parse(response.body)
        else
          nil
        end
      end

    end
  end
end