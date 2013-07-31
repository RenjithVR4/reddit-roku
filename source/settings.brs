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