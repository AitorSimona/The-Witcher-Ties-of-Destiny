function GetTableArrowScript()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.GameObjectFunctions = Scripting.GameObject()
lua_table.PhysicsSystem =  Scripting.Physics()
lua_table.Transform = Scripting.Transform()

lua_table.collider_damage = 10
lua_table.force = 30

local start_time = 0

local rotation = {}
local rot_fixed = 0

local MyUID = 0

local DestroyPlayer = false

local Layers = {
    DEFAULT = 0,
    PLAYER = 1,
    PLAYER_ATTACK = 2,
    ENEMY = 3,
    ENEMY_ATTACK = 4
}

local function GimbalLockWorkaroundY(param_rot_y)

    if math.abs(lua_table.Transform:GetRotation(MyUID)[1]) == 180
    then
        if param_rot_y >= 0 then param_rot_y = 90 + 90 - param_rot_y
        elseif param_rot_y < 0 then param_rot_y = -90 + -90 - param_rot_y
        end
    end

    return param_rot_y
end

function lua_table:OnTriggerEnter()
    local collider_GO = lua_table.PhysicsSystem:OnTriggerEnter(MyUID)
    
    
end

function lua_table:OnCollisionEnter()
    local collider_GO = lua_table.PhysicsSystem:OnCollisionEnter(MyUID)
    local layer = lua_table.GameObjectFunctions:GetLayerByID(collider_GO)

    if layer == Layers.PLAYER
    then
		DestroyPlayer = true
        --lua_table.GameObjectFunctions:DestroyGameObject(MyUID)
    end
    
end

--------------------------------------------------------------------------------------------------

function lua_table:Awake()
    lua_table.System:LOG ("This Log was called from ArrowScript on AWAKE")
end

function lua_table:Start()

    MyUID = lua_table.GameObjectFunctions:GetMyUID()

    start_time = lua_table.System:GameTime()*1000

    rotation = lua_table.Transform:GetRotation(MyUID)
    rot_fixed = GimbalLockWorkaroundY(rotation[2])

    local X = math.sin(math.rad(rot_fixed))
    local Z = math.cos(math.rad(rot_fixed))
    lua_table.PhysicsSystem:AddForce(X*lua_table.force , 0, Z*lua_table.force, 0, MyUID)

    
end

function lua_table:Update()
    
    if start_time + 5000 <= lua_table.System:GameTime()*1000 
    then  
        lua_table.GameObjectFunctions:DestroyGameObject(MyUID)
    end
	
	if DestroyPlayer 
	then 
		lua_table.GameObjectFunctions:DestroyGameObject(MyUID)
	end
end

return lua_table
end