class Lilo::Api # And Stitch
  extend ::Api::Base::Connection

  set_connection 'https://xyz/', ->(credentials, connection) {
    connection.headers['Content-Type'] = 'application/x-www-form-urlencoded'
  }
end