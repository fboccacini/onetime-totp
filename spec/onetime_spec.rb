require_relative '../lib/onetime'

describe OneTime do
   context "When testing the OneTime class" do

     methods = ['SHA1','SHA256','SHA512']
     tests = Array.new
     index = 0
     o = [('a'..'z'), ('A'..'Z'), (0..9)].map(&:to_a).flatten

     it "should create a one time password with random secret, length, encryption and step without errors and verify it at different times" do
       3.times do
         methods.each do |encryption|
          # sleep 0.5
          test = Hash.new

          test[:number] = index + 1
          test[:secret] = (0...rand(1..32)).map { o[rand(o.length)] }.join
          test[:length] = rand(4..10)
          test[:step] = rand(4..10)
          test[:first_delay] = rand(0..(test[:step] - 1))
          test[:thread] = Thread.new do

            puts "Test #{test[:number]} started. (Wait time: #{test[:first_delay]}s)"
            totp = OneTime.new(test[:secret], length: test[:length], step: test[:step], encryption: encryption)
            expect(totp.class).to eq OneTime

            pass = totp.password
            time = totp.generation_time
            gen = totp.gen_step

            sleep test[:first_delay]

            test[:verify] = totp.verify(pass)
            if test[:verify]
              puts "Test #{test[:number]} (#{encryption}) within step -> OK (#{totp.gen_step - gen} / #{gen} / #{totp.gen_step}) #{test[:step]}s / #{Time.now.to_i - time.to_i}s"
            else
              puts "Test #{test[:number]} (#{encryption}) within step -> time: #{time.strftime('%H:%M:%S')} / #{totp.generation_time.strftime('%H:%M:%S')} step: #{test[:step]} (#{Time.now.to_i - time.to_i}s) (#{totp.gen_step - gen} / #{gen} / #{totp.gen_step}) secret: #{test[:secret]} / #{totp.secret} length: #{test[:length]} enc: #{encryption} pass: #{pass} / #{totp.password} verify: #{test[:verify].to_s}"
            end
            expect(test[:verify]).to eq true

            # it "should verify the password at step time and return true"
              sleep (test[:step] - test[:first_delay])
              test[:verify_limit] = totp.verify(pass)
              unless test[:verify_limit]
                puts "Test #{test[:number]} (#{encryption}) time limit -> OK (#{totp.gen_step - gen} / #{gen} / #{totp.gen_step}) #{test[:step]}s / #{Time.now.to_i - time.to_i}s"
              else
                puts "Test #{test[:number]} (#{encryption}) time limit -> time: #{time.strftime('%H:%M:%S')} / #{totp.generation_time.strftime('%H:%M:%S')} step: #{test[:step]} (#{Time.now.to_i - time.to_i}s) (#{totp.gen_step - gen} / #{gen} / #{totp.gen_step}) secret: #{test[:secret]} / #{totp.secret} length: #{test[:length]} enc: #{encryption} pass: #{pass} / #{totp.password} verify: #{test[:verify].to_s}"
              end
              expect(test[:verify_limit]).to eq false
            #   verify = totp.verify(pass)
            #   puts "Test #{i} (#{encryption}) time limit -> time: #{time.strftime('%H:%M:%S')} / #{totp.generation_time.strftime('%H:%M:%S')} step: #{step} (#{totp.diff} #{gen}/#{totp.gen_step}) (#{totp.generation_time - time}s) secret: #{secret} / #{totp.secret} length: #{length} enc: #{encryption} pass: #{pass} / #{totp.password} verify: #{verify.to_s}"
            #   expect(verify).to eq true
            # end
            # it "should verify the password after step time and return false"
              # sleep rand(1..60)
              sleep test[:step] * 2
              test[:verify_exceed] = totp.verify(pass)
              unless test[:verify_exceed]
                puts "Test #{test[:number]} (#{encryption}) time exceed -> OK (#{totp.gen_step - gen} / #{gen} / #{totp.gen_step}) #{test[:step]}s / #{Time.now.to_i - time.to_i}s"
              else
                puts "Test #{test[:number]} (#{encryption}) time exceed -> time: #{time.strftime('%H:%M:%S')} / #{totp.generation_time.strftime('%H:%M:%S')} step: #{test[:step]} (#{Time.now.to_i - time.to_i}s) (#{totp.gen_step - gen} / #{gen} / #{totp.gen_step}) secret: #{test[:secret]} / #{totp.secret} length: #{test[:length]} enc: #{encryption} pass: #{pass} / #{totp.password} verify: #{test[:verify].to_s}"
              end
              expect(test[:verify_exceed]).to eq false
            #   expect(verify).to eq false
            # end
          end

          tests << test
          index += 1
        end

      end
      tests.each{ |t| t[:thread].join }
      # tests.each{ |t| expect(t[:verify]).to eq true}
      # tests.each{ |t| expect(t[:verify_limit]).to eq false}
      # tests.each{ |t| expect(t[:verify_exceed]).to eq false}
    end
  end
end
