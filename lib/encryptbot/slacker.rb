require "slack-notifier"

module Encryptbot
  class Slacker

    def self.post_message(message)
      unless Encryptbot.configuration.slack_webhook.nil?
        notifier.ping message
      end
    end

    def self.notifier
      @notifier ||= Slack::Notifier.new Encryptbot.configuration.slack_webhook, username: Encryptbot.configuration.slack_bot_username
    end
  end
end