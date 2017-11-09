# IP2Location Filter Plugin
This is IP2Location filter plugin for Logstash that enables Logstash's users to add geolocation information such as country, region, city, latitude, longitude, ZIP code, time zone, Internet Service Provider (ISP), domain name, connection speed, IDD code, area code, weather station code, weather station name, mobile country code (MCC), mobile network code (MNC), mobile brand, elevation, and usage type by IP address. The library reads the geo location information from **IP2Location BIN data** file.

Supported IPv4 and IPv6 address.


## Example
![Example of data](https://www.ip2location.com/images/tutorial/logstash-filter-ip2location-screenshot2.png)


## Dependencies (IP2LOCATION BIN DATA FILE)
This plugin requires IP2Location BIN data file to function. You may download the BIN data file at
* IP2Location LITE BIN Data (Free): https://lite.ip2location.com
* IP2Location Commercial BIN Data (Comprehensive): https://www.ip2location.com/software/java-component


## Installation
Install this plugin by the following code:
```
bin/logstash-plugin install logstash-filter-ip2location
```


## IP2Location Filter Configuration
|Setting|Input type|Required|
|---|---|---|
|source|string|Yes|
|database|a valid filesystem path|No|
|license|string|No|

* **source** field is a required setting that containing the IP address or hostname to get the ip information.
* **database** field is an optional setting that containing the path to the IP2Location BIN database file.
* **license** field is an optional setting that containing the license key value to remove the random 5 second delay in demo version.


## Support
Email: support@ip2location.com

URL: [https://www.ip2location.com](https://www.ip2location.com)
