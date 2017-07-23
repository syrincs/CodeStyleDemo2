xml << '<?xml version="1.0" encoding="UTF-8"?>'
xml << "\n"
xml.Response do
  xml.Sms 'Thanks for the message. We recieved it. Reply HELP for help. Reply STOP to unsubscribe.'
end
