# encoding: utf-8
require_relative '../spec_helper'
require "logstash/filters/ip2location"

IP2LOCATIONDB = ::Dir.glob(::File.expand_path("../../vendor/", ::File.dirname(__FILE__))+"/IP2LOCATION-LITE-DB3.IPV6.BIN").first

describe LogStash::Filters::IP2Location do

  describe "normal test" do
    config <<-CONFIG
      filter {
        ip2location {
          source => "ip"
          #database => "#{IP2LOCATIONDB}"
        }
      }
    CONFIG

    sample("ip" => "8.8.8.8") do
      expect(subject.get("ip2location")).not_to be_empty
      expect(subject.get("ip2location")["country_short"]).to eq("US")
      end
    end

    sample("ip" => "2a01:04f8:0d16:26c2::") do
      expect(subject.get("ip2location")).not_to be_empty
      expect(subject.get("ip2location")["country_short"]).to eq("DE")
      end
    end
  end

end