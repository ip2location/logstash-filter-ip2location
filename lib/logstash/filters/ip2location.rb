# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"

require "logstash-filter-ip2location_jars"

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
    if @ip2locationfilter.handleEvent(event)
      filter_matched(event)
    else
      tag_iplookup_unsuccessful(event)
    end
  end

  def tag_iplookup_unsuccessful(event)
    @logger.debug? && @logger.debug("IP #{event.get(@source)} was not found in the database", :event => event)
  end

end # class LogStash::Filters::IP2Location
