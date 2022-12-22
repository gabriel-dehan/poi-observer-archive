class Dreamact::Api
  extend ::Api::Base::Connection

  set_connection 'https://xyz/', ->(credentials, connection) {
  }
end