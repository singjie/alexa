require 'net/http'
require 'mechanize'
require 'numbers_and_words'

class RequestController < ApplicationController
  skip_before_action :verify_authenticity_token

  @@temp = 0

  def index
    intent = params["request"]["intent"]

    name = intent["name"]

    @message = ""

    if name == "Haze"
      return haze_intent(intent)
    elsif name == "Pregnancy"
      return pregnancy_intent(intent)
    elsif name == "Review"
      return ios_review_intent(intent)
    elsif name == "Lottery"
      return lottery_review_intent(intent)
    elsif name == "Temperature"
      return temperature_intent(intent)
    end
  end








  def random_intent intent
    @message "Random number is #{rand(10).to_words}"
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
    date = Date.strptime("14/12/2015", "%d/%m/%Y")
    week = 40 - (date.cweek - Date.today.cweek)
    @message = "Baby is now #{week} weeks."
  end









  def ios_review_intent intent
    mechanize = Mechanize.new
    page = mechanize.get('http://appreviewtimes.com/')

    slots = intent["slots"]

    days = page.search(".average").first.children.text
    platform = object_for_key("Platform", slots)

    if platform.nil?
      platform = "iOS"
    end

    if platform == "mac"
      days = page.search(".average").last.children.text
    end

    @message = "Review times for #{platform} is #{days}."
  end









  def lottery_review_intent intent
    result = Net::HTTP.get(URI.parse('http://gsgresult.appspot.com/api/4d/?afterdrawnum=3800'))

    json = JSON.parse(result)

    slots = intent["slots"]

    date_request = object_for_key("date", slots)

    date = Date.strptime(date_request, "%Y-%m-%d")
    date_string = date.strftime("%b %-d, %Y")

    result = {}

    json.each do |draw|
      draw_date = draw["drawDate"]

      if draw_date.starts_with?(date_string)
        result = draw
        break
      end
    end

    @message = "First Prize, #{humanize(result["wn1"])};
    Second Prize, #{humanize(result["wn2"])};
    Third Prize, #{humanize(result["wn3"])}"
  end

  def humanize number
    string = []
    string << (number/1000).to_words
    string << ((number/100) %10).to_words
    string << ((number/10) %10).to_words
    string << (number%10).to_words

    string.join(", ")
  end









  def temp
    value = params["value"]
    @@temp = value.to_i/100
    render :text => @@temp
  end

  def temperature_intent intent
    @message = "Temperature of the room is now #{@@temp.to_words} degree celcius."
  end

  def object_for_key key, slots
    slots.each do |slot_key, value|
      if key != slot_key
        next
      end

      return value["value"]
    end

    nil
  end

end
