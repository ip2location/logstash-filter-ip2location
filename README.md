# IP2Location Filter Plugin
This is IP2Location Filter plugin for Logstash that enables the user to find the country, region or state, city, latitude and longitude, US ZIP code, time zone, Internet Service Provider (ISP) or company name, domain name, net speed, area code, weather station code, weather station name, mobile country code (MCC), mobile network code (MNC) and carrier brand, elevation, and usage type by IP address or hostname originates from.  The library reads the geo location information from **IP2Location BIN data** file.

Supported IPv4 and IPv6 address.


## Dependencies (IP2LOCATION BIN DATA FILE)
This plugin requires IP2Location BIN data file to function. You may download the BIN data file at
* IP2Location LITE BIN Data (Free): https://lite.ip2location.com
* IP2Location Commercial BIN Data (Comprehensive): https://www.ip2location.com/software/java-component


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