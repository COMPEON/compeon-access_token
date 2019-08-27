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

token.aud = 'audience'
token.iat = Time.now.to_i
token.exp = Time.now.to_i + 3600 # 1 Expiry time is required and must be in the future.
token.iss = 'issuer'
token.sub = 'subject'

token.encode(private_key: OpenSSL::PKey::RSA.new(private_key_string))
# => eyJhbGciOiJIUzI1NiIsInR5cC...
```

Decode a token

```ruby
token = Compeon::Token::Access.decode(
  encoded_token: 'eyJhbGciOiJIUzI1NiIsInR5cC...',
  public_key: OpenSSL::PKey::RSA.new(private_key_string).public_key
)

token.client_id # => 'compeon-auth'
token.role # => 'customer'
token.user_id # => '123'
token.aud # => 'audience'
token.iss # => 'issuer'
# etc.

```

Decode a token and verify reserved claims

```ruby
token = Compeon::Token::Access.decode(
  # The `exp` claim is validated by default and is not needed here
  claim_verifications: { aud: 'audience', iat: true, iss: 'issuer', sub: 'subject' },
  encoded_token: 'eyJhbGciOiJIUzI1NiIsInR5cC...',
  public_key: OpenSSL::PKey::RSA.new(private_key_string).public_key
)
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/compeon/compeon-access_token.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
