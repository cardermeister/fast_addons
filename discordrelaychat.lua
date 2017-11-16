local WebhookURL = "https://discordapp.com/api/webhooks/378116447605620736/z8UAE5XXQMAlpLCbvM8gd25jh17Jopg6rVGNkvvfgvlbgc65J5cgJ69U--SRdkg5FCD8"

local SteamWebAPIKey = "C9E4E47AB57681D140D9924A16196EC8"

local function getAvatarFromJson( j_response ) -- Thanks https://facepunch.com/showthread.php?t=1484549&p=48631437&viewfull=1#post48631437
    local t_response = util.JSONToTable( j_response )

    if ( !istable( t_response ) or !t_response.response ) then return false end
    if ( !t_response.response.players or !t_response.response.players[1] ) then return false end
   
    return t_response.response.players[1].avatarfull
end
local function getAvatarURL(p_sender, s_text, b_teamChat)
	
    local t_struct = {
        failed = function( err ) MsgC( Color(255,0,0), "HTTP error: " .. err ) end,
        method = "get",
        url = "https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/",
        parameters = { key = SteamWebAPIKey, steamids = p_sender:SteamID64() },
        success = function(c,body,h)
        	
        	local t_post = {
        		content = s_text,
    			username = (p_sender:Nick() or "Unknown"),
    		    avatar_url = getAvatarFromJson(body)
    		}
    		
    		local t_struct = {
    		    failed = function( err ) MsgC( Color(255,0,0), "HTTP error: " .. err ) end,
    		    method = "post",
    		    url = WebhookURL,
    		    parameters = t_post,
    		    type = "application/json; charset=utf-8" --JSON Request type, because I'm a good boy.
    		}
		
    		HTTP( t_struct )
    			
        	
        end
    }
	
    HTTP( t_struct )

    
end
function sendChat(p_sender, s_text, b_teamChat)
    if !p_sender then return end
    getAvatarURL(p_sender, s_text, b_teamChat)
    	
end
hook.Add("PlayerSay","Discord_Webhook_Chat", sendChat)	