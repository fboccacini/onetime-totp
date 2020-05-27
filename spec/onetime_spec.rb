require_relative '../lib/onetime'

describe OneTime do
   context "When testing the OneTime class" do

     methods = ['SHA1','SHA256','SHA512']
     tests = Array.new
     index = 0
     o = [(' '..'~')].map(&:to_a).flatten

     it "should create a one time password with random secret, length, encryption and step without errors and verify it at different times" do
       100.times do
         methods.each do |encryption|

          # Preapare random data
          test = Hash.new

          test[:number] = index + 1
          test[:secret] = (0...rand(1..32)).map { o[rand(o.length)] }.join
          test[:length] = rand(4..10)
          test[:step] = rand(4..180)
          test[:first_delay] = rand(0..(test[:step] - 1))

          # Start a thread for each test
          test[:thread] = Thread.new do

            puts "Test #{test[:number]} started. (Wait time: #{test[:first_delay]}s)"

            # Instantiate totp
            totp = OneTime.new(test[:secret], length: test[:length], step: test[:step], encryption: encryption)
            expect(totp.class).to eq OneTime

            # Get password and time for validation and reference
            pass = totp.password
            time = totp.generation_time

            # Sleep random time
            sleep rand(0..test[:step] * 2)

            # Verify
            time_diff = (Time.now.to_f - time.to_f)
            test[:verify] = totp.verify(pass)

            if (test[:step] - time_diff).abs < 1
              time_label = "Around time limit"
            elsif time_diff < test[:step]
                time_label = 'Within step'
            else
              time_label = 'Time exceeds'
            end
            test_num = tests.reject{ |t| t[:verify].nil? }.length
            if test[:verify] == time_diff < test[:step]
              puts "#{test_num.to_s.rjust(3)}/#{tests.length} Test #{test[:number].to_s.rjust(3)} #{encryption.rjust(7)} "\
                    "#{time_label.rjust(17)} #{('%+.5f' % (time_diff - test[:step])).rjust(11)} -> "\
                    "OK #{test[:verify] ? '(Granted)' : '(Denied)'.rjust(9)} pass: #{pass.rjust(10)} / #{totp.password.ljust(10)} "\
                    "elapsed/step: #{"#{'%.5f' % (Time.now.to_f - time.to_f)}s".rjust(10)}/#{test[:step].to_s.rjust(3)}s "\
                    "length: #{test[:length].to_s.rjust(2)} secret: #{test[:secret]}"
            else
              puts "Test #{test[:number]} (#{encryption}) #{time_label} (#{'%+.5f' % (time_diff - test[:step])}) -> Error (#{test[:verify] ? 'Granted' : 'Denied'}) time: #{time.strftime('%H:%M:%S')} / #{totp.generation_time.strftime('%H:%M:%S')} elapsed / step: #{'%.5f' % (Time.now.to_f - time.to_f)}s / #{test[:step]}s secret: #{test[:secret]} / #{totp.secret} length: #{test[:length]} pass: #{pass} / #{totp.password}}"
            end
            expect((test[:verify] == time_diff < test[:step])).to eq true

          end   # thread

          tests << test
          index += 1
        end   #methods
      end   #times
      tests.each{ |t| t[:thread].join }
    end   # it

  end   #context
end   #describe
