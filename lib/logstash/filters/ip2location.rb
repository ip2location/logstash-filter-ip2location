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
    return unless filter?(event)

    Cache.set(@cache_size) if @cache_size
    if Cache.include?(event)
      event.set('ip2location', Cache.for(event))
    else
      return tag_iplookup_unsuccessful(event) unless @ip2locationfilter.handleEvent(event)
      Cache.cache(event)
    end
    filter_matched(event)
  end

  def tag_iplookup_unsuccessful(event)
    @logger.debug? && @logger.debug("IP #{event.get(@source)} was not found in the database", :event => event)
  end

end # class LogStash::Filters::IP2Location

class OrderedHash
  ONE = 1

  attr_reader :hits_for # ip -> times queried
  attr_reader :ips_for

  def initialize
    @hits_for = Hash.new(0) # ip -> times queried
    @ips_for = {} # number of hits -> ips that have been hit #{key} times
  end

  def register(ip)
    ips_for[ONE] ||= []
    ips_for[ONE] << ip
    hits_for[ip] += 1
  end

  # 1. remove ip from its current category
  # 2. delete category if now empty
  # 3. (create and) add to the new category
  def reorder(ip)
    category = hits_for[ip]
    remove_ip_from(category, ip)
    add_ip_to(category + 1, ip)
  end

  def remove_ip_from(category, ip)
    ips_for[category].delete(ip)
    ips_for.delete(category) if ips_for[category].empty?
  end

  def add_ip_to(category, ip)
    ips_for[category] ||= []
    ips_for[category] << ip
  end

  # 1. registers the ip if it's a first-timer
  # 2. reorders the priority list
  # 3. updates times_quried
  def upvote(ip)
    if hits_for.has_key?(ip)
      hits_for[ip] += 1
      reorder(ip)
    else
      register(ip)
    end
  end

  def delete_least_used
    hits_for.delete(lowest_ip)
  end

  def lowest_ip
    lowest_category = ips_for.keys.min
    lowest_ip = ips_for[lowest_category].shift
    ips_for.delete(lowest_category) if ips_for[lowest_category].empty?
    lowest_ip
  end
end

class Cache
  ONE_DAY_IN_SECONDS = 86_400

  @ip2loc_for    = {}              # ip -> ip2location_key
  @timestamps    = {}              # ip -> time of caching
  @times_queried = OrderedHash.new # ip -> times queried
  @mutex         = Mutex.new

  class << self
    attr_reader :ip2loc_for
    attr_reader :timestamps
    attr_reader :times_queried
    attr_reader :cache_size

    def set(cache_size)
      @cache_size = cache_size
    end

    def include?(event)
      ip = ip_from(event)
      ip2loc_for.has_key?(ip) && up_to_date?(ip)
    end

    # Retrieve the `ip2location` tag for a given event
    # 1. increment the counter on this event
    # 2. return the `ip2location` tag
    def for(event)
      synchronize do
        ip = ip_from(event)
        times_queried.upvote(ip)
        ip2loc_for[ip]
      end
    end

    def cache(event)
      synchronize do
        make_room if cache_full?
        cache_event(event)
      end
    end

    private

    def up_to_date?(ip)
      timestamps[ip] < Time.now - ONE_DAY_IN_SECONDS
    end

    def cache_full?
      ip2loc_for.size >= cache_size
    end

    def make_room
      least_used_ip = times_queried.delete_least_used
      forget(least_used_ip)
    end

    def forget(ip)
      ip2loc_for.delete(ip)
      timestamps.delete(ip)
    end

    def cache_event(event)
      ip = ip_from(event)
      ip2loc_for[ip] = event.get('ip2location')
      timestamps[ip] = Time.now
    end

    def synchronize(&block)
      @mutex.synchronize(&block)
    end

    def ip_from(event)
      JSON.parse(event.to_json)['clientip']
    end
  end
end

