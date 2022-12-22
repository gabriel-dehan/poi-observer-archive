class Lrqdo::Api
  extend ::Api::Base::Connection

  set_connection 'https://xyz/', ->(credentials, connection) {
    # TODO: Handle auth requests
    # if credentials
    # end
  }
end