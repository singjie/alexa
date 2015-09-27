class RequestController < ApplicationController
  def index
    puts "YOU REQUESTED FOR ME?"
    puts request.body.read
    #puts request.env
  end
end
