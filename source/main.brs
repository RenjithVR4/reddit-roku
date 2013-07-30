Library "v30/bslCore.brs"

Function Main()


	' Pop up start of UI for some instant feedback while we load the icon data
	poster=uitkPreShowPosterMenu()
	if poster=invalid then
		print "unexpected error in uitkPreShowPosterMenu"

	end if


	initTheme()

	port=CreateObject("roMessagePort")
    grid = CreateObject("roGridScreen")
    grid.SetMessagePort(port)
    grid.SetDisplayMode("scale-to-fit")
    grid.SetGridStyle("Flat-Square")

	
    subReddits = CreateObject("roArray", 30, true)
    subReddits.Push("/r/funny")
	subReddits.Push("/r/pics")
  '  subReddits.Push("/r/adviceanimals")
   ' subReddits.Push("/r/aww")
  '  subReddits.Push("/r/books")
   ' subReddits.Push("/r/earthporn")
  '  subReddits.Push("/r/explainlikeimfive")
  '  subReddits.Push("/r/gaming")
    subReddits.Push("/r/gifs")
  '  subReddits.Push("/r/IAmA")
   ' subReddits.Push("/r/treecomics")
   ' subReddits.Push("/r/news")
   ' subReddits.Push("/r/science")
   ' subReddits.Push("/r/technology")
   ' subReddits.Push("/r/television")
   ' subReddits.Push("/r/todayilearned")
   ' subReddits.Push("/r/worldnews")
    

    grid.SetupLists(subReddits.Count())
    grid.SetListNames(subReddits) 
	list = CreateObject("roArray", 30, true)
	
    for j = 0 to subReddits.Count() - 1
		list[j] = CreateObject("roArray", 10, true)
		title = subReddits[j]
		api_url = "http://www.reddit.com" + title + ".json"
		
		print api_url
		json = fetch_JSON(api_url)
		print json
		for each post in json.data.children
				
				 url = fixImgur(post.data.url)
				 if(isGood(url) = false)
				   print "Its not an img!"
				   
				 else
					 ups = post.data.ups.tostr()
					 downs = post.data.downs.tostr()
					 o = CreateObject("roAssociativeArray")
					 o.ContentType = "episode"
					 o.Title = post.data.title
					 o.Url = url
					 o.SDPosterUrl = post.data.thumbnail
					 o.HDPosterUrl = post.data.thumbnail
					 o.ShortDescriptionLine1 = "Upvotes: " + ups + " - Downvotes: " + downs
					 o.ShortDescriptionLine2 = post.data.url
					 o.Description = "Upvotes: " + ups + " - Downvotes: " + downs + "     " + post.data.url
					 o.Rating = "NR"
					 o.StarRating = "100"
					 o.ReleaseDate = "[<mm/dd/yyyy]"
					 o.Length = 5400
					 o.Actors = []
					 o.Actors.Push("Posted by: "+ post.data.author)
					 o.Actors.Push("domain: " + post.data.domain)
					 o.Actors.Push("[Actor3]")
					 o.Director = "[Director]"
					 list[j].Push(o)
				 
				 endif
		
		end for
         grid.SetContentList(j, list[j]) 
     end for 
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
				 'print list[msg.GetData()].url
				 showSlideShow(list[msg.GetIndex()][msg.GetData()].url,port)
				 ' showImg(list[msg.GetIndex()][msg.GetData()].url)
				' showImg("http://dudelol.com/img/took-way-to-long-for-me-to-notice.jpeg")
				'  showImg("http://www.dudelol.com/img/doesnt-matter-had-sex39666.jpeg")
             endif
         endif
     end while
End Function

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

    theme.ThemeType = "generic-dark"

    ' All these are greyscales
    theme.GridScreenBackgroundColor = "#363636"
    theme.GridScreenMessageColor    = "#808080"
    theme.GridScreenRetrievingColor = "#CCCCCC"
    theme.GridScreenListNameColor   = "#FFFFFF"

    ' Color values work here
    theme.GridScreenDescriptionTitleColor    = "#001090"
    theme.GridScreenDescriptionDateColor     = "#FF005B"
    theme.GridScreenDescriptionRuntimeColor  = "#5B005B"
    theme.GridScreenDescriptionSynopsisColor = "#606000"
    
    'used in the Grid Screen
    theme.CounterTextLeft           = "#FF0000"
    theme.CounterSeparator          = "#00FF00"
    theme.CounterTextRight          = "#0000FF"
	
	theme.GridScreenLogoHD          = "pkg:/images/reddit-logo-hd.png"
	
    theme.GridScreenLogoOffsetHD_X  = "30"
    theme.GridScreenLogoOffsetHD_Y  = "15"
    theme.GridScreenOverhangHeightHD = "114"

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

function createScreenDescription(topx, topy, width ,height, screenwidth, screenheight, par)
    description1 = str(width)+"x"+str(height)
    description2 = "No Sidebars"
    if (topx)
        description2 = "sidebar=" + str(topx)
    endif
    if (topy)
        description2 = "letterbox=" + str(topy)
    endif
       
    return {    ShortDescriptionLine1: description1,
                ShortDescriptionLine2: description2,
                drawwidth: width,
                drawheight: height,
                screenwidth: screenwidth,
                screenheight: screenheight,
                par: par,
                drawtopx: topx,
                drawtopy: topy,
            }
end function