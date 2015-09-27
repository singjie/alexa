require 'net/http'
require 'mechanize'
class RequestController < ApplicationController
  skip_before_action :verify_authenticity_token
  def index
    #puts "YOU REQUESTED FOR ME?"
    #puts request.body.read
    #puts params["request"]["intent"]
    name = params["request"]["intent"]["name"]

    intent = params["request"]["intent"]

    @message = ""

    if name == "Haze"
      return ios_review_intent(intent)
      return haze_intent(intent)
    elsif name == "Pregnancy"
      return pregnancy_intent(intent)
    elsif name = "Review"
      return ios_review_intent(intent)
    end

    slots = params["request"]["intent"]["slots"]

    slots.each do |key, value|
      puts "key:#{key}"
      puts "value:#{value}"
    end
    #puts params["session"]
    #puts request.env
  end

  def haze_intent intent
    result = Net::HTTP.get(URI.parse('http://sghaze.herokuapp.com/'))

    json = JSON.parse(result)

    values = []
    values << json["North"].to_i
    values << json["South"].to_i
    values << json["East"].to_i
    values << json["West"].to_i

    average = values.sum / values.size.to_f

    description = "hazardous"
    if average <= 50
      description = "good"
    elsif average <= 100
      description = "moderate"
    elsif average <= 200
      description = "unhealthy"
    elsif average <= 300
      description = "very unhealthy"
    end

    @message = "The PSI is now #{average.round}, in the #{description} range."
  end

  def pregnancy_intent intent
    @message = "Baby is growing."
  end

  def ios_review_intent intent
    mechanize = Mechanize.new
    page = mechanize.get('http://appreviewtimes.com/')

    slots = intent["slots"]

    days = page.search(".average").first.children.text
    platform = "iOS"

    slots.each do |key, value|
      puts "key:#{key}"
      if key != "platform"
        next
      end

      if value.lowercase == "mac"
        days = page.search(".average").last.children.text
        platform = "Mac"
      end
    end

    @message = "Review times for #{platform} is #{days}."
  end
end
