
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
        RenderImage(url, m.port)   'not sure why we cant always create a roBitmap, but when it fails use roSlideshow
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
    backgroundRegion.SetWrap(false)

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

Sub RenderImage(img, port)
    s = CreateObject("roSlideShow")
    s.SetMessagePort(port)
    s.SetContentList([{ Url: img }])
   's.SetContentList([{ Url: "file://" + img }])
    s.Show()
    while not WaitMessage(port).isScreenClosed(): end while
End Sub

'This is a wait wrapper that ignores invalid message objects (from debugging)
Sub WaitMessage(port) As Object
    while true
        msg = wait(0, port)
        if msg <> invalid return msg
    end while
End Sub