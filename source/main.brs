Library "v30/bslCore.brs"

Function Main()
	initTheme()
	loadMainGrid()
End Function

sub loadMainGrid()
	port=CreateObject("roMessagePort")
	subReddits = getSubreddits()
	countSubreddits = subReddits.Count()
	
	
	grid = CreateObject("roGridScreen")
	grid.SetMessagePort(port)

    grid.SetupLists(countSubreddits)
    grid.SetListNames(subReddits)  'we are now setting these asyncornously
    grid.SetDisplayMode("scale-to-fit")
    grid.SetGridStyle("flat-16x9")
    grid.Show() 
	'dialog = showLoadingScreen("Loading subreddits: 0/" +countSubreddits.tostr(),port)
	
	list = CreateObject("roArray", 100, true)
	
	settings = getSettingsGridForHome()
	'grid.SetListName(0,"Settings")
	grid.SetContentList(0, settings)
	
	request = CreateObject("roArray", 100, true)
	'httpPort=CreateObject("roMessagePort")
	for j = 1 to subReddits.Count() -1
		request[j] = CreateObject("roUrlTransfer")
		request[j].SetMessagePort(port)
		subReddit = subReddits[j]
		api_url = "http://www.reddit.com/r/" + subReddit + ".json"
		request[j].SetUrl(api_url)
		request[j].AsyncGetToString()
		print "init list " + j.tostr()
	end for
	
	
	countListAsync = 1 'counting the list but for when the async returns
	
	while true
	print "in awhile"
         msg = wait(0, port)
		 
		if (type(msg) = "roUrlEvent")
			code = msg.GetResponseCode()
			if (code = 200)
				newList = invalid
				response = msg.GetString()
				json = ParseJSON(response)
				if(json = invalid)
					'do nothing
				else
					newList = parseJsonPosts(json)
					subRedditName = newList[0].subReddit
					if(subRedditName <> invalid)
						print "got the subreddit= " + subRedditName
						grid.SetListName(countListAsync,subRedditName)
						'grid.SetListName(countListAsync,"test")
					end if
					list[countListAsync] = newList								
					if(list[countListAsync] = invalid)
						'build a failed to load icon for the grid
						list[countListAsync] = buildErrorGrid()
					END IF
					
					grid.SetContentList(countListAsync, list[countListAsync])
					grid.show()
				'	dialog.SetTitle( "Loading subreddits: "+countListAsync.tostr()+ "/" + countSubreddits.tostr() )
				'	dialog.Show()
					'print "adding another grid = " +countListAsync.tostr()
					
					'print "[" + msg.GetString() + "]"
				END IF
				countListAsync = countListAsync+1
				if(countListAsync = countSubreddits)
					exit while
				end if
			END IF
		END IF 
	end while
	
	

	'grid.SetFocusedListItem(2,0)
	grid.show()
	'dialog.Close()
	
	sleep(20000)
	
    while true	
         msg = wait(0, port)

         if type(msg) = "roGridScreenEvent" then
             if msg.isScreenClosed() then
                 return
             elseif msg.isListItemFocused()
                 print "Focused msg: ";msg.GetMessage();"row: ";msg.GetIndex();
                 print " col: ";msg.GetData()
					 
             elseif msg.isListItemSelected()
                 print "Selected msg: ";msg.GetMessage();"row: ";msg.GetIndex();
                 print " col: ";msg.GetData()
				 row = msg.GetIndex()
				 col = msg.GetData()
				 
				 'login or logout
				if(row=0 AND col=2) THEN 'show settings grid
					showHelp()
				ELSE IF (row=0 AND col=1) THEN
					'show the login screen
					if(isLoggedIn() = true) THEN
						logout()
					else
						login()
					END IF 
				ELSE if(row=0 AND col=0) THEN 'show settings grid
					settingsGrid(port)
				 ELSE
				 'for images show a slideshow
				 if(list[row][col].self = false )
					list[row] = showSlideShow(list[row],list[row][col].id,port)
					'dialog = showLoadingScreen("Loading" ,port)
					'populate any new reddit posts we got during the slideshow
				    grid.SetContentList(row, list[row]) 
				    'send the user back to the original location in the grid
				    grid.SetListOffset(row,col)
					'dialog.close()
					
				 ELSE IF(list[row][col].name = "loadmore" )
					'load more posts for this subreddit
					dialog = showLoadingScreen( "loading MOAR",port)
					subReddit = list[row][col].subReddit
					after = getTheAfter(list[row])	
					list[row] = removeOldLoadMore(list[row])
					newPosts = loadMorePosts(subReddit,after)
					list[row].Append(newPosts) 
					dialog.Close()
				 
				 ELSE					
					'for self posts show the comments page
					showComments(list[row][col])
				 END IF
				 

				 END IF
				 
             endif
         endif
     end while
