require 'net/http'
require 'mechanize'
require 'numbers_and_words'
class RequestController < ApplicationController
  skip_before_action :verify_authenticity_token
  @@lights = 0

  def lights
    render :text => @@lights
  end

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
    elsif name == "Lights"
      return lights_intent(intent)
    end
    #
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
    platform = "iOS"

    slots.each do |key, value|
      puts "key:#{key}"
      if key != "Platform"
        next
      end

      if value["value"] == "mac"
        days = page.search(".average").last.children.text
        platform = "Mac"
      end
    end

    @message = "Review times for #{platform} is #{days}."
  end

  def lottery_review_intent intent
    result = Net::HTTP.get(URI.parse('http://gsgresult.appspot.com/api/4d/?afterdrawnum=3800'))

    json = JSON.parse(result)

    slots = intent["slots"]
    slots.each do |key, value|
      puts "key:#{key}"
      if key != "date"
        next
      end

      date = Date.strptime(value["value"], "%Y-%m-%d")

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

    # puts json
  end

  def lights_intent intent
    slots = intent["slots"]

    colour = ""
    on_off = ""
    slots.each do |key, value|
      if key == "switch"
        on_off = value["value"]
      elsif key == "colour"
        colour = value["value"]
      end
    end

    if colour == "red"
      if on_off == "on"
        @@lights |= 0b001
      else
        @@lights &= 0b110
      end
    elsif colour == "green"
      if on_off == "on"
        @@lights |= 0b010
      else
        @@lights &= 0b101
      end
    elsif colour == "yellow"
      if on_off == "on"
        @@lights |= 0b100
      else
        @@lights &= 0b011
      end
    end

    @message = "Please check the lights!"
  end

  def humanize number
    string = []
    string << (number/1000).to_words
    string << ((number/100) %10).to_words
    string << ((number/10) %10).to_words
    string << (number%10).to_words

    string.join(", ")
  end

  def bank_account_intent intent

  end

  def singapore_population_intent intent
    mechanize = Mechanize.new
    page = mechanize.get("http://beta.data.gov.sg/dataset/f60283b8-ded9-4499-88c1-737a1c3499c0/resource/b7652e8c-2df9-401b-9123-994d63773316/download/population.csv")

  end
end
