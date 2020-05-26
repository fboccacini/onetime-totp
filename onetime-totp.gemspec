Gem::Specification.new do |s|
  s.name        = 'onetime-totp'
  s.version     = '1.0.0'
  s.summary     = "Time-based One Time Password (TOTP) generator."
  s.description = "A TOTP generator, that includes validation, generation and send methods.
    See https://github.com/fboccacini/onetime-totp for reference and usage."
  s.authors     = ["Fabio Boccacini"]
  s.email       = 'fboccacini@gmail.com'
  s.files       = ["lib/onetime.rb"]
  s.homepage    = 'https://github.com/fboccacini/onetime-totp'
  s.license     = 'MIT'
  s.add_runtime_dependency 'base32', '~> 0.3'
end
