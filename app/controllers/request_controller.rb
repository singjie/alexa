class RequestController < ApplicationController
  skip_before_action :verify_authenticity_token
  def index
    #Rails.logger "YOU REQUESTED FOR ME?"
    Rails.logger request.body.read
    #puts request.env
  end
end
