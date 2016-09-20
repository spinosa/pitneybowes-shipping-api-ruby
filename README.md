# Pitney Bowes Shipping Client Library for Ruby
[![gem version](https://badge.fury.io/rb/pbshipping.svg)](https://badge.fury.io/rb/pbshipping)

The Pitney Bowes Shipping Services APIs provide easy access to United States 
Postage Service shipping and tracking services that can be easily integrated 
into any web application such as online shopping carts, e-commerce sites or 
multi-carrier applications. 

This package provides a wrapper layer allowing easy access to the Pitney Bowes 
shipping REST APIs in the Ruby programming language.  

You would need a Pitney Bowers developer account for testing and using the API
and the client library.

For more informaton please visit the 
[Pitney Bowes developer portal](http://developer.pitneybowes.com).

## Installation
 
You can clone or download the source from Github repository (https://github.com/pitneybowes/pitneybowes-shipping-api-ruby) or
install as [Ruby gem)](https://rubygems.org/).

## Dependencies

You would need to install Ruby rest-client (https://rubygems.org/gems/rest-client/), version 1.8 or later.

## Registration

Make sure you have signed up a developer account on the 
[Pitney Bowes developer portal](http://developer.pitneybowes.com).

Once you have successfully registered for a developer account, sign in and
you can access your API test key (`API key` and `API secret`) from the *Dashboard*
page. 

You can also access your `Developer ID` (e.g.: 12345678) from the *My Account* 
page.

By default, your developer account is configured to work with individual 
merchant account payment model. In this caes, each merchant signs up for 
a Pitney Bowes shipment account directly and their funds are directly 
managed by Pitney Bowes. 

For testing purpose, you can create a merchant account 
at https://developer.pbshippingmerchant.pitneybowes.com/home?developerID={DeveloperID}.
Make sure you replace the placeholder in the URL with your own developer ID.

You will use the `email address` for registering the merchant account for
identifying the corresponding mercchant in the shipping API call. 

## Understanding Configuration

The client library provides a configuration object (*lib/pbshipping.rb*) for 
managing configuraton for environment using the Shipping APIs. The values 
for each parameter can be readily accessed and modified programmatically:

```
module PBShipping

  @configuration = {
    :sandbox => "https://api-sandbox.pitneybowes.com",
    :production => "https://api.pitneybowes.com",
    :is_production => false,
    :default_api_version => "/v1",
    :overwrite_api_version => {
      "post/developers/.../merchants/registration" => "/v2",
      "get/ledger/developers/.../transactions/reports" => "/v2"
    }
  }
  . . . . . 
```
* *sandbox* and *production* refer to the URL pointing at the testing (sandbox)
and production server supporting the endpoints;
* *is_production* controls if the application should run in sandbox or 
production mode;
* *default_api_version* defines the default API version to be used in general 
except for cases where explict overrides are specified;
* *override_api_version* is a set (Ruby Hash) of API version 
overrides for specific API calls; each entry defines the particular version 
to be used for the corresponding API.

#### Choosing API version

You may need to use different version number for diferent Shipping APIs. 
This can be accomplished by customizing the *defaul_api_version* and 
*override_api_version* entries in the *Configuration.params* structure. 

To specify the version number of a particular call type:
* Identify the *signature* for the API call; the signature mimics the relative
path of the API and can be found in the comment headers in the resource files
(*account.rb, address.rb, carrier.rb, developer.rb, manifest.rb, shipmente.rb, tracking.rb*).
* Add an entry to *override_api_version* in the format 
*<api signature>: <verson string>* 


## Running the Tutorials

A tutorial *tutorial.rb* is provided to demonstrate how to use the different class and
methods available through the client library to consume the shipping services.

*Note: if you clone or download the source from Github and run the tutorial example
directly, make sure you include the lib directory/folder in your Ruby library path (RUBYLIB).*

```
ruby tutorial.rb
```

You would need to set your authentication (key and secret), 
developer (ID), and merchant (email) credentials either through environment 
variables or command line arguments.

### Setting through Environment Variables

The following four varaibles should be set:
* PBSHIPPING_KEY: your assigned API key
* PBSHIPPING_SECRET: your assigned API secret
* PBSHIPPING_DEVID: your Developer ID
* PBSHIPPING_MERCHANT: email address for the regsitered merchant account

```
export PBSHIPPING_KEY=<api key>
export PBSHIPPING_SECRET=<api secret>
export PBSHIPPING_DEVID=<developer id>
export PBSHIPPING_MERCHANT=<merchant email address>
```

### Setting through Command Line Arguments

Use the command line long options *--key*, *--secret*, *--devid*, and *--merchant*:

```
ruby tutorial_client_library.rb --key=<your key> --secret=<your secret> 
                                --devid==<developer id> 
                                --merchant=<merchant email>
```

## Running Test 

The test suite can be found under the *test* directory and can be run as follows:

```
ruby ts_all_tests.rb 
```

Similar to the tutorial, you have to set the authentication, developer, and 
merchant settings through environment variables to run the test.

## Documentation

The Pitney Bowes Shipping Services API (REST) documentation can be found at the 
[Pitney Bowes developer portal](http://developer.pitneybowes.com).

Developers are also encouraged to use the tutorial example and source code 
comment blocks for information on the wrapper layer interface and mapping to 
the underlying REST shipping APIs. 


