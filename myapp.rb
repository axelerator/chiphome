# myapp.rb
require 'sucker_punch'
require 'sinatra'

DRY_MODE = false
begin
  require 'chip-gpio'
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
    end
  end
end

class LivingRoomLigts < GpioJob
  def pin_name
    "XIO_7"
  end
end


get '/' do
  'Hello world!'
end

post '/lights/on' do
  LivingRoomLigts.perform_in(5, GpioJob::ON)
  redirect '/dashboard.html?flash=lightson'
end


post '/lights/off' do
  LivingRoomLigts.perform_in(5, GpioJob::OFF)
  redirect '/dashboard.html?flash=lightsoff'
end
