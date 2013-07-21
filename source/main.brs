Function Main()
     port = CreateObject("roMessagePort")
    grid = CreateObject("roGridScreen")
    grid.SetMessagePort(port) 
	' grid.SetDisplayMode("zoom-to-fill")
	' grid.SetDisplayMode("photo-fit")
	grid.SetDisplayMode("scale-to-fit")
    subReddits = CreateObject("roArray", 30, true)
    subReddits.Push("/r/funny")
	subReddits.Push("/r/pics")
    subReddits.Push("/r/adviceanimals")
    subReddits.Push("/r/aww")
    subReddits.Push("/r/books")
    subReddits.Push("/r/earthporn")
    subReddits.Push("/r/explainlikeimfive")
    subReddits.Push("/r/gaming")
    subReddits.Push("/r/gifs")
    subReddits.Push("/r/IAmA")
    subReddits.Push("/r/movies")
    subReddits.Push("/r/news")
    subReddits.Push("/r/science")
    subReddits.Push("/r/technology")
    subReddits.Push("/r/television")
    subReddits.Push("/r/todayilearned")
    subReddits.Push("/r/worldnews")
    

    grid.SetupLists(subReddits.Count())
    grid.SetListNames(subReddits) 
    for j = 0 to subReddits.Count() - 1
		list = CreateObject("roArray", 10, true)
		title = subReddits[j]
		api_url = "http://www.reddit.com" + title + ".json"
		print api_url
		json = fetch_JSON(api_url)
		print json
		for each post in json.data.children
				 o = CreateObject("roAssociativeArray")
				 o.ContentType = "episode"
				 o.Title = post.data.title
				 o.SDPosterUrl = post.data.thumbnail
				 o.HDPosterUrl = post.data.thumbnail
				 o.ShortDescriptionLine1 = "[ShortDescriptionLine1]"
				 o.ShortDescriptionLine2 = "[ShortDescriptionLine2]"
				 o.Description = ""
				 o.Description = "[Description] "
				 o.Rating = "NR"
				 o.StarRating = "75"
				 o.ReleaseDate = "[<mm/dd/yyyy]"
				 o.Length = 5400
				 o.Actors = []
				 o.Actors.Push("[Actor1]")
				 o.Actors.Push("[Actor2]")
				 o.Actors.Push("[Actor3]")
				 o.Director = "[Director]"
				 list.Push(o)
		
		end for
         grid.SetContentList(j, list) 
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
             endif
         endif
     end while
End Function


Function fetch_JSON(url as string) as Object

    print "fetching new JSON"

    xfer=createobject("roURLTransfer")
    xfer.seturl(url)
    data=xfer.gettostring()
    json = ParseJSON(data)

    return json
End Function


