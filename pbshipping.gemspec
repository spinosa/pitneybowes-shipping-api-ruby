# encoding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pbshipping/version'

Gem::Specification.new do |spec|
  spec.name          = 'pbshipping'
  spec.version       = PBShipping::VERSION
  spec.summary       = "Client library for using Pitney Bowes Shipping API"
  spec.description   = "Client library for using Pitney Bowes Shipping API"  
  spec.authors       = ["Pitney Bowes Shipping API support team"]
  spec.email         = 'ShippingAPISupport@pb.com'
  spec.files         = Dir['tutorial.rb', 'README.md', 'LICENSE', 'lib/**/*']  
  spec.test_files    = Dir['test/*']
  spec.require_paths = ["lib"]
  spec.homepage      = 'http://developer.pitneybowes.com'
  spec.license       = 'MIT'
  spec.metadata      = {'pbshipping_documentation' => "http://developer.pitneybowes.com/" }  

  spec.add_dependency 'rest-client', '~> 1.8'

end


