
Function login()

username = getUserInput("Login - Username", "Enter your Reddit username", "faketestuser")
password = getUserInput("Login - Password", "Enter your Reddit password", "abc123")

print "I got username = "+username 
print "I got pw = "+password

'http = NewHttp2("http://www.reddit.com/api/login", "application/json")
http = NewHttp2("https://ssl.reddit.com/api/login", "application/json")

http.AddParam("user", username)
http.AddParam("passwd", password)
http.AddParam("api_type", "json")
http.AddParam("rem", "false")
response= http.PostFromStringWithTimeout("", 90)
json = ParseJSON(response[0])
' response[1] contains the header information
print response

IF(json.json.errors.count() > 0 ) then
print "error logging in"
showMessage("Unable to login, reason:" + json.json.errors[1] )
return "fail"
else

modhash = json.json.data.modhash
cookie = json.json.data.cookie
setSetting("modhash", modhash)
setSetting("cookie", cookie)
setSetting("username", username)
return username
END IF

END FUNCTION

FUNCTION isLoggedIn() as Boolean
	if(getSetting("username") <> invalid)
		return true
	else
		return false
	END IF
END FUNCTION

FUNCTION getModhash() as String
	modhash = getSetting("username")
	if(modhash <> invalid)
		return modhash
	else
		return invalid
	END IF
END FUNCTION


FUNCTION getUserInput(title, dspText, default) as String
	 screen = CreateObject("roKeyboardScreen")
     port = CreateObject("roMessagePort") 
     screen.SetMessagePort(port)
     screen.SetTitle(title)
     screen.SetText(default)
     screen.SetDisplayText(dspText)
     screen.SetMaxLength(45)
     screen.AddButton(1, "next")
     'screen.AddButton(2, "back")
     screen.Show() 
  
     while true
         msg = wait(0, screen.GetMessagePort()) 
         if type(msg) = "roKeyboardScreenEvent"
             if msg.isScreenClosed()
                 return -1
             else if msg.isButtonPressed() then
                 print "Evt:"; msg.GetMessage ();" idx:"; msg.GetIndex()
                 if msg.GetIndex() = 1
                     textInput = screen.GetText()
                     print "textInput: "; textInput
                     return textInput 
                 endif
             endif
         endif
     end while 
END FUNCTION
