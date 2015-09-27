class RequestController < ApplicationController
  skip_before_action :verify_authenticity_token
  def index
    puts "YOU REQUESTED FOR ME?"
    puts request.body.read
    #puts request.env
  end
end
