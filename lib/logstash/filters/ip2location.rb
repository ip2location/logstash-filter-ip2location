# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"

require "logstash-filter-ip2location_jars"
require "json"

require 'thread'


class LogStash::Filters::IP2Location < LogStash::Filters::Base
  config_name "ip2location"

  # The path to the IP2Location.BIN database file which Logstash should use.
  # If not specified, this will default to the IP2LOCATION-LITE-DB3.IPV6.BIN database that embedded in the plugin.
  config :database, :validate => :path

  # The field containing the IP address.
  # If this field is an array, only the first value will be used.
  config :source, :validate => :string, :required => true

  # The field used to define iplocation as target.
  config :target, :validate => :string, :default => 'ip2location'

  # The field used to define the size of the cache. It is not required and the default value is 10 000 
  config :cache_size, :validate => :number, :required => false, :default => 10_000

  public
  def register
    if @database.nil?
      @database = ::Dir.glob(::File.join(::File.expand_path("../../../vendor/", ::File.dirname(__FILE__)),"IP2LOCATION-LITE-DB3.IPV6.BIN")).first

      if @database.nil? || !File.exists?(@database)
        raise "You must specify 'database => ...' in your ip2location filter (I looked for '#{@database}')"
      end
    end

    @logger.info("Using ip2location database", :path => @database)

    @ip2locationfilter = org.logstash.filters.IP2LocationFilter.new(@source, @target, @database)
  end

  public
  def filter(event)
    json = JSON.parse(event.to_json)
    ip = json["clientip"]

    return unless filter?(event)
    if value = Cache.find(event, ip, @ip2locationfilter, @cache_size).get('ip2location')
      event.set('ip2location', value)
      filter_matched(event)
    else
      tag_iplookup_unsuccessful(event)
    end
  end

  def tag_iplookup_unsuccessful(event)
    @logger.debug? && @logger.debug("IP #{event.get(@source)} was not found in the database", :event => event)
  end

end # class LogStash::Filters::IP2Location

class OrderedHash
  ONE = 1

  attr_reader :times_queried # ip -> times queried
  attr_reader :hash

  def initialize
    @times_queried = Hash.new(0) # ip -> times queried
    @hash = {} # number of hits -> array of ips
  end

  def add(key)
    hash[ONE] ||= []
    hash[ONE] << key
    times_queried[key] = ONE
  end

  def reorder(key)
    number_of_queries = times_queried[key]

    hash[number_of_queries].delete(key)
    hash.delete(number_of_queries) if hash[number_of_queries].empty?

    hash[number_of_queries + 1] ||= []
    hash[number_of_queries + 1] << key
  end

  def increment(key)
    add(key) unless times_queried.has_key?(key)
    reorder(key)
    times_queried[key] += 1
  end

  def delete_least_used
    first_pile_with_someting.shift.tap { |key| times_queried.delete(key) }
  end

  def first_pile_with_someting
    hash[hash.keys.min]
  end
end

class Cache
  ONE_DAY_IN_SECONDS = 86_400

  @cache         = {}            # ip -> event
  @timestamps    = {}            # ip -> time of caching
  @times_queried = OrderedHash.new # ip -> times queried
  @mutex         = Mutex.new

  class << self
    attr_reader :cache
    attr_reader :timestamps
    attr_reader :times_queried


    def find(event, ip, filter, cache_size)
      synchronize do
        if cache.has_key?(ip)
          refresh_event(ip) if too_old?(ip)
        else
          if cache_full?(cache_size)
            make_room 
          end
          cache_event(event, ip, filter)
        end
        times_queried.increment(ip)
        cache[ip]
      end
    end

    def too_old?(ip)
      timestamps[ip] < Time.now - ONE_DAY_IN_SECONDS
    end

    def make_room
      key = times_queried.delete_least_used
      cache.delete(key)
      timestamps.delete(key)
    end

    def cache_full?(cache_size)
      cache.size >= cache_size
    end

    def cache_event(event, ip, filter)
      filter.handleEvent(event)
      cache[ip] = event
      timestamps[ip] = Time.now
    end

    def synchronize(&block)
      @mutex.synchronize(&block)
    end

    alias_method :refresh_event, :cache_event
  end
end