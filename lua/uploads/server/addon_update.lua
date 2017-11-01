iin.AddCommand( "updatesf", function()
	if not cpp then require "wbcpp1337" end
	
	print( cpp.sf_update( function(msg)
		Msg( "[Starfall Update] " )
		print( msg )
	end ) )
end, "devs", true )


iin.AddCommand( "updatewire", function()
	if not cpp then require "wbcpp1337" end
	
	cpp.wire_update( function(msg)
		Msg( "[Wiremod Update] " )
		print( msg )
	end )
end, "devs", true )