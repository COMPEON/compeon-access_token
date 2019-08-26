# Compeon::AccessToken

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'compeon-access_token'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install compeon-access_token

## Usage

Encode a token

```ruby
token = Compeon::Token::Access.new(
  client_id: 'compeon-auth',
  role: 'customer',
  user_id: '123'
)
# 1 hours until expiry. Expiry time is required and must be in the future.
token.claims[:exp] = Time.now.to_i + 3600
# Any claim specified in the JWT specification can be used here.
token.claims[:iss] = 'compeon'

Compeon::Token::Encoder.new(
  private_key: OpenSSL::PKey::RSA.new(private_key_string),
  token: token
).encode
# => eyJhbGciOiJIUzI1NiIsInR5cC...
```

Decode a token

```ruby
token = Compeon::Token::Decoder.new(
  encoded_token: 'eyJhbGciOiJIUzI1NiIsInR5cC...',
  public_key: OpenSSL::PKey::RSA.new(private_key_string).public_key,
  token_klass: AccessToken # Deocding fails if token kind is not `access`
).decode

token.client_id # => 'compeon-auth'
token.role # => 'customer'
token.user_id # => '123'
token.claims[:iss] # => 'compeon'
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/compeon/compeon-access_token.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
