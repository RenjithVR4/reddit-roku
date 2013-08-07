function showComments(post)		    port = CreateObject("roMessagePort")    dialog = showLoadingScreen( post.Title, port)	seperator = "------------------------------------------------------------------------------------------------"	screen = CreateObject("roTextScreen")    screen.SetMessagePort(port)    'screen.SetTitle(post.Description)	screen.SetText(post.Title  )	screen.AddText(seperator)	if(post.selftext <> invalid AND post.selftext <> "")		screen.AddText(post.selftext)	 END IF	 	 screen.AddButton(1,"back")	 	 screen.SetBreadcrumbText("Up: " + post.ups , "Down: " + post.downs)  'contains the up and downvotes	 if(len(post.Title) > 46)		 screen.SetHeaderText(left(post.Title,46) + "...")  ' truncate this to 48 characters	 else	 screen.SetHeaderText(post.Title)  ' truncate this to 48 characters	 end if	 'screen.SetHeaderText("Comments")     	 	http = NewHttp2("http://www.reddit.com/comments/"+post.id+".json?depth=4", "application/json")	response= http.GetToStringWithTimeout(90)	json = ParseJSON(response)		if(json = invalid)		dialog.Close()		return invalid	END IF		comments = json[1]			for each comment in comments.data.children			printComments(screen, comment,invalid, 0)			screen.AddText(seperator)	end for	screen.Show()	dialog.Close()       while true         msg = wait(0, screen.GetMessagePort())          if type(msg) = "roTextScreenEvent"             if msg.isScreenClosed()                 return -1             else if msg.isButtonPressed() then                 print "Evt:"; msg.GetMessage ();" idx:"; msg.GetIndex()                 if msg.GetIndex() = 1                     return -1                 endif             endif         endif     end while END FUNCTIONFUNCTION printComments(screen, comment,parentAuthor, depth)	if(comment.data.body <> invalid)		body=  comment.data.body		author = comment.data.author		beforeText = "->"				if(depth > 0 )			beforeText = String(depth, "--" ) + ">" 			screen.AddText(beforeText+ author + " in reply to " + parentAuthor + "'s comment: ")			screen.AddText( body)		else			screen.AddText(" ") ' only add an extra line break when its a new comment thread			screen.AddText(author + " said: ")			screen.AddText( body)		END IF												replies = comment.data.replies		if(type(replies) <> "String")		for each reply in replies.data.children			if(reply.kind= "t1")				printComments(screen, reply, author,depth+1)			end if	    end for		END IF							END IFEND FUNCTION