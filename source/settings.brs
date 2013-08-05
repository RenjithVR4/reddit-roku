Function getSetting(name as String) As Dynamic
     sec = CreateObject("roRegistrySection", "Authentication")
     if sec.Exists(name) 
         return sec.Read(name)
     endif
     return invalid
End Function


Function setSetting(name As String, value) As Void
    sec = CreateObject("roRegistrySection", "Authentication")
    sec.Write(name, value)
    sec.Flush()
End Function

Function deleteSetting(name as String) As Dynamic
     sec = CreateObject("roRegistrySection", "Authentication")
     if sec.Exists(name) 
         return sec.Delete(name)
     endif
     return invalid
End Function


Function getSettingsGridForHome()
	settings = CreateObject("roArray", 28, true)
	o = CreateObject("roAssociativeArray")
	o.Title = "Settings"
	o.self = true
	o.SDPosterUrl = "pkg:/images/settings.jpg"
	o.HDPosterUrl = "pkg:/images/settings.jpg"
	settings.Push(o)
	L = CreateObject("roAssociativeArray")
	L.self = true
	if(isLoggedIn() = true)
		username = getSetting("username")
		L.Title = username + " - Logout"
		L.SDPosterUrl = "http://www.dudelol.com/thumbs/power-outlet-style.jpg"
		L.HDPosterUrl = "http://www.dudelol.com/thumbs/power-outlet-style.jpg"	
	else		
		L.Title = "Login"
		L.SDPosterUrl = "http://www.dudelol.com/thumbs/power-outlet-style.jpg"
		L.HDPosterUrl = "http://www.dudelol.com/thumbs/power-outlet-style.jpg"			
	END IF
	settings.Push(L)
	return settings
	
END FUNCTION

function getTimerSetting() as String
'default 10 seconds
timer = getSetting("timer")
	if(timer <> invalid)
		return timer
	else
		return "5"
	end if

END FUNCTION

function getShowTitleSetting() as String
'default "yes"
display= getSetting("showTitle")
	if(display <> invalid)
		return display
	else
		return "yes"
	end if

END FUNCTION


Function settingsGrid()
	port=CreateObject("roMessagePort")
	grid = CreateObject("roGridScreen")
    grid.SetMessagePort(port)
    grid.SetDisplayMode("scale-to-fit")
    grid.SetGridStyle("Flat-Square")

    grid.SetupLists(1)
	rowTitles = CreateObject("roArray", 1, true)
    rowTitles.Push("Settings")
    grid.SetListNames(rowTitles) 
	
	list = CreateObject("roArray", 10, true)
    timer = CreateObject("roAssociativeArray")
    timer.Title = "Slide Show Timer"
	timer.name = "timer"
	timer.SDPosterUrl = "pkg:/images/settings.jpg"
	timer.HDPosterUrl = "pkg:/images/settings.jpg"

	timerSetting =getTimerSetting()
	timer.Description =  "currently: "+timerSetting + " seconds"
    list.Push(timer)
	display = CreateObject("roAssociativeArray")
    display.Title = "Show title of Reddit post at the bottom of the screen?"
	display.SDPosterUrl = "pkg:/images/settings.jpg"
	display.HDPosterUrl = "pkg:/images/settings.jpg"
	display.name = "displayTitle"
	displaySetting =getShowTitleSetting()
	display.Description = "currently: "+displaySetting
    list.Push(display)
	grid.SetContentList(0, list) 
	grid.Show()
 
	while true
         msg = wait(0, port)
         if type(msg) = "roGridScreenEvent" then
             if msg.isScreenClosed() then
                 return -1
             elseif msg.isListItemFocused()
                 print "Focused msg: ";msg.GetMessage();"row: ";msg.GetIndex();
                 print " col: ";msg.GetData()
             elseif msg.isListItemSelected()
                print "Selected msg: ";msg.GetMessage();"row: ";msg.GetIndex();
                print " col: ";msg.GetData()
				row = msg.GetIndex()
				col = msg.GetData()
				name = list[col].name
				
				IF(name = "timer" )
					changeTimerGrid()
					settingsGrid()
					return -1
				ELSE IF(name = "displayTitle" )
					changeDisplayGrid()
					settingsGrid()
					return -1					 
				END IF
				 
				 
             endif
         endif
     end while
	
	
