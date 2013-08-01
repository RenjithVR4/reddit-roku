
function addButtons(s) as Object
s.AddButton(1, "Resume") 
s.AddButton(2, "Upvote") 
s.AddButton(3, "Downvote") 
s.AddButton(4, "View Comments") 
s.AddButton(5, "Save Post") 
s.AddButton(6, "View Full Img(Beta)") 
s.AddButton(7, "Hide Title Text Overlay") 
return s
end function

function showSlideShow(list,start, port)
    s = CreateObject("roSlideShow")
    s.SetMessagePort(port)
	s.SetTextOverlayHoldTime(1000)   ' 1 second = 1000 milaseconds
	' s.SetTextOverlayIsVisible(true)
	s.SetUnderscan(3) ' gives a padding around the image because TVs cut off the outer part of the image sometimes
	' s.SetDisplayMode("photo-fit") 'I think default is best
	s.SetPeriod(1) ' dont need this
	
	s.SetContentList(list)
    s.Show()
	s.SetNext(start, true)
	
	msg = "declaring"
	loading = false
	row = invalid
	
	while true
         msg = wait(0, port)
         if type(msg) = "roSlideShowEvent" then
             if msg.isScreenClosed() then
                 return list 'when the user closes the screen return any new reddit posts we downloaded
			 end if
			 if msg.isPaused() then
				print "adding btns"
                 s = addButtons(s)
			 end if
			 if msg.isResumed() then
				print "removing btns"
                 s.ClearButtons()
			 end if
			 IF msg.isPlaybackPosition() THEN
			 
				row = msg.GetIndex()   'keeps the variable row supplied with the list index
			    IF msg.GetIndex() = (list.count() -1) THEN
					'load more reddit posts
					s.Pause()

					originalIndex = list.count() -1
					after = list[list.count() -1].After
					subReddit = list[list.count() -1].subReddit
					print "attempting to get the after= " + after
					api_url = "http://www.reddit.com/r/" + subReddit + ".json?after=" + after
					print "api_url="+ api_url
					json = fetch_JSON(api_url)
					newList = parseJsonPosts(json)
					
					'remove the last array entry because it contains the old After 					
					list.Pop()
					list.Append(newList)
					print "done adding to the list"
					
					'add the new content to the list
					's.AddContent(newList)  'AddContent wont work because we have to remove the old "after", but we can .Pop() it then do reset the content to the new list
					s.ClearContent()
					s.SetContentList(list)
					s.Show()
					s.SetNext(originalIndex, true)
					s.Resume()

					
				END IF
			 END IF
			 if msg.isButtonPressed() then
				IF msg.GetIndex() = 1 THEN
					print "User hit resume"
					s.ClearButtons()
					s.Resume()
				END IF
				IF msg.GetIndex() = 2 THEN
					print "User hit upvote btn"
				END IF
				IF msg.GetIndex() = 3 THEN
					print "User hit downvote btn"
				END IF
				IF msg.GetIndex() = 4 THEN
					print "view comments"
					showComments(list[row])
				END IF
				IF msg.GetIndex() = 5 THEN
					print "save post"
				END IF
				IF msg.GetIndex() = 6 THEN
					print "view full img"
				END IF
				IF msg.GetIndex() = 7 THEN
					print "hide text overlay"
					s.SetTextOverlayIsVisible(false)
					s.ClearButtons()
					s.Resume()
				END IF
				end if
			 
		 end if
    end while
	
End function

