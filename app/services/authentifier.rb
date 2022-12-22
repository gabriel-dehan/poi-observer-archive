class Authentifier 
  attr_reader :credential
  
  def initialize(credential)
    @credential = credential 
  end

  def request 
    raise StandardError.new("Not Implemented")
  end

  def token_valid? 
    !token_invalid?
  end

  def token_invalid? 
    raise StandardError.new("Not Implemented")
  end

  def can_auth?
    request.success?
  end

end