# Used for unobserved apps, they will be switched to the null fetcher, this might in the futur allow us to log some things
class NullFetcher 
  attr_reader :app

  def fetch_for_users!
  end
  
  def fetch_for_user!(user)
  end
end