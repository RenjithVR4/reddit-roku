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

Function parseJsonPosts(json)
	tmpList = CreateObject("roArray", 28, true)
	subReddit = "declared"
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

Function fetch_JSON(url as string) as Object

    print "fetching new JSON"

    xfer=createobject("roURLTransfer")
    xfer.seturl(url)
    data=xfer.gettostring()
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

