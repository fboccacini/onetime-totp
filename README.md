# OneTime
Time-based One Time Password (TOTP) generator RubyGem

Installation
------------

gem install onetime-totp

Usage
-----

totp = OneTime.new('secret-token').generate

**Constructor's options:**

- secret: user's secret token. Required
- length: final password length (int). Default: 6
- encryption: encryption algorithm, supports SSL supported algoritms (string). Default: 'SHA512'
- step: time step for password generation, in seconds (int). Default: 30

Example: totp = OneTime.new('secret-token', length: 10, step: 10, encryption: 'SHA1')

----------------------
**Methods:**

 - generate(time = Time.now, length: self.length, step: self.step, encryption: self.encryption, reset: false)
    *Generates a password with the given options and stores it in self.password*

 - verify('password to verify', time: Time.now, length: self.length, step: self.step, encryption: self.encryption)
    *Verifies a given password against a newly generated (with options)*

 - call_service(url, user, payload, content_type: 'application/json', accept: '*/*')
    *Sends a request to the specified url, user and payload. If a password wasn't generated previously, it generates one using current timestamp and combines it with the user ("user:password"), encodes the result in base64, and stores it in the Authentication field in the header.*
