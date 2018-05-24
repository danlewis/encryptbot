# a=Encryptbot::Services::Dyn.new("*.domain.com", {type: "TXT", name: "_acme-challenge", content: "test-3"});a.add_challenge
require "faraday"
require "json"

module Encryptbot
  module Services
    class Dyn

      attr_accessor :domain, :dns_entry, :full_domain_name, :api_token, :customer_name, :username, :password

      def initialize(domain, dns_entry)
        @domain = domain.to_s.gsub("*.", "") # cleanup wildcard by removing *. infront
        @dns_entry = dns_entry # {content: "txt-record-content", type: "TXT", name: "_acme-challenge.domain.com"}
        @full_domain_name = "#{dns_entry[:name]}.#{@domain}"
        @api_token = nil
        @customer_name = Encryptbot.configuration.dyn_customer_name
        @username = Encryptbot.configuration.dyn_username
        @password = Encryptbot.configuration.dyn_password
      end

      # sign in
      # check for txt record, update if already exists, otherwise create new one
      # publish changes
      # sign out
      def add_challenge
        begin
          sign_in
          success = setup_dns_record
          sign_out
          success
        rescue => e
          raise Encryptbot::Error::DynDNSError, e
        end

      end

      def sign_in
        response = post("/REST/Session/", {
          customer_name: customer_name,
          user_name: username,
          password: password
        })
        if response && response["status"] == "success"
          @api_token = response["data"]["token"]
        end
        if @api_token.nil?
          raise Encryptbot::Error::DynDNSError, "Unable to get Dyn API Token"
        end
      end

      def sign_out
        response = delete("/REST/Session/")
      end

      def setup_dns_record
        txt_endpoint = find_dns_record

        if txt_endpoint
          update_dns_record(txt_endpoint)
        else
          add_dns_record
        end
      end

      def find_dns_record
        response = get("/REST/TXTRecord/#{domain}/#{full_domain_name}/")
        if response && response["status"] == "success"
          return response["data"][0]
        end
        nil
      end

      def add_dns_record
        response = post("/REST/TXTRecord/#{domain}/#{full_domain_name}/", {
          rdata: {
            txtdata: dns_entry[:content]
          },
          ttl: "30"
        })
        if response && response["status"] == "success"
          return publish_changes
        end
        false
      end

      def update_dns_record(txt_endpoint)
        response = put(txt_endpoint, {
          rdata: {
            txtdata: dns_entry[:content]
          },
          ttl: "30"
        })
        if response && response["status"] == "success"
          return publish_changes
        end
        false
      end

      def publish_changes
        response = put("/REST/Zone/#{domain}/", {publish: true})
        response && response["status"] == "success"
      end

      private

      def post(endpoint_path, payload)
        response = connection.post "https://api2.dynect.net#{endpoint_path}", payload.to_json
        format_response(response)
      end

      def put(endpoint_path, payload)
        response = connection.put "https://api2.dynect.net#{endpoint_path}", payload.to_json
        format_response(response)
      end

      def delete(endpoint_path)
        response = connection.delete "https://api2.dynect.net#{endpoint_path}"
        format_response(response)
      end

      def get(endpoint_path)
        response = connection.get "https://api2.dynect.net#{endpoint_path}"
        format_response(response)
      end

      # Api token if set for requests after sign in completed
      def connection
        headers = {
          "Auth-Token" => api_token.to_s,
          "Content-Type" => "application/json"
        }
        Faraday.new(url: "https://api2.dynect.net", headers: headers)
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