END sub

function buildSubredditGrid(grid, subRedditName,index)
	list = CreateObject("roArray",100, true)		
	list = loadMorePosts(subRedditName,"")
			
	if(list = invalid)
		'build a failed to load icon for the grid
		list = buildErrorGrid()
	END IF
			
	grid.SetContentList(index, list)
	grid.show()
	return list
			
END FUNCTION

function buildErrorGrid()
	tmpList = CreateObject("roArray", 2, true)
	o = CreateObject("roAssociativeArray")
	o.Title = "Error getting subreddit"
	tmpList.Push(o)
	return tmpList
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

    'theme.ThemeType = "generic-dark"
	
	black = "#000000"
	white = "#ffffff"
	hdLogo = "pkg:/images/reddit-logo-hd.png"
	sdLogo = "pkg:/images/reddit-logo-sd.png"
	
	theme.BackgroundColor = white
	theme.ParagraphBodyText = black
	
	theme.OverhangSliceHD = "pkg:/images/clear.png"
	theme.OverhangSliceSD = "pkg:/images/clear.png"
    theme.GridScreenBackgroundColor = white
    theme.GridScreenMessageColor    = black
    theme.GridScreenRetrievingColor = black
    theme.GridScreenListNameColor   = black
	
	'one msg dialog
	theme.ButtonMenuNormalOverlayText = white
	theme.ButtonMenuNormalText = black
	theme.ButtonNormalColor = black
	theme.DialogBodyText = black
	theme.ButtonHighlightColor = white
	theme.DialogTitleText = black


    ' Color values work here
    theme.GridScreenDescriptionTitleColor    = black
    theme.GridScreenDescriptionDateColor     = "#FF005B"
    theme.GridScreenDescriptionRuntimeColor  = "#5B005B"
    theme.GridScreenDescriptionSynopsisColor = "#606000"
    
    'used in the Grid Screen
    theme.CounterTextLeft           = black
    theme.CounterSeparator          = black
    theme.CounterTextRight          = black
	
	theme.GridScreenLogoHD          = hdLogo
	theme.OverhangPrimaryLogoHD     = sdLogo
    theme.GridScreenLogoOffsetHD_X  = "220"
    theme.GridScreenLogoOffsetHD_Y  = "25"
    theme.GridScreenOverhangHeightHD = "145"
	
	theme.OverhangPrimaryLogoOffsetHD_X = "220"
	theme.OverhangPrimaryLogoOffsetHD_Y = "15"


	
    theme.GridScreenLogoSD          = sdLogo
	theme.OverhangPrimaryLogoSD     = sdLogo
    theme.GridScreenLogoOffsetSD_X  = "160"
    theme.GridScreenLogoOffsetSD_Y  = "18"
	theme.GridScreenOverhangHeightSD = "100"
    
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
	sleep(3200)
	return -1
END FUNCTION 

Function showLoadingScreen(msg As String,port)
	dialog = CreateObject( "roOneLineDialog" )
	dialog.SetMessagePort(port)
	dialog.ShowBusyAnimation() 
	dialog.SetTitle( msg )
	dialog.Show()
	return dialog
END FUNCTION

Function IsHD()
    di = CreateObject("roDeviceInfo")
    if di.GetDisplayType() = "HDTV" then return true
    return false
End Function