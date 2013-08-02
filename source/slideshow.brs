
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

function showSlideShow(originalList,start, port)
	after = getTheAfter(originalList)	
	list= removeSelfPosts(originalList)
	activeListCount = list.count()
    s = CreateObject("roSlideShow")
    s.SetMessagePort(port)
	s.SetTextOverlayHoldTime(9000)   ' 1 second = 1000 milaseconds
	' s.SetTextOverlayIsVisible(true)
	s.SetUnderscan(3) ' gives a padding around the image because TVs cut off the outer part of the image sometimes
	' s.SetDisplayMode("photo-fit") 'I think default is best
	s.SetPeriod(9) ' dont need this
	
	s.SetContentList(list)
    s.Show()
	s.SetNext(start, true)
	
	msg = "declaring"
	loading = false
	row = invalid
	
	while true
         
		 
		 		if(after <> invalid)
						subReddit = list[0].subReddit
						newList = loadMorePosts(subReddit, after)
						after = getTheAfter(newList)	
									
						newListRemovedSelf = removeSelfPosts(newList)
						
						'make sure the new subreddits we found contained at least one image
						if(newListRemovedSelf.count() > 1)
							print "adding more posts count= " + newListRemovedSelf.count().tostr()
							list.Append(newListRemovedSelf)	
						END IF
				END IF
		 
		 msg = wait(0, port)
         if type(msg) = "roSlideShowEvent" then
             if msg.isScreenClosed() then
				'return the list that also contains the self posts
				originalList.Append(list)
                 return originalList 'when the user closes the screen return any new reddit posts we downloaded
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
					print "showing row= " + row.tostr()
			

						IF row = (activeListCount -1 ) THEN
							'load more reddit posts
							's.AddContent(newListRemovedSelf)
							s.ClearContent()
							s.SetContentList(list)
							activeListCount = list.count()
							s.Show()
							s.SetNext(row, false)
							print "Forcing the slideshow to row= " +row.tostr() 
							print "but we have activelist=" + activeListCount.tostr()
							
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


FUNCTION removeSelfPosts(list) as Object
	tmpList = CreateObject("roArray", 122, true)

	for each post in list
		if (post.self=false) then
			tmpList.Push(post)
		END IF
	end for
	
	return tmpList
END FUNCTION


FUNCTION removeOldLoadMore(list) as Object
	tmpList = CreateObject("roArray", 122, true)

	for each post in list
		if (post.DoesExist("after")=false) then
			tmpList.Push(post)
			'print("not the after")
		else
			'print "this the after"
		END IF
	end for
	
	return tmpList
END FUNCTION
