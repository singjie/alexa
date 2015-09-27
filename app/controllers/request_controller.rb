class RequestController < ApplicationController
  skip_before_action :verify_authenticity_token
  def index
    #puts "YOU REQUESTED FOR ME?"
    #puts request.body.read
    #puts params["request"]["intent"]
    name = params["request"]["intent"]["name"]
    puts "Name #{name}"

    if name == "GetLuckyNumbers"
      return haze_intent
    end

    slots = params["request"]["intent"]["slots"]

    slots.each do |key, value|
      puts "key:#{key}"
      puts "value:#{value}"
    end
    #puts params["session"]
    #puts request.env
  end

  def haze_intent

  end
end
