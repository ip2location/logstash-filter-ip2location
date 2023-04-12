# IP2Location Filter Plugin
This is IP2Location filter plugin for Logstash that enables Logstash's users to add geolocation information such as country, region, district, city, latitude, longitude, ZIP code, time zone, Internet Service Provider (ISP), domain name, connection speed, IDD code, area code, weather station code, weather station name, mobile country code (MCC), mobile network code (MNC), mobile brand, elevation, usage type, address type, IAB category and ASN by IP address. The library reads the geo location information from **IP2Location BIN data** file.

Supported IPv4 and IPv6 address.

For the methods to use IP2Location filter plugin with Elastic Stack (Elasticsearch, Filebeat, Logstash, and Kibana), please take a look on this [tutorial](https://www.ip2location.com/tutorials/how-to-use-ip2location-filter-plugin-with-elastic-stack).

*Note: This plugin works in Logstash 7 and Logstash 8.*


## Dependencies (IP2LOCATION BIN DATA FILE)
This plugin requires IP2Location BIN data file to function. You may download the BIN data file at
* IP2Location LITE BIN Data (Free): https://lite.ip2location.com
* IP2Location Commercial BIN Data (Commercial): https://www.ip2location.com


## Installation
Install this plugin by the following code:
```
bin/logstash-plugin install logstash-filter-ip2location
```


## Config File Example 1
```
input {
  beats {
    port => "5043"
  }
}

filter {
  grok {
    match => { "message" => "%{COMBINEDAPACHELOG}"}
  }
  ip2location {
    source => "[source][address]"
  }
}


output {
  elasticsearch {
    hosts => [ "localhost:9200" ]
  }
}
```


## Config File Example 2
```
input {
  beats {
    port => "5043"
  }
}

filter {
  grok {
    match => { "message" => "%{COMBINEDAPACHELOG}"}
  }
  ip2location {
    source => "[source][address]"
    # Set path to the database located
    database => "IP2LOCATION_BIN_DATABASE_FILESYSTEM_PATH"
    # Enable memory mapped to be used
    use_memory_mapped => true
  }
}


output {
  elasticsearch {
    hosts => [ "localhost:9200" ]
  }
}
```


## IP2Location Filter Configuration
|Setting|Input type|Required|
|---|---|---|
|source|string|Yes|
|database|a valid filesystem path|No|
|use_memory_mapped|boolean|No|
|use_cache|boolean|No|
|hide_unsupported_fields|boolean|No|

* **source** field is a required setting that containing the IP address or hostname to get the ip information.
* **database** field is an optional setting that containing the path to the IP2Location BIN database file.
* **use_memory_mapped** field is an optional setting that used to allow user to enable the use of memory mapped file. Default value is false.
* **use_cache** field is an optional setting that used to allow user to enable the use of cache. Default value is true.
* **hide_unsupported_fields** field is an optional setting that used to allow user to hide unsupported fields. Default value is false.


## Sample Output
|Field|Description|
|---|---|
|ip2location.address_type|the IP address type (A-Anycast, B-Broadcast, M-Multicast & U-Unicast) of IP address or domain name|
|ip2location.area_code|the varying length number assigned to geographic areas for call between cities|
|ip2location.as|Autonomous system (AS) name|
|ip2location.asn|the Autonomous system number (ASN)|
|ip2location.category|the IAB content taxonomy category of IP address or domain name|
|ip2location.city|the city name|
|ip2location.country_long|the country name based on ISO 3166|
|ip2location.country_short|the two-character country code based on ISO 3166|
|ip2location.district|the district or county name|
|ip2location.domain|the Internet domain name associated to IP address range|
|ip2location.elevation|the elevation|
|ip2location.idd_code|the IDD prefix to call the city from another country|
|ip2location.ip_address|the IP address|
|ip2location.isp|the Internet Service Provider (ISP) name|
|ip2location.latitude|the city latitude|
|ip2location.location|the city location|
|ip2location.longitude|the city longitude|
|ip2location.mcc|the mobile country code|
|ip2location.mnc|mobile network code|
|ip2location.mobile_brand|the mobile brand|
|ip2location.net_speed|the Internet Connection Speed (DIAL) DIAL-UP,(DSL) DSL/CABLE or(COMP) COMPANY|
|ip2location.region|the region or state name|
|ip2location.time_zone|the Time zone in UTC (Coordinated Universal Time)|
|ip2location.usage_type|the usage type|
|ip2location.weather_station_code|the special code to identify the nearest weather observation station|
|ip2location.weather_station_name|the name of the nearest weather observation station|
|ip2location.zip_code|the ZIP code|


## Support
Email: support@ip2location.com  
URL: [https://www.ip2location.com](https://www.ip2location.com)
