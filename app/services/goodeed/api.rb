class Goodeed::Api
  extend ::Api::Base::Connection

  set_connection 'https://xyz/', ->(credentials, connection) {
    if credentials
      connection.headers['x-goodeed-token'] = credentials.auth["token"]
    end
  }
end