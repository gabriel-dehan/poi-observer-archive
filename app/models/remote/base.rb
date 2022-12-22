class Remote::Base < ApplicationRecord

  self.abstract_class = true

  def self.collection_resolver(resolver)
    @collection_resolver = resolver
  end

  def self.member_resolver(resolver)
    @member_resolver = resolver
  end

  def self.resolver(type)
    type == :collection ? (@collection_resolver || 'data').split('.') : (@member_resolver || 'data').split('.')
  end

  def self.table_name_prefix
    'remote_'
  end

  def self.member_name
    self.to_s.split(/::/)[1..-1].join('').underscore
  end

  def self.collection_name
    self.to_s.split(/::/)[1..-1].join('').underscore.pluralize
  end

  # Caching class methods
  def self.cached_attributes_names 
    self.attribute_names - ["created_at", "updated_at"]
  end

  def self.clear_cache!
    self.destroy_all
    Remote::CachePolicy.update("#{self.collection_name}_last_cached_at", nil)
  end

  # TODO: should probably use individual records last_cached_at
  def self.collection_cache_expired?
    cache_policy = Remote::CachePolicy.instance
    cache_duration = cache_policy["#{self.collection_name}_cache_duration"]
    last_fetched = cache_policy["#{self.collection_name}_last_cached_at"]

    # If was never fetched before, considered as expired
    last_fetched ? last_fetched + cache_duration < DateTime.now.utc : true 
  end

  def self.collection_cached!
    Remote::CachePolicy.update("#{self.collection_name}_last_cached_at", DateTime.now.utc)
  end

  # Caches a collection of remote records
  def self.cache_collection!(remote_records)
    in_cache_collection = self.all
    in_cache_ids = in_cache_collection.all.pluck(:id)
    remote_ids = remote_records.map { |rec| rec[:id] }
    # missing_cache_ids = remote_ids - in_cache_ids 

    remote_records.each do |remote_record| 
      # Record already cached
      if in_cache_ids.include?(remote_record[:id])
        cached_record = in_cache_collection.select { |cached_record| cached_record.id == remote_record[:id] }.first
        cached_record.cache!(remote_record)
      else
      # Record not yet in the cache
        self.new.cache!(remote_record)
      end
    end
    self.collection_cached!
  end

  # Caching instance methods
  def cache_expired? 
    cache_duration = Remote::CachePolicy.instance["#{self.class.collection_name}_cache_duration"]
    last_cached_at + cache_duration < DateTime.now.utc
  end

  def mark_as_cached
    self.last_cached_at = DateTime.now.utc
  end

  # Caches a single remote record
  def cache!(remote_record)
    # We set even the id
    fields = remote_record.slice(*self.class.cached_attributes_names)
    self.assign_attributes(fields)
    self.mark_as_cached
    self.save!
  end

  # Queries
  # we can't override all because find and find_by use it
  def self.find_all
    if collection_cache_expired? 
      response = Api::Poi::client.get("/v1/#{collection_name}")
      if response.success?
        remote_records = response.body.dig(*resolver(:collection))

        self.cache_collection!(remote_records)
      else 
        raise ActiveRecord::RecordNotFound.new("Error fetching #{self} collection.")
      end
    end
    self.all
  end

  # Improved remote find with caching
  def self.find(id)

    record = self.find_by(id: id)
    if (record && record.cache_expired?) || !record
      response = Api::Poi::client.get("/v1/#{collection_name}/#{id}")
      if response.success? 
        remote_record = response.body.dig(*resolver(:member))
        (record || self.new).cache!(remote_record)
      else 
        raise ActiveRecord::RecordNotFound.new("Couldn't find #{self} with 'id'=#{id}")
      end
    end

    # If record was just fetched from API, we do a find_by to make sure we don't get stale data
    (record && !record.cache_expired?) ? record : self.find_by(id: id)
  end

  def first 
    find_all.first
  end

  def last
    find_all.last
  end
end