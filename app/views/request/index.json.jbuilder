json.version "1.0"
json.response do
  json.outputSpeech do
    json.type "PlainText"
    json.text @message
  end
  json.card do
    json.type "Simple"
    json.title @message
  end
end
json.shouldEndSession true
