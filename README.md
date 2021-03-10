# Encryptbot

Encryptbot creates and renews your Let's Encrypt SSL certificate on Heroku allowing for multiple wildcards.

The gem will:

- Create Let's Encrypt
- Add Let's Encrypt DNS Challenge TXT records to DNS provider Route 53
- Add certificate to your Heroku SNI endpoint

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
  config.acme_email = "letsencrypt_account_email"
  config.route53_hosted_zone_id = "Z123456"
  config.route53_acme_record_name = "_acme-challenge.acme.domain.com"
  config.route53_access_key_id = "aws_api_key"
  config.route53_secret_access_key = "aws_api_secret"
  config.domains = ["*.domain1.com", "*.domain2.com"]
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