END FUNCTION


Function changeTimerGrid()
	port=CreateObject("roMessagePort")
	grid = CreateObject("roGridScreen")
    grid.SetMessagePort(port)
    grid.SetDisplayMode("scale-to-fit")
    grid.SetGridStyle("Flat-Square")

    grid.SetupLists(1)
	rowTitles = CreateObject("roArray", 1, true)
	currentSeconds = getTimerSetting()
    rowTitles.Push("Timer seconds, currently: " + currentSeconds + " seconds")
    grid.SetListNames(rowTitles) 
	
	list = CreateObject("roArray", 20, true)
	for i = 1 to 18 - 1
		seconds = (i*5).tostr()
		timer = CreateObject("roAssociativeArray")
		timer.Title = seconds + " seconds"
		timer.ShortDescriptionLine1 = "How many seconds between each post?"
		timer.seconds = seconds
		timer.SDPosterUrl = "pkg:/images/settings.jpg"
		timer.HDPosterUrl = "pkg:/images/settings.jpg"
		list.Push(timer)
	end for


	grid.SetContentList(0, list) 
	grid.Show()
 
	while true
         msg = wait(0, port)
         if type(msg) = "roGridScreenEvent" then
             if msg.isScreenClosed() then
                 return -1
             elseif msg.isListItemFocused()
                 print "Focused msg: ";msg.GetMessage();"row: ";msg.GetIndex();
                 print " col: ";msg.GetData()
             elseif msg.isListItemSelected()
                print "Selected msg: ";msg.GetMessage();"row: ";msg.GetIndex();
                print " col: ";msg.GetData()
				row = msg.GetIndex()
				col = msg.GetData()
				 
				newTime = list[col].seconds
				setSetting("timer", newTime) 
				print "changed timer settings to " + newTime
				 return -1
             endif
         endif
     end while
END FUNCTION

function changeDisplayGrid()
	port=CreateObject("roMessagePort")
	grid = CreateObject("roGridScreen")
    grid.SetMessagePort(port)
    grid.SetDisplayMode("scale-to-fit")
    grid.SetGridStyle("Flat-Square")

    grid.SetupLists(1)
	rowTitles = CreateObject("roArray", 1, true)
	currentDisplay = getShowTitleSetting()
    rowTitles.Push("Display the Reddit post title at the bottom? currently: " + currentDisplay)
    grid.SetListNames(rowTitles) 
	
	list = CreateObject("roArray", 2, true)
	yes = CreateObject("roAssociativeArray")
	yes.Title = "yes"
	yes.option = "yes"
	yes.SDPosterUrl = "pkg:/images/settings.jpg"
	yes.HDPosterUrl = "pkg:/images/settings.jpg"
	list.Push(yes)

	no = CreateObject("roAssociativeArray")
	no.Title = "no"
	no.option = "no"
	no.SDPosterUrl = "pkg:/images/settings.jpg"
	no.HDPosterUrl = "pkg:/images/settings.jpg"
	list.Push(no)
	
	grid.SetContentList(0, list) 
	grid.Show()
 
	while true
         msg = wait(0, port)
         if type(msg) = "roGridScreenEvent" then
             if msg.isScreenClosed() then
                 return -1
             elseif msg.isListItemFocused()
                 print "Focused msg: ";msg.GetMessage();"row: ";msg.GetIndex();
                 print " col: ";msg.GetData()
             elseif msg.isListItemSelected()
                print "Selected msg: ";msg.GetMessage();"row: ";msg.GetIndex();
                print " col: ";msg.GetData()
				row = msg.GetIndex()
				col = msg.GetData()
				 
				option = list[col].option
				setSetting("showTitle", option) 
				print "changed display title setting:  " + option
				 return -1
             endif
         endif
     end while
END FUNCTION