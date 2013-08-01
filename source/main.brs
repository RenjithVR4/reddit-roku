Library "v30/bslCore.brs"

Function Main()

	initTheme()
	
	setSetting("someSetting", "some Value!!")
	print getSetting("someSetting")

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
		api_url = "http://www.reddit.com/r/" + subReddit + ".json"
		print "original api_url= " + api_url
		json = fetch_JSON(api_url)
		list[j] = parseJsonPosts(json) 
		
		
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
					login()
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
End Function

function getDefaultSubreddits()
    subReddits = CreateObject("roArray", 30, true)
	subReddits.Push("Settings")
    subReddits.Push("funny")
	subReddits.Push("pics")
    subReddits.Push("adviceanimals")
    subReddits.Push("aww")
  '  subReddits.Push("books")
   ' subReddits.Push("earthporn")
  '  subReddits.Push("explainlikeimfive")
  '  subReddits.Push("gaming")
   ' subReddits.Push("gifs")
  '  subReddits.Push("IAmA")
   ' subReddits.Push("treecomics")
   ' subReddits.Push("news")
   ' subReddits.Push("science")
   ' subReddits.Push("technology")
   ' subReddits.Push("television")
   ' subReddits.Push("todayilearned")
   ' subReddits.Push("worldnews")
   return subReddits
END FUNCTION

function getBlockedSubreddits()
    subReddits = CreateObject("roArray", 30, true)
    subReddits.Push("funny")
	subReddits.Push("pics")
    subReddits.Push("books")
    subReddits.Push("announcements")
    subReddits.Push("explainlikeimfive")
    subReddits.Push("videos")
    subReddits.Push("gifs")
  '  subReddits.Push("IAmA")
   ' subReddits.Push("treecomics")
    subReddits.Push("news")
    subReddits.Push("blog")
   ' subReddits.Push("technology")
   ' subReddits.Push("television")
    subReddits.Push("todayilearned")
    subReddits.Push("worldnews")
   return subReddits
END FUNCTION

function getSubreddits()
subReddits = CreateObject("roArray", 300, true)
subReddits.Push("settings")
subReddits.Push("aww")
return subReddits


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

Function getSettingsGrid()
	settings = CreateObject("roArray", 28, true)
	o = CreateObject("roAssociativeArray")
	o.Title = "Settings"
	o.SDPosterUrl = "http://www.dudelol.com/thumbs/your-thinking-beard-will-help.jpg"
	o.HDPosterUrl = "http://www.dudelol.com/thumbs/your-thinking-beard-will-help.jpg"
	settings.Push(o)
	o = CreateObject("roAssociativeArray")
	o.Title = "Login"
	o.SDPosterUrl = "http://www.dudelol.com/thumbs/power-outlet-style.jpg"
	o.HDPosterUrl = "http://www.dudelol.com/thumbs/power-outlet-style.jpg"	
	settings.Push(o)
	return settings
	
END FUNCTION

Function parseJsonPosts(json)
	tmpList = CreateObject("roArray", 28, true)
	subReddit = "declared"
	print "loading more in parseJsonPosts"
	for each post in json.data.children		
				 IF(subReddit = "declared")
					subReddit = post.data.subreddit
				 END IF
				 
				 url = fixImgur(post.data.url)
				 
				 if(isGood(url) = false)
					 print "Its not an img!"			   
				 else
					 ups = post.data.ups.tostr()
					 downs = post.data.downs.tostr()
					 o = CreateObject("roAssociativeArray")
					 o.ContentType = "episode"
					 o.Title = post.data.title
					 o.TextOverlayBody = post.data.title
					 o.Url = url
					 print "url="+url
					 print "thumb=" + post.data.thumbnail
					 o.SDPosterUrl = post.data.thumbnail
					 o.HDPosterUrl = post.data.thumbnail
					 o.ShortDescriptionLine1 = "Upvotes: " + ups + " - Downvotes: " + downs
					 o.ShortDescriptionLine2 = post.data.url
					 o.Description = "Upvotes: " + ups + " - Downvotes: " + downs + "     " + post.data.url
					 o.Rating = "NSFW"
					 o.ups = ups
					 o.downs = downs
					 o.id = post.data.id
					 o.selftext = post.data.selftext
					 o.StarRating = "100"
					 o.ReleaseDate = "[<mm/dd/yyyy]"
					 o.Length = 5400
					 o.Actors = []
					 o.Actors.Push("Posted by: "+ post.data.author)
					 o.Actors.Push("domain: " + post.data.domain)
					 o.Actors.Push("[Actor3]")
					 o.Director = "[Director]"
					 o.Font = "Large"
					 o.TextAttrs = { 
									Color:"#FFCCCCCC", 
									Font:"Large", 
									HAlign:"HCenter", 
									VAlign:"VCenter", 
									Direction:"LeftToRight" 
									}
					 tmpList.Push(o)
				 endif
		end for
		
		'need to store the after variable we can load the next set of posts
		more = CreateObject("roAssociativeArray")		
		more.After = json.data.after 
		more.Title = "Load More"
		more.Url = "pkg:/images/loading.png" 'shows the loading screen
		'get the subreddit from the json
		print subReddit
		more.SubReddit = subReddit		
		tmpList.Push(more)
		'return the new subreddit posts
		return tmpList
END FUNCTION

Function isGood(url as string) as Boolean
	if(isImg(url) = false OR isGallery(url) = false OR isGif(url) = false)
		return false
	else
		return true
	endif
End Function

Function isGif(url as string) as Boolean
	if(right(url, 3) <> "gif")
		return true
	else
		return false
	endif
End Function

Function fixImgur(url as string) as String
if(Instr(1, url, "imgur.com")=0) 'if the domain is not imgur return the original URL
	return url
END IF

if right(url, 3) <> "jpg" AND right(url, 3) <> "png" AND right(url, 4) <> "jpeg"  then
	url = url + ".jpg"
endif
	return url
End Function

Function isImg(url as string) As Boolean
	if right(url, 3) <> "jpg" AND right(url, 3) <> "png" AND right(url, 3) <> "gif" AND right(url, 4) <> "jpeg"  then
		return false
	else
		return true
	endif
End Function

Function isGallery(url as string) As Boolean
	if Instr(1, url, "imgur.com/a/") > 0 then
		return false
	else
		return true
	endif
End Function

Function fetch_JSON(url as string) as Object

    print "fetching new JSON"

    xfer=createobject("roURLTransfer")
    xfer.seturl(url)
    data=xfer.gettostring()
    json = ParseJSON(data)

    return json
End Function



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