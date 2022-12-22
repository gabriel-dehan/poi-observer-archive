class ApplicationCredential < ApplicationRecord
  scope :connected, -> { where(connected: true) }
  scope :disconnected, -> { where(connected: false) }

  # Make sure that last_fetched is automatically the current date upon creation
  # This is because we don't want to fetch data prior to this day
  after_create :has_synched!

  # TODO: After create, last sync should be now - 1 day

  def self.find_by_request_id(request_id)
    # Because a request id encodes ApplicationCredential id
    cred_id = request_id.split("-").last
    self.find_by(id: cred_id)
  end

  # TODO: After save, if password changed, reset remote_encrypted_password

  # Can't user belongs to because we want the cached data to be fetched if necessary
  def user 
    @user ||= Remote::User.find(user_id)
  end

  def application 
    @application ||= Remote::Application.find(application_id)
  end

  def authentifier 
    @authentifier ||= authentifier = "#{application.uid.classify}::Authentifier".constantize.new(self)
  end

  def generate_auth_request
    auth_data = authentifier.get_auth!

    if auth_data 
      auth_request = auth_data.merge({ id: self.generate_request_id! })

      # TODO: Reactivate me before prod
      unless Rails.env.development?
        auth_request[:lastSync] = self.last_fetched if self.last_fetched
      end
      auth_request
    else
      false
    end
  end

  def has_synched!
    self.update(last_fetched: DateTime.now)
  end

  def set_impact_meta_data(data)
    metadata = self.metadata

    metadata[:previous_impact_data] = data

    self.metadata = metadata
    self.save!
  end

  def generate_request_id!
    requests = self.last_requests 
    # A request id encodes the date and the ApplicationCredential id
    id = "#{SecureRandom.hex(6)}-#{DateTime.now.to_i}-#{self.id}"

    # Pop the last element and prepend the new one
    requests.prepend(id)
    self.last_requests = requests[0..2]

    self.save

    id
  end

  def last_request_id 
    self.last_requests.first
  end

  def password 
    decode_password(encrypted_password)
  end

  def decode_password(encrypted_pwd = self.encrypted_password)
    pem_file = File.read(Rails.root.join(".rsa", "poi-network.pem"))
    rsa = OpenSSL::PKey::RSA.new(pem_file)
    begin 
      rsa.private_decrypt(Base64.decode64(encrypted_pwd))
    rescue Exception => e
      puts e
      ""
    end
  end

  # Used mainly for testing and dev purposes
  def encode_password(pwd, force_save: false)
    pem_file = File.read(Rails.root.join(".rsa", "poi-network.pem"))
    rsa = OpenSSL::PKey::RSA.new(pem_file)
    encrypted_pwd = Base64.encode64(rsa.public_encrypt(pwd))

    if force_save 
      self.update(encrypted_password: encrypted_pwd)
    end
    encrypted_pwd
  end
end
