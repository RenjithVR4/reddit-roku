
Function IsHD()
    di = CreateObject("roDeviceInfo")
    if di.GetDisplayType() = "HDTV" then return true
    return false
End Function

Function showImg(url) 

	'this needs to be declared somehow
	screen = "null"
	
    if IsHD()
        ' screen=CreateObject("roScreen", true, 854, 480)  'try this to see zoom
		screen=CreateObject("roScreen", true)
    else
        screen=CreateObject("roScreen", true)
    endif
	
	m.port = CreateObject("roMessagePort")
    

    ' http = NewHttp2("http://rokudev.roku.com/rokudev/examples/scroll/VeryBigPng.png", "text/xml")
	 http = NewHttp(url)
	' http = NewHttp2(url, "text/xml")
    http.GetToFileWithTimeout("tmp:/viewPost.png", 120)
    bigbm=CreateObject("roBitmap", "tmp:/viewPost.png")
		  
    if bigbm = invalid
        print "bigbm create failed"
        showSlideShow(url, m.port)   'not sure why we cant always create a roBitmap, but when it fails use roSlideshow
    else
	
	ScreenWidth = screen.getwidth()
	ScreenHeight = screen.getheight()
	
	if (bigbm.GetWidth() < screen.getwidth())
		ScreenWidth = bigbm.GetWidth()
	endif
	if (bigbm.GetHeight() < screen.getheight())
		ScreenHeight = bigbm.GetHeight()
	endif
	
    ' backgroundRegion=CreateObject("roRegion", bigbm, 0, 0, screen.getwidth(), screen.getheight())
	' backgroundRegion=CreateObject("roRegion", bigbm, 0, 0, bigbm.GetWidth(), bigbm.GetHeight())
	 backgroundRegion=CreateObject("roRegion", bigbm, 0, 0, ScreenWidth, ScreenHeight)
	 
	
    if backgroundRegion = invalid
        print "create region failed"
        stop
    endif
    backgroundRegion.SetWrap(true)

	screen.SetPort(m.port)
    screen.drawobject(0, 0, backgroundRegion)
    screen.SwapBuffers()
    

    
    movedelta = 16
    if (screen.getwidth() <= 720)
        movedelta = 8
    endif

    codes = bslUniversalControlEventCodes()

    pressedState = -1 ' If > 0, is the button currently in pressed state
    while true
	if pressedState = -1 then
	    msg=wait(0, m.port)   ' wait for a button press
	else
	    msg=wait(1, m.port)   ' wait for a button release or move in current pressedState direction 
	endif
        if type(msg)="roUniversalControlEvent" then
                keypressed = msg.GetInt()
                print "keypressed=";keypressed
                if keypressed=codes.BUTTON_UP_PRESSED then 
                        Zip(screen, backgroundRegion, 0,-movedelta)  'up
			pressedState = codes.BUTTON_UP_PRESSED 
                else if keypressed=codes.BUTTON_DOWN_PRESSED then 
                        Zip(screen, backgroundRegion, 0,+movedelta)  ' down
			pressedState = codes.BUTTON_DOWN_PRESSED 
                else if keypressed=codes.BUTTON_RIGHT_PRESSED then 
                        Zip(screen, backgroundRegion, +movedelta,0)  ' right
			pressedState = codes.BUTTON_RIGHT_PRESSED 
                else if keypressed=codes.BUTTON_LEFT_PRESSED then 
                        Zip(screen, backgroundRegion, -movedelta, 0)  ' left
			pressedState = codes.BUTTON_LEFT_PRESSED 
                else if keypressed=codes.BUTTON_BACK_PRESSED then
		        pressedState = -1
		        exit while
                else if keypressed=codes.BUTTON_UP_RELEASED or keypressed=codes.BUTTON_DOWN_RELEASED or keypressed=codes.BUTTON_RIGHT_RELEASED or keypressed=codes.BUTTON_LEFT_RELEASED then 
		       pressedState = -1
                end if
	else if msg = invalid then
                print "eventLoop timeout pressedState = "; pressedState
                if pressedState=codes.BUTTON_UP_PRESSED then 
                        Zip(screen, backgroundRegion, 0,-movedelta)  'up
                else if pressedState=codes.BUTTON_DOWN_PRESSED then 
                        Zip(screen, backgroundRegion, 0,+movedelta)  ' down
                else if pressedState=codes.BUTTON_RIGHT_PRESSED then 
                        Zip(screen, backgroundRegion, +movedelta,0)  ' right
                else if pressedState=codes.BUTTON_LEFT_PRESSED then 
                        Zip(screen, backgroundRegion, -movedelta, 0)  ' left
		end if
        end if
    end while
	endif
        
end function

function Zip(screen, region, xd, yd)
    region.Offset(xd,yd,0,0)
    screen.drawobject(0, 0, region)
    screen.SwapBuffers()
end function

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
	s.SetTextOverlayHoldTime(9000)
	' s.SetTextOverlayIsVisible(true)
	s.SetUnderscan(3) ' gives a padding around the image because TVs cut off the outer part of the image sometimes
	' s.SetDisplayMode("photo-fit") 'I think default is best
	s.SetPeriod(9) ' dont need this
	
	s.SetContentList(list)
    s.Show()
	s.SetNext(start, true)
	
	msg = "declaring"
	loading = false
	
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
			    IF msg.GetIndex() = (list.count() -1) THEN
					'load more reddit posts
					originalIndex = list.count() -1
					print "attempting to get the after"
					after = list[list.count() -1].After
					print after
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

