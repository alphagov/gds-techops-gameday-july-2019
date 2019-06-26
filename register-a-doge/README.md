# TECH.OPS / Register a Doge

## Usage

```
rbenv install
bundle install
RACK_ENV=development rackup
# OR
RACK_ENV=production rackup
```

## End-to-End Test

The e2e tests use the Splunk HTTP Event Collector, please enable this in your splunk config, and update the config in web.env.

```shell
$ docker-compose up
```
