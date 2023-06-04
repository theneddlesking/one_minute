require 'gosu'

class Timer
   attr_accessor :start_time, :done, :length, :running, :font, :seconds_left
   
   def initialize()
        @start_time = Time.now
        @done = false
        @length = 60 # the length of the timer in seconds
        @running = false
        @font = Gosu::Font.new(30)
   end
end

def start_timer(timer)
    timer.running = true
end

def reset_timer(timer)
    timer.start_time = Time.now
    timer.done = false
end

def update_timer(timer)
    if !timer.running
        ret
    end

    elapsed_time = Time.now - timer.start_time
    timer.seconds_left = timer.length - elapsed_time.to_i

    # if there is no time left then the timer has ended
    timer.done = timer.seconds_left == 0
end