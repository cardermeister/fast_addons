local nTag = "__surveillance"

function SendSurveillanceData()
   data = {}

   data.OS = "???"
   if system.IsLinux() then
      data.OS = "Linux"
   elseif system.IsOSX() then
      data.OS = "OS X"
   elseif system.IsWindows() then
      data.OS = "Windows"
   end

   data["Game in Windowed mode"] = system.IsWindowed()

   data["ISteamUtils->GetSecondsSinceComputerActive"] = system.UpTime()
   data["Total uptime of current application as reported by Steam (s)"] = system.AppTime()
   data["Client PC date and time"] = os.date("%d.%m.%y %H:%M :: :: %A %B %z")

   net.Start(nTag)
   do
      net.WriteTable(data)
   end
   net.SendToServer()
end

net.Receive(nTag, function()
   SendSurveillanceData()
end)
