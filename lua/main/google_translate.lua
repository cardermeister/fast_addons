/*if SERVER thenutil.AddNetworkString'say_google_pidor'local Hex = {{"�","%D0%90"},
{"�","%D0%91"},
{"�","%D0%92"},
{"�","%D0%93"},
{"�","%D0%94"},
{"�","%D0%95"},
{"�","%D0%81"},
{"�","%D0%96"},{"�","%D0%97"},
{"�","%D0%98"},
{"�","%D0%99"},
{"�","%D0%9A"},
{"�","%D0%9B"},
{"�","%D0%9C"},{"�","%D0%9D"},
{"�","%D0%9E"},
{"�","%D0%9F"},
{"�","%D0%A0"},
{"�","%D0%A1"},
{"�","%D0%A2"},{"�","%D0%A3"},
{"�","%D0%A4"},
{"�","%D0%A5"},
{"�","%D0%A6"},
{"�","%D0%A7"},
{"�","%D0%A8"},{"�","%D0%A9"},
{"�","%D0%AA"},
{"�","%D0%AB"},
{"�","%D0%AC"},
{"�","%D0%AD"},{"�","%D0%AE%0A"},
{"�","%D0%AF%0A"},
{"�","%D0%B0"},
{"�","%D0%B1"},
{"�","%D0%B2"},{"�","%D0%B3"},
{"�","%D0%B4"},
{"�","%D0%B5"},
{"�","%D1%91"},
{"�","%D0%B6"},
{"�","%D0%B7"},{"�","%D0%B8"},
{"�","%D0%B9"},
{"�","%D0%BA"},
{"�","%D0%BB"},
{"�","%D0%BC"},
{"�","%D0%BD"},{"�","%D0%BE"},
{"�","%D0%BF"},
{"�","%D1%80"},
{"�","%D1%81"},
{"�","%D1%82"},
{"�","%D1%83"},{"�","%D1%84"},
{"�","%D1%85"},
{"�","%D1%86"},
{"�","%D1%87"},
{"�","%D1%88"},
{"�","%D1%89"},{"�","%D1%8A"},
{"�","%D1%8B"},
{"�","%D1%8C"},
{"�","%D1%8D"},
{"�","%D1%8E"},
{"�","%D1%8F"},{"&","%D0%B0%D0%BC%D0%BF%D0%B5%D1%80%D1%81%D0%B0%D0%BD%D1%82%0A"},{"/","%D0%BF%D0%BE%D0%BB%D0%BE%D1%81%D0%B0"},{"\\","%D0%BE%D0%B1%D1%80%D0%B0%D1%82%D0%BD%D0%B0%D1%8F%20%D0%BF%D0%BE%D0%BB%D0%BE%D1%81%D0%B0"},{",",""}, -- FIX{"-",""}, -- FIX{".",""}, -- FIX }hook.Add('l33t_Initialized',function()l33t.AddCommand('google',function(ply,text)	for i=1,#Hex dotext=string.Replace( text, Hex[i][1],Hex[i][2])	endnet.Start('say_google_pidor')net.WriteString(text)net.Broadcast()end,'admins')end)elsenet.Receive('say_google_pidor',function()sound.PlayURL('http://translate.google.ru/translate_tts?ie=UTF-8&q='..(net.ReadString())..'&tl=ru','mono', function(s) s:SetPos(Vector()) s:Play() end)end)end