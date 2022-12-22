class Dreamact::Authentifier < Authentifier
  # There is no real need for authentification because we don't need a password
  # Just the email  
  def get_auth!      
    {
      email: credential.email
    }
  end
end