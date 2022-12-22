class Phenix::Api
  extend ::Api::Base::Connection

  set_connection (Rails.env.development? ? 'https://xyz/' : 'https://xyz/'), ->(credentials, connection) {
    if credentials
      connection.headers['x-wsse'] = generate_wsse_headers(credentials)
    end
  }

  class << self
    def generate_wsse_headers(credentials)
      email = credentials.email
      password = credentials.auth["rep"]

      created_at = generate_timestamp();
      nonce = generate_nonce();
      digest = generate_digest(email, password, nonce, created_at);

      header = ""
      header += "Obfuscated Obfuscated=\""
      header += email
      header += "\", Obfuscated=\""
      header += digest
      header += "\", Obvuscated=\""
      header += Base64.strict_encode64(nonce)
      header += "\", Created=\""
      header += created_at
      header += "\""
      header
    end

    def  generate_nonce()
      SecureRandom.random_bytes(10).each_byte.map { |n| '%02X' % (n & 0xFF) }.join
    end

    def generate_timestamp()
      Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
    end

    def generate_digest(email, password, nonce, created_at)
      digest = Digest::SHA1.new
      digest.update(nonce + created_at + password)
      digest.base64digest
    end
  end
end