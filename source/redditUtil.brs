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
    subReddits.Push("bestof")
    subReddits.Push("news")
    subReddits.Push("blog")
   ' subReddits.Push("technology")
   ' subReddits.Push("television")
    subReddits.Push("todayilearned")
    subReddits.Push("worldnews")
   return subReddits
END FUNCTION

FUNCTION loadMorePosts(subReddit,after)

	if(subReddit = invalid OR after = invalid)
		print "subreddit or after are invalid"
		return invalid
	END IF
	api_url = "http://www.reddit.com/r/" + subReddit + ".json?after=" + after
	http = NewHttp2(api_url, "application/json")
	response= http.GetToStringWithTimeout(90)
	json = ParseJSON(response)
	if(json = invalid)
		return invalid
	END IF
	newList = parseJsonPosts(json)
	return newList
END FUNCTION


Function parseJsonPosts(json)
	tmpList = CreateObject("roArray", 28, true)
	subReddit = "notdeclared"
	modhash = json.data.modhash
	if(modhash <> invalid)
		'print "updating new modhash="+ modhash
		setSetting("modhash", modhash)
	else
	print "modhash is invalid"
	END IF
	
	for each post in json.data.children		
				 IF(subReddit = "notdeclared")
					subReddit = post.data.subreddit			
				 END IF
				 
				 url = fixImgur(post.data.url)
				 self = post.data.is_self
				 
				 if((isGood(url) = false) AND (self = false))
					 'print "Its not an img!"			   
				 else
					 ups = post.data.ups.tostr()
					 downs = post.data.downs.tostr()
					 o = CreateObject("roAssociativeArray")
					 o.ContentType = "episode"
					 o.Title = post.data.title
					 o.TextOverlayBody = post.data.title
					 if(self=true)
						 o.Url = "pkg:/images/self.png" 
						 o.SDPosterUrl = "pkg:/images/self.png" 
						 o.HDPosterUrl = "pkg:/images/self.png" 
						 o.self = true
					 else
						 o.Url = url
						 o.SDPosterUrl = post.data.thumbnail
						 o.HDPosterUrl = post.data.thumbnail
						 o.self=false
					 END IF

					 o.ShortDescriptionLine1 = "Upvotes: " + ups + " - Downvotes: " + downs
					 o.ShortDescriptionLine2 = post.data.url
					 o.Description = "Upvotes: " + ups + " - Downvotes: " + downs + "     " + post.data.url
					 o.Rating = "NSFW"
					 o.subReddit = post.data.subreddit
					 o.ups = ups
					 o.downs = downs
					 o.id = post.data.id
					 o.selftext = post.data.selftext
					' o.StarRating = "100"
					' o.ReleaseDate = "[<mm/dd/yyyy]"
					' o.Length = 5400
					 o.minBandwidth = 20
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
		
		more.self=true 'the slideshow will update when it comes to this post
		more.Url = "pkg:/images/loading.png" 'shows the loading screen
		'get the subreddit from the json
		more.SubReddit = subReddit		
		tmpList.Push(more)
		'return the new subreddit posts
		return tmpList
END FUNCTION

function getSubreddits()
'subReddits = CreateObject("roArray", 300, true)
'subReddits.Push("settings")
'subReddits.Push("movies")
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



FUNCTION savePost(id as String)
	print "saving post id=" +id
	modhash = getSetting("modhash")
	http = NewHttp2("http://www.reddit.com/api/save", "application/json") 
	http.AddParam("id", id)
	http.AddParam("uh", modhash)
	response= http.PostFromStringWithTimeout("", 90)
	print response
	dumpArray(response[1])
	json = ParseJSON(response[1])
	print dumpArray(json)
END FUNCTION

FUNCTION getTheAfter(list) 
	after = "init"
	for each post in list
		if (post.DoesExist("after")=true) then 
			after = post.after
			if(post.after = invalid)
				return invalid
			END IF
			return post.after
			
		END IF
	end for
	
	print "couldnt find the after returning invalid"
	
	'after = list[list.count() - 1].Lookup(id)
	return invalid
	
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

Function fetch_JSON(url as string) as Object

    xfer=createobject("roURLTransfer")
    xfer.seturl(url)
    data=xfer.gettostring()
	if(data = "")
		return invalid
	END IF
    json = ParseJSON(data)

    return json
End Function

Function isGallery(url as string) As Boolean
	if Instr(1, url, "imgur.com/a/") > 0 then
		return false
	else
		return true
	endif
End Function

