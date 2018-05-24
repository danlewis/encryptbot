# Encryptbot

Encryptbot creates and renews your Lets Encrypt SSL certificate on Heroku allowing for multiple wildcards.

The gem will:

- Create Lets Encrypt
- Add Lets Encrypt DNS Challenge TXT records to your DNS provider (cloudflare and Dyn supported)
- Add certificate to your Heroku SNI endpoint
- Send Slack notifications if the process fails.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'encryptbot'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install encryptbot


## Usage

Add an initializer file to your rails application and all applicable config settings.

```ruby
Encryptbot.configure do |config|
  config.heroku_app = "heroku_app_name"
  config.heroku_token = "heroku_api_token"
  config.cloudflare_api_key = "cloudflare_api_key"
  config.cloudflare_email = "cloudflare_account_email"
  config.acme_email = "letsencrypt_account_email"
  config.dyn_customer_name = "dyn_customer_name"
  config.dyn_username = "dyn_username"
  config.dyn_password = "dyn_password"
  config.slack_webhook = "slack_webhook_url"
  config.slack_bot_username = "name_for_slack_bot"
  config.domains = [
    {domain: "*.domain1.com", service: "cloudflare"},
    {domain: "*.domain2.com", service: "dyn"},
    {domain: "domain3.com", service: "cloudflare"},
  ]
end
```

Request initial certificate
```ruby
heroku run rails encryptbot:add_cert
```

Once the certificate has been initially setup, you can schedule the rake task to run every 60 days.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/encryptbot. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the encryptbot project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/encryptbot/blob/master/CODE_OF_CONDUCT.md).
