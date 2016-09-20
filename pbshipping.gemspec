Gem::Specification.new do |s|
  s.name        = 'pbshipping'
  s.version     = '1.0.0'
  s.date        = '2016-07-01'
  s.summary     = "Client library for using Pitney Bowes Shipping API"
  s.description = "Client library for using Pitney Bowes Shipping API"
  s.add_dependency('rest-client', '>= 1.8')
  s.authors     = ["Pitney Bowes Shipping API support team"]
  s.email       = 'ShippingAPISupport@ob.com'
  s.files       = ["tutorial.rb", "lib/pbshipping.rb"].concat(Dir.entries('./lib/pbshipping/').keep_if { |v| /\.rb$/.match(v) }.collect! { |v| './lib/pbshipping/'+v })
  s.homepage    = 'http://developer.pitneybowes.com'
  s.license     = 'MIT'
  s.metadata    = {'pbshipping_documentation' => "http://developer.pitneybowes.com/" }
end
