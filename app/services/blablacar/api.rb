class Blablacar::Api
  extend ::Api::Base::Connection

  set_connection 'https://xyz/', ->(credentials, connection) {
    if credentials
      connection.headers['Bearer'] = credentials.auth["token"]
    end
  }
end