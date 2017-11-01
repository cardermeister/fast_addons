/* made by CornerPin[Smooze] */

function hook.GetUserHooks()
    local UserHooks = {}
   
    for HookType, Hooks in pairs( hook.GetTable() ) do
        for HookName, HookFunction in pairs( Hooks ) do
            local src = debug.getinfo( HookFunction, "S" ).short_src
           
            if src and src ~= "[C]" and string.Right( src, 4 ) ~= ".lua" then
                if not UserHooks[ HookType ] then
                    UserHooks[ HookType ] = {}
                end
               
                UserHooks[ HookType ][ HookName ] = src
            end
        end
    end
   
    return UserHooks
end
 
function hook.RemoveUserHooks( env )
    local UserHooks = hook.GetUserHooks()
   
    for HookType, Hooks in pairs( UserHooks ) do
        for HookName, HookEnv in pairs( Hooks ) do
            if env == nil or env == HookEnv then
                hook.Remove( HookType, HookName )
            end
        end
    end
end