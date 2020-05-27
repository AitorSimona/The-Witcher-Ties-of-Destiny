function GetTableTriggerStep9()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.SystemFunctions = Scripting.System()
lua_table.ObjectFunctions = Scripting.GameObject()
lua_table.PhysicsFunctions = Scripting.Physics()

local manager
local managerTable
local geraltUID
local jaskierUID
local MyUUID
local justonce = false

function lua_table:OnTriggerEnter()
    local colliderGO = lua_table.PhysicsFunctions:OnTriggerEnter(MyUUID)

    if justonce == false and colliderGO == geraltUID or colliderGO == jaskierUID
    then    
        managerTable.PauseStep9 = true
        justonce = true
    end
end

function lua_table:Awake()
    MyUUID = lua_table.ObjectFunctions:GetMyUID()
    manager = lua_table.ObjectFunctions:FindGameObject("TutorialManager")
    managerTable = lua_table.ObjectFunctions:GetScript(manager)
    geraltUID = lua_table.ObjectFunctions:FindGameObject("Geralt")
    jaskierUID = lua_table.ObjectFunctions:FindGameObject("Jaskier")
end

function lua_table:Start()
end

function lua_table:Update()
end

return lua_table
end