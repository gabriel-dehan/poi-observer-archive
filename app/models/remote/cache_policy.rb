# This singleton class holds all cache settings and model collections cache expirations dates
class Remote::CachePolicy < ApplicationRecord
  DEFAULTS = {
    users_cache_duration: 30.minutes.to_i,
    applications_cache_duration: 12.hours.to_i
  }
  # TODO: Force refresh cache rake task

  # Pseudo singleton
  def self.instance 
    self.first || self.create!
  end

  def self.create(attrs = {})
    self.first || super(DEFAULTS.merge(attrs))
  end

  def self.create!(attrs = {})
    self.first || super(DEFAULTS.merge(attrs))
  end

  def self.update(*args)
    if args.first.kind_of? Hash 
      self.instance.update_attributes(*args)
    else 
      self.instance.update_attribute(*args)
    end
  end

  def self.reset!(attrs = {})
    self.instance.destroy && self.create!(attrs)
  end
end
