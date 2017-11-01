if SERVER then

	function Say(ret)
	me:ConCommand('say '..tostring(ret))
	end
	
else

	function Say(ret)
	LocalPlayer():ConCommand('say '..tostring(ret))
	end

end