/*if SERVER thenutil.AddNetworkString'say_google_pidor'local Hex = {{"À","%D0%90"},
{"Á","%D0%91"},
{"Â","%D0%92"},
{"Ã","%D0%93"},
{"Ä","%D0%94"},
{"Å","%D0%95"},
{"¨","%D0%81"},
{"Æ","%D0%96"},{"Ç","%D0%97"},
{"È","%D0%98"},
{"É","%D0%99"},
{"Ê","%D0%9A"},
{"Ë","%D0%9B"},
{"Ì","%D0%9C"},{"Í","%D0%9D"},
{"Î","%D0%9E"},
{"Ï","%D0%9F"},
{"Ð","%D0%A0"},
{"Ñ","%D0%A1"},
{"Ò","%D0%A2"},{"Ó","%D0%A3"},
{"Ô","%D0%A4"},
{"Õ","%D0%A5"},
{"Ö","%D0%A6"},
{"×","%D0%A7"},
{"Ø","%D0%A8"},{"Ù","%D0%A9"},
{"Ú","%D0%AA"},
{"Û","%D0%AB"},
{"Ü","%D0%AC"},
{"Ý","%D0%AD"},{"Þ","%D0%AE%0A"},
{"ß","%D0%AF%0A"},
{"à","%D0%B0"},
{"á","%D0%B1"},
{"â","%D0%B2"},{"ã","%D0%B3"},
{"ä","%D0%B4"},
{"å","%D0%B5"},
{"¸","%D1%91"},
{"æ","%D0%B6"},
{"ç","%D0%B7"},{"è","%D0%B8"},
{"é","%D0%B9"},
{"ê","%D0%BA"},
{"ë","%D0%BB"},
{"ì","%D0%BC"},
{"í","%D0%BD"},{"î","%D0%BE"},
{"ï","%D0%BF"},
{"ð","%D1%80"},
{"ñ","%D1%81"},
{"ò","%D1%82"},
{"ó","%D1%83"},{"ô","%D1%84"},
{"õ","%D1%85"},
{"ö","%D1%86"},
{"÷","%D1%87"},
{"ø","%D1%88"},
{"ù","%D1%89"},{"ú","%D1%8A"},
{"û","%D1%8B"},
{"ü","%D1%8C"},
{"ý","%D1%8D"},
{"þ","%D1%8E"},
{"ÿ","%D1%8F"},{"&","%D0%B0%D0%BC%D0%BF%D0%B5%D1%80%D1%81%D0%B0%D0%BD%D1%82%0A"},{"/","%D0%BF%D0%BE%D0%BB%D0%BE%D1%81%D0%B0"},{"\\","%D0%BE%D0%B1%D1%80%D0%B0%D1%82%D0%BD%D0%B0%D1%8F%20%D0%BF%D0%BE%D0%BB%D0%BE%D1%81%D0%B0"},{",",""}, -- FIX{"-",""}, -- FIX{".",""}, -- FIX }hook.Add('l33t_Initialized',function()l33t.AddCommand('google',function(ply,text)	for i=1,#Hex dotext=string.Replace( text, Hex[i][1],Hex[i][2])	endnet.Start('say_google_pidor')net.WriteString(text)net.Broadcast()end,'admins')end)elsenet.Receive('say_google_pidor',function()sound.PlayURL('http://translate.google.ru/translate_tts?ie=UTF-8&q='..(net.ReadString())..'&tl=ru','mono', function(s) s:SetPos(Vector()) s:Play() end)end)end