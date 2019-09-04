# IP2Location Filter Plugin
This is IP2Location filter plugin for Logstash that enables Logstash's users to add geolocation information such as country, region, city, latitude, longitude, ZIP code, time zone, Internet Service Provider (ISP), domain name, connection speed, IDD code, area code, weather station code, weather station name, mobile country code (MCC), mobile network code (MNC), mobile brand, elevation, and usage type by IP address. The library reads the geo location information from **IP2Location BIN data** file.

Supported IPv4 and IPv6 address.

For the methods to use IP2Location filter plugin with Elastic Stack (Elasticsearch, Filebeat, Logstash, and Kibana), please take a look on this [tutorial](https://www.ip2location.com/tutorials/how-to-use-ip2location-filter-plugin-with-elastic-stack).


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
    source => "clientip"
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
    source => "[nginx][access][source][ip]"
    # Set path to the database located
    database => "IP2LOCATION_BIN_DATABASE_FILESYSTEM_PATH"
    target => "[ip][location]"
    cache_size => 100000
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

* **source** field is a required setting that containing the IP address or hostname to get the ip information.
* **database** field is an optional setting that containing the path to the IP2Location BIN database file.
* **use_memory_mapped** field is an optional setting that used to allow user to enable the use of memory mapped file. Default value is false.
* **cache_size** this field used to define the size of the cache. It is not required and the default value is 10000 
* **target** The name of the container to put all of the ip2location date into. the default value is `ip2location`


## Sample Output
|Field|Description|
|---|---|
|ip2location.area_code|the varying length number assigned to geographic areas for call between cities|
|ip2location.city|the city name|
|ip2location.country_long|the country name based on ISO 3166|
|ip2location.country_short|the two-character country code based on ISO 3166|
|ip2location.domain|the Internet domain name associated to IP address range|
|ip2location.elevation|the elevation|
|ip2location.idd_code|the IDD prefix to call the city from another country|
|ip2location.ip_address|the IP address|
|ip2location.isp|the Internet Service Provider (ISP) name|
|ip2location.latitude|the city latitude|
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

![Example of data](https://www.ip2location.com/images/tutorial/logstash-filter-ip2location-screenshot2.png?)


## Support
Email: support@ip2location.com

URL: [https://www.ip2location.com](https://www.ip2location.com)
