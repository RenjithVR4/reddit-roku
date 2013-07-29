
Function IsHD()
    di = CreateObject("roDeviceInfo")
    if di.GetDisplayType() = "HDTV" then return true
    return false
End Function

Function showImg(url) 

	'this needs to be declared somehow
	screen = "null"
	
    if IsHD()
        screen=CreateObject("roScreen", true, 854, 480)  'try this to see zoom
    else
        screen=CreateObject("roScreen", true)
    endif

    ' http = NewHttp2("http://rokudev.roku.com/rokudev/examples/scroll/VeryBigPng.png", "text/xml")
	' http = NewHttp("http://cutecaptions.com/img/waste-of-money.png")
	 http = NewHttp(url)
	' http = NewHttp("http://i.imgur.com/H7dF5MM.jpg")
    http.GetToFileWithTimeout("tmp:/viewPost.png", 5020)
    bigbm=CreateObject("roBitmap", "tmp:/viewPost.png")
		  
    if bigbm = invalid
        print "bigbm create failed"
        stop
    endif
	
	ScreenWidth = screen.getwidth()
	ScreenHeight = screen.getheight()
	
	if (bigbm.GetWidth() < screen.getwidth())
		ScreenWidth = bigbm.GetWidth()
	endif
	if (bigbm.GetHeight() < screen.getwidth())
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

    screen.drawobject(0, 0, backgroundRegion)
    screen.SwapBuffers()
    
    msgport = CreateObject("roMessagePort")
    screen.SetPort(msgport)
    
    movedelta = 16
    if (screen.getwidth() <= 720)
        movedelta = 8
    endif

    codes = bslUniversalControlEventCodes()

    pressedState = -1 ' If > 0, is the button currently in pressed state
    while true
	if pressedState = -1 then
	    msg=wait(0, msgport)   ' wait for a button press
	else
	    msg=wait(1, msgport)   ' wait for a button release or move in current pressedState direction 
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
        
end function

function Zip(screen, region, xd, yd)
    region.Offset(xd,yd,0,0)
    screen.drawobject(0, 0, region)
    screen.SwapBuffers()
end function
