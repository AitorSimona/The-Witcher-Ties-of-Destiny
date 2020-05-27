function GetTableGeraltCutscene()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.GameObjectFunctions = Scripting.GameObject()
lua_table.AnimationFunctions = Scripting.Animations()

-- Camera target GO names
lua_table.speed = 30.0
local Geralt_UID = 0
local started_time = 0
local play_animation = true
lua_table.current_state = 0

function lua_table:Awake()
    lua_table.System:LOG ("This Log was called from GeraltCutscene on AWAKE")
end

function lua_table:Start()
    Geralt_UID = lua_table.GameObjectFunctions:GetMyUID()

    started_time = lua_table.System:GameTime()
end

function lua_table:Update()
    time = lua_table.System:GameTime() - started_time

    if time >= 46 and play_animation == true 
    then
        lua_table.AnimationFunctions:PlayAnimation("Cutscene", lua_table.speed, Geralt_UID)
        play_animation = false
    end

end

return lua_table
end