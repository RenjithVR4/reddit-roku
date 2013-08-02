
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

	list= removeSelfPosts(originalList)
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
			    IF msg.GetIndex() = (list.count() -1) THEN
					'load more reddit posts
					s.Pause()
					originalIndex = list.count() -1
					after = list[list.count() -1].After
					subReddit = list[list.count() -1].subReddit
					newList = loadMorePosts(subReddit, after)
					
					'error checking
					if(newList = invalid) 
						print "Unable to get more posts, trying again"
						'return originalList
						if(originalIndex -2 > 0)
							originalIndex =originalIndex -2
							print "original index= " + originalIndex.tostr()
						END IF
						s.ClearContent()
						s.SetContentList(list)
						s.Show()
						s.SetNext(0, true)
						s.Resume()
					else
					
					newListRemovedSelf = removeSelfPosts(newList)
					
					'make sure the new subreddits we found contained at least one image
					if(newListRemovedSelf.count() > 1)
							
						'list.Pop() 'pop sucks
						'originalList.Pop() 'remove the last array entry because it contains the old After 
						list = removeOldLoadMore(list)
						originalList = removeOldLoadMore(originalList)
					
					else	
						print "WARNING: Found no new posts count =" + newListRemovedSelf.count().tostr()
					END IF
					
					'print "DUMPING newListRemovedSelf"
					'dumpAssArray(newListRemovedSelf)
					
					list.Append(newListRemovedSelf)
					
					'add the new content to the list
					s.ClearContent()
					s.SetContentList(list)
					s.Show()
					s.SetNext(originalIndex, true)

					s.Resume()

					END IF
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
