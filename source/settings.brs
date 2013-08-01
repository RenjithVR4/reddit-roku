Function getSetting(name as String) As Dynamic
     sec = CreateObject("roRegistrySection", "Authentication")
     if sec.Exists(name) 
         return sec.Read(name)
     endif
     return invalid
End Function


Function setSetting(name As String, value) As Void
    sec = CreateObject("roRegistrySection", "Authentication")
    sec.Write(name, value)
    sec.Flush()
End Function

Function deleteSetting(name as String) As Dynamic
     sec = CreateObject("roRegistrySection", "Authentication")
     if sec.Exists(name) 
         return sec.Delete(name)
     endif
     return invalid
End Function


Function getSettingsGrid()
	settings = CreateObject("roArray", 28, true)
	o = CreateObject("roAssociativeArray")
	o.Title = "Settings"
	o.SDPosterUrl = "pkg:/images/settings.jpg"
	o.HDPosterUrl = "pkg:/images/settings.jpg"
	settings.Push(o)
	L = CreateObject("roAssociativeArray")
	if(isLoggedIn() = true)
		username = getSetting("username")
		L.Title = username + " - Logout"
		L.SDPosterUrl = "http://www.dudelol.com/thumbs/power-outlet-style.jpg"
		L.HDPosterUrl = "http://www.dudelol.com/thumbs/power-outlet-style.jpg"	
	else		
		L.Title = "Login"
		L.SDPosterUrl = "http://www.dudelol.com/thumbs/power-outlet-style.jpg"
		L.HDPosterUrl = "http://www.dudelol.com/thumbs/power-outlet-style.jpg"			
	END IF
	settings.Push(L)
	return settings
	
END FUNCTION