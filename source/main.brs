Library "v30/bslCore.brs"

Function Main()
	initTheme()
	loadMainGrid()
End Function

function loadMainGrid()
	port=CreateObject("roMessagePort")
    grid = CreateObject("roGridScreen")
    grid.SetMessagePort(port)
    grid.SetDisplayMode("scale-to-fit")
    grid.SetGridStyle("Flat-Square")

	subReddits = getSubreddits()

    grid.SetupLists(subReddits.Count())
    grid.SetListNames(subReddits) 
	list = CreateObject("roArray", 30, true)
	

	
    for j = 0 to subReddits.Count() - 1
	if (j=0) then
		settings = getSettingsGrid()
		grid.SetContentList(0, settings)
	else
		list[j] = CreateObject("roArray", 28, true)
		subReddit = subReddits[j]
		
		list[j] = loadMorePosts(subReddit,"")
		
		
        grid.SetContentList(j, list[j]) 
	END IF
     end for 
	 
	 grid.SetFocusedListItem(2,0)
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
				 'selectedGrid = 
				 
				 IF (row=0 AND col=1) THEN
					'show the login screen
					if(isLoggedIn() = true) THEN
						logout()
					else
						login()
					END IF
				 ELSE 
				 
				 list[msg.GetIndex()] = showSlideShow(list[msg.GetIndex()],msg.getData(), port)
				 'populate any new reddit posts we got during the slideshow
				 grid.SetContentList(msg.GetIndex(), list[msg.GetIndex()]) 
				 'send the user back to the original location in the grid
				 grid.SetListOffset(msg.GetIndex(),msg.getData())
				 END IF
				 
             endif
         endif
     end while
END FUNCTION


function getSubreddits()
'subReddits = CreateObject("roArray", 300, true)
'subReddits.Push("settings")
'subReddits.Push("aww")
'return subReddits


	if(isLoggedIn() = true)
		blocked = getBlockedSubreddits()
		subReddits = CreateObject("roArray", 300, true)
		'always include these subreddits first
		subReddits.Push("Settings")
		subReddits.Push("funny")
		subReddits.Push("pics")
		http = NewHttp2("http://www.reddit.com/reddits/mine.json", "application/json")
		response= http.GetToStringWithTimeout(90)
		json = ParseJSON(response)
		for each post in json.data.children	
			found = false
			'block the blocked subreddits
			for i = 0 to blocked.Count() - 1 
				name =  LCase(post.data.display_name)
				if (name = blocked[i]) THEN
					found = true
				END IF
			end for
			if(found = false) THEN
					subReddits.Push(name)
			END IF
		end for
		
		if(subReddits.Count() < 3)
			subReddits = getDefaultSubreddits()
		END IF
		return subReddits
	else
		subReddits =getDefaultSubreddits()
		return subReddits

   END IF

END FUNCTION







Sub initTheme()
    app = CreateObject("roAppManager")
    app.SetTheme(CreateDefaultTheme())
End Sub
'******************************************************
'** @return The default application theme.
'** Screens can make slight adjustments to the default
'** theme by getting it from here and then overriding
'** individual theme attributes.
'******************************************************
Function CreateDefaultTheme() as Object
    theme = CreateObject("roAssociativeArray")

    theme.ThemeType = "generic-white"

    ' All these are greyscales
    theme.GridScreenBackgroundColor = "#ffffff"
    theme.GridScreenMessageColor    = "#000000"
    theme.GridScreenRetrievingColor = "#000000"
    theme.GridScreenListNameColor   = "#000000"

    ' Color values work here
    theme.GridScreenDescriptionTitleColor    = "#000000"
    theme.GridScreenDescriptionDateColor     = "#FF005B"
    theme.GridScreenDescriptionRuntimeColor  = "#5B005B"
    theme.GridScreenDescriptionSynopsisColor = "#606000"
    
    'used in the Grid Screen
    theme.CounterTextLeft           = "#000000"
    theme.CounterSeparator          = "#000000"
    theme.CounterTextRight          = "#000000"
	
	theme.GridScreenLogoHD          = "pkg:/images/reddit-logo-hd.png"
	
    theme.GridScreenLogoOffsetHD_X  = "35"
    theme.GridScreenLogoOffsetHD_Y  = "23"
    theme.GridScreenOverhangHeightHD = "124"

    theme.GridScreenLogoSD          = "pkg:/images/reddit-logo-sd.png"
    theme.GridScreenOverhangHeightSD = "81"
    theme.GridScreenLogoOffsetSD_X  = "30"
    theme.GridScreenLogoOffsetSD_Y  = "15"
    
    ' to use your own focus ring artwork 
    'theme.GridScreenFocusBorderSD        = "pkg:/images/GridCenter_Border_Movies_SD43.png"
    'theme.GridScreenBorderOffsetSD  = "(-26,-25)"
    'theme.GridScreenFocusBorderHD        = "pkg:/images/GridCenter_Border_Movies_HD.png"
    'theme.GridScreenBorderOffsetHD  = "(-28,-20)"
    
    ' to use your own description background artwork
    'theme.GridScreenDescriptionImageSD  = "pkg:/images/Grid_Description_Background_SD43.png"
    'theme.GridScreenDescriptionOffsetSD = "(125,170)"
    'theme.GridScreenDescriptionImageHD  = "pkg:/images/Grid_Description_Background_HD.png"
    'theme.GridScreenDescriptionOffsetHD = "(190,255)"
    

    return theme
End Function


Function showMessage(msg As String)
	port = CreateObject("roMessagePort") 
	dialog = CreateObject( "roOneLineDialog" )
	dialog.SetMessagePort(port)
	dialog.SetTitle( msg )
	dialog.Show()
	sleep(4000)
	return -1
END FUNCTION 


Function IsHD()
    di = CreateObject("roDeviceInfo")
    if di.GetDisplayType() = "HDTV" then return true
    return false
End Function