################################################################################
#                                                                              #
#   OneTime password generator - 2020 fboccacini@gmail.com <Fabio Boccacini>   #
#   v1.0                                                                       #
#                                                                              #
################################################################################

require 'openssl'
require 'base64'
require 'base32'
require 'json'
require 'net/https'

class OneTime

  attr_accessor :step, :encryption, :length
  attr_reader :password, :secret, :generation_time, :gen_step

  def initialize(secret, length: 6, step: 30, encryption: 'SHA512')

    @secret = secret
    @length = length
    @step = step
    @encryption = encryption
    self.generate

  end

  def generate(time: Time.now,
                length: self.length,
                step: self.step,
                encryption: self.encryption,
                reset: false)

    begin

      # If reset is true nil the generation time
      @generation_time = time.clone if reset == true || @generation_time.nil?
      # Binary key from time / step
      rounded_step = (time.to_i - @generation_time.to_i) / step
      key = ['%0.16x' % (rounded_step).to_s(16).hex].pack('H*')
      @gen_step = rounded_step
      # Convert secret's non base32 char to base32 and back to string
      data = Base32.decode(Base32.encode(self.secret))

      # Get initial HMAC hash
      hash = OpenSSL::HMAC.digest(encryption, data, key)

      # Dynamic truncation:
      # Get the last for bit of the last byte of the hash
      offset = hash[hash.length - 1].ord & 0xf

      # Get the for bytes pointed by the offset
      hash = hash[offset .. offset + 3].bytes

      # Get new hash
      truncated_hash = ((hash[0] & 0x7f) << 24) |
                       ((hash[1] & 0xff) << 16) |
                       ((hash[2] & 0xff) <<  8) |
                       (hash[3] & 0xff)

      # Get actual password
      @password = "%0.#{length}d" % (truncated_hash % (10 ** length));

      return self.password

    rescue Exception => e
      puts e.message
      # puts e.backtrace.join("\n")
      return nil
    end

  end

  def verify(password, time: Time.now,
                      length: self.length,
                      step: self.step,
                      encryption: self.encryption)

    # verify a password correctness for a given time
    begin

      return self.generate(time: time,
                          length: length,
                          step: step,
                          encryption: encryption) == password

    rescue Exception => e
      puts e.message
      # puts e.backtrace.join("\n")
      return false
    end

  end

  def call_service(url, user, payload, content_type: 'application/json', accept: '*/*')

    begin

      self.generate if self.password.nil?

      # Base64 encode authentication for the header
      auth = Base64.strict_encode64("#{user}:#{self.password}".encode("ASCII"))

      # Prep uri and headers
      uri = URI.parse(url)
      headers = {
          'Authorization' => "Basic #{auth}",
          'Content-Type' => content_type,
          'Accept' => accept
        }

      # Create request
      request = Net::HTTP.new(uri.host, uri.port)
      request.use_ssl = true

      # Send request
      return request.post(uri.path, payload.to_json, headers)
    rescue Exception => e
      puts e.message
      # puts e.backtrace.join("\n")
      return nil
    end

  end



end
