
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
	s.SetTextOverlayHoldTime(5000)   ' 1 second = 1000 milaseconds
	' s.SetTextOverlayIsVisible(true)
	s.SetUnderscan(3) ' gives a padding around the image because TVs cut off the outer part of the image sometimes
	' s.SetDisplayMode("photo-fit") 'I think default is best
	s.SetPeriod(5) ' dont need this
	
	s.SetContentList(list)
    s.Show()
	s.SetNext(start, true)
	
	msg = "declaring"
	loading = false
	row = invalid
	addThesePosts = CreateObject("roArray", 28, true)
	attemptMoreCount = 0
	
	while true
         
		 
		 		if(after <> invalid)
						print "attempting to load more posts attempt = " + attemptMoreCount.tostr()
						attemptMoreCount = attemptMoreCount +1
						subReddit = list[0].subReddit
						newList = loadMorePosts(subReddit, after)
						after = getTheAfter(newList)	
									
						newListRemovedSelf = removeSelfPosts(newList)
						
						'make sure the new subreddits we found contained at least one image
						if(newListRemovedSelf.count() > 1)
							print "adding more posts count= " + newListRemovedSelf.count().tostr()
							list.Append(newListRemovedSelf)
							addThesePosts.Append(newListRemovedSelf)
						END IF
				else
					'print "after is invalid"
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
					print  row.tostr() +"/" + (activeListCount-1).tostr() + " pending to add =" +addThesePosts.count().tostr() 
			

						IF  addThesePosts.count() > 0 THEN
							'add more posts to the slideshow
							FOR EACH post IN addThesePosts
								s.AddContent(post)
								s.show()
							END FOR
							
							activeListCount = activeListCount + addThesePosts.count()
							's.SetNext(activeListCount -2, false)

							print "REFRESHING SLIDESHOW adding new posts =  " + addThesePosts.count().tostr() 
							'after we are done adding new posts clear the list containing new posts
							addThesePosts.Clear()
							
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
					print "save post: " + list[row].Title
					savePost(list[row].id)
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
