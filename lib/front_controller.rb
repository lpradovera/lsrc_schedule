# encoding: utf-8

class FrontController < Adhearsion::CallController
  def run
    answer
    menu "#{Adhearsion.config.platform[:root]}/sounds/main-menu", :timeout => 5.seconds, :tries => 3 do
      match 1 do
        schedule
      end
      match 2 do
        record_message
      end
 
      timeout do
        "#{Adhearsion.config.platform[:root]}/sounds/menu-timeout"
      end
      invalid do
        "#{Adhearsion.config.platform[:root]}/sounds/menu-invalid"
      end
 
      failure do
        "#{Adhearsion.config.platform[:root]}/sounds/menu-failure"
        hangup
      end
    end
  end

  def schedule  
    logger.info "Running schedule"
    schedule = HTTParty.get('http://www.lonestarrubyconf.com/schedule.json')
    schedule["three"].each do |k|
      k[1].each do |talk|
        time =  Time.parse(talk["when"])
        logger.info talk["id"]
        if time >= Time.now - 5.minutes
          play "#{Adhearsion.config.platform[:root]}/sounds/#{talk["id"]}"
        end
      end
    end
  end

  def record_message
    play "#{Adhearsion.config.platform[:root]}/sounds/please-leave"
    record_result = record :start_beep => true, :max_duration => 10_000
    logger.info "Recording saved to #{record_result.recording_uri}"
    sleep(0.5)
    play record_result.recording_uri.gsub(/file:\/\//, '').gsub(/\.wav/, '')
  end
end
