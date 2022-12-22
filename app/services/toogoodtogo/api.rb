class Toogoodtogo::Api
  extend ::Api::Base::Connection

  set_connection 'https://xyz/', ->(credentials, connection) {
    connection.headers['Content-Type'] = 'application/x-www-form-urlencoded'

    # TODO: Handle auth requests
    # if credentials
    # end
  }
end