json.version "1.0"
json.response do
  json.outputSpeech do
    json.type "PlainText"
    json.text "Hello la"
  end
  json.card do
    json.type "Simple"
    json.title "Lol"
  end
end
json.shouldEndSession true
