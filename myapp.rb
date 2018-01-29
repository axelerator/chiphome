# myapp.rb
require 'sucker_punch'
require 'sinatra'
set :bind, '0.0.0.0'
DRY_MODE = false
begin
  require 'chip-gpio'
  PINS = ChipGPIO.get_pins
  PINS[:XIO7].export
  PINS[:XIO7].direction = :output
rescue NameError => e
  DRY_MODE = true
end

class GpioJob
  include SuckerPunch::Job

  ON = true
  OFF = false

  def perform(enable)
    if DRY_MODE
      if !!enable
        puts "ENABLING #{pin_name}"
      else
        puts "DISABLING #{pin_name}"
      end
    else
      if !!enable
        PINS[pin_name].value = 1
        puts "ENABLING #{pin_name}"
      else
        PINS[pin_name].value = 0
        puts "DISABLING #{pin_name}"
      end
    end
  end
end

class LivingRoomLigts < GpioJob
  def pin_name
    :XIO7
  end
end


get '/' do
  'Hello world!'
end

post '/lights/on' do
  LivingRoomLigts.perform_in(1, GpioJob::ON)
  redirect '/dashboard.html?flash=lightson'
end


post '/lights/off' do
  LivingRoomLigts.perform_in(1, GpioJob::OFF)
  redirect '/dashboard.html?flash=lightsoff'
end
