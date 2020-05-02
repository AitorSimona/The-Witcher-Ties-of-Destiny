function GetTableMinionGhoul_Scriptv02()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.GameObject = Scripting.GameObject()
lua_table.Transform = Scripting.Transform()
lua_table.Physics =  Scripting.Physics()
lua_table.Animations = Scripting.Animations()
lua_table.Recast = Scripting.Navigation()
-- DEBUG PURPOSES
--lua_table.Input = Scripting.Inputs()

-----------------------------------------------------------------------------------------
-- Inspector Variables
-----------------------------------------------------------------------------------------

-- Possible targets
lua_table.geralt = 0 
lua_table.jaskier = 0
lua_table.currentTarget = 0
lua_table.currentTargetDir = 0
lua_table.currentTargetPos = 0

lua_table.GeraltDistance = 0
lua_table.JaskierDistance = 0

local State = {
	IDLE = 0,
	SEEK = 1,
	ATTACK = 2,
	KNOCKBACK = 3,
	STUNNED = 4,
	DEATH = 5
}

local layers = {
	default = 0,
	player = 1,
	player_attack = 2,
	enemy = 3,
	enemy_attack = 4
}

local attack_effects = {
	none = 0, 
	stun = 1,
	knockback = 2,
	taunt = 3,
	venom = 4
}

------------   All the values below are placeholders, will change them when testing
-- Ghoul values 
lua_table.MyUID = 0 --Entity UID
lua_table.max_hp = 50
lua_table.health = 0
lua_table.speed = 0.05
lua_table.knock_speed = 0.5
lua_table.currentState = 0
lua_table.is_stunned = false
lua_table.is_taunt = false
lua_table.is_knockback = false
lua_table.is_dead = false
	
-- Aggro values 
lua_table.AggroRange = 100
lua_table.minDistance = 2.5 -- If entity is inside this distance, then attack
lua_table.maxDistance = 5
--
lua_table.stun_duration = 4000

local knock_force = {0, 0, 0}

local Stun_DMG = 7

-- Time management
local start_attack = false
local attack_timer = 0

local start_knockback = false
local knockback_timer = 0

local start_taunt = false
local taunt_timer = 0

local start_stun = false
local stun_timer = 0

local start_death = false
local death_timer = 0

-- Flow control conditionals
local attacked = false

-- Recast navigation
local navID = 0
local corners = {}
local currCorner = 2

-- Entity colliders
local is_front_active = false
local is_area_active = false

lua_table.Minion_Front = "Minion_Front_Attack"
local Front_Collider = 0
lua_table.collider_damage = 0
lua_table.collider_effect = 0

local random_attack = 0

-- ______________________SCRIPT FUNCTIONS______________________

local function ResetNavigation()
	currCorner = 2
end

local function ResetAttack()
	-- Attack Timer
	if start_attack == true then start_attack = false end
	if attack_timer > 0 then attack_timer = 0 end
	-- Attack control bools
	if attacked == true then attacked = false end
end

local function ResetStun()
	if start_stun == true then start_stun = false end
	if stun_timer > 0 then stun_timer = 0 end
end

local function ResetKnockBack()
	if start_knockback == true then start_knockback = false end
	if knockback_timer > 0 then knockback_timer = 0 end
end

local function SearchPlayers() -- Check if targets are within range

	lua_table.GeraltPos = lua_table.Transform:GetPosition(lua_table.geralt)
	lua_table.JaskierPos = lua_table.Transform:GetPosition(lua_table.jaskier)
	lua_table.GhoulPos = lua_table.Transform:GetPosition(lua_table.MyUID)
	
	local GC1 = lua_table.GeraltPos[1] - lua_table.GhoulPos[1]
	local GC2 = lua_table.GeraltPos[3] - lua_table.GhoulPos[3]
	lua_table.GeraltDistance = math.sqrt(GC1 ^ 2 + GC2 ^ 2)

	local JC1 = lua_table.JaskierPos[1] - lua_table.GhoulPos[1]
	local JC2 = lua_table.JaskierPos[3] - lua_table.GhoulPos[3]
	lua_table.JaskierDistance =  math.sqrt(JC1 ^ 2 + JC2 ^ 2)
	
	if lua_table.is_taunt then 
		lua_table.currentTarget = lua_table.jaskier
		lua_table.currentTargetDir = lua_table.JaskierDistance
		lua_table.currentTargetPos = lua_table.JaskierPos
	else 
		lua_table.currentTarget = lua_table.geralt
		lua_table.currentTargetDir = lua_table.GeraltDistance
		lua_table.currentTargetPos = lua_table.GeraltPos
	end
					
	if lua_table.JaskierDistance < lua_table.GeraltDistance then
		lua_table.currentTarget = lua_table.jaskier
		lua_table.currentTargetDir = lua_table.JaskierDistance
		lua_table.currentTargetPos = lua_table.JaskierPos
		
	elseif lua_table.JaskierDistance == lua_table.GeraltDistance then 
		lua_table.currentTarget = lua_table.geralt
		lua_table.currentTargetDir = lua_table.GeraltDistance
		lua_table.currentTargetPos = lua_table.GeraltPos
	end 
end

-- local function ToggleCollider(ID, start, finish, timer, condition, dmg, effect)

-- 	lua_table.collider_effect = effect
-- 	lua_table.collider_damage = dmg
		
-- 	condition = true

-- 	if timer + start < lua_table.System:GameTime() * 1000 and condition then
-- 		lua_table.GameObject:SetActiveGameObject(true, ID)
-- 	end
-- 	if timer + finish < lua_table.System:GameTime() * 1000 then
-- 		lua_table.GameObject:SetActiveGameObject(false, ID)
-- 		condition = false
-- 	end
-- end

local function AttackColliderShutdown()
	if is_front_active then
		lua_table.GameObjectFunctions:SetActiveGameObject(false, Front_Att_Coll)	--TODO-Colliders: Check
		is_front_active = false
	end
end
	
local function Idle() 
		
	if lua_table.currentTargetDir <= lua_table.AggroRange then
		lua_table.currentState = State.SEEK
		lua_table.Animations:PlayAnimation("Run", 30.0, lua_table.MyUID)
		lua_table.System:LOG("Minion state: SEEK (1)") 
	end
	
end
	
local function Seek()
	
	-- Now we get the direction vector and then we normalize it and aply a velocity in every component
	
	if lua_table.currentTargetDir < lua_table.AggroRange and lua_table.currentTargetDir > lua_table.minDistance then
			
		corners = lua_table.Recast:CalculatePath(lua_table.GhoulPos[1], lua_table.GhoulPos[2], lua_table.GhoulPos[3], lua_table.currentTargetPos[1], lua_table.currentTargetPos[2], lua_table.currentTargetPos[3], 1 << navID)

		local nextCorner = {}
		nextCorner[1] = corners[currCorner][1] - lua_table.GhoulPos[1]
		nextCorner[2] = corners[currCorner][2] - lua_table.GhoulPos[2]
		nextCorner[3] = corners[currCorner][3] - lua_table.GhoulPos[3]

		local dis = math.sqrt(nextCorner[1] ^ 2 + nextCorner[3] ^ 2)
		
		if dis > 0.05 then 

			local vec = { 0, 0, 0 }
			vec[1] = nextCorner[1] / dis
			vec[2] = nextCorner[2]
			vec[3] = nextCorner[3] / dis
				
			-- Apply movement vector to move character
			lua_table.Transform:LookAt(corners[currCorner][1], lua_table.GhoulPos[2], corners[currCorner][3], lua_table.MyUID)
			lua_table.Physics:Move(vec[1] * lua_table.speed, vec[3] * lua_table.speed, lua_table.MyUID)
			
			else
				currCorner = currCorner + 1
		end
		
	else 
		lua_table.currentState = State.IDLE	
			
	end
	
	if lua_table.currentTargetDir <= lua_table.minDistance then
		lua_table.currentState = State.ATTACK
		lua_table.System:LOG("Minion state: ATTACK (2)")
	end
end
	
local function Attack()

	if lua_table.currentTargetDir >= lua_table.maxDistance then
		lua_table.currentState = State.SEEK	
		lua_table.System:LOG("Minion state: SEEK (1), target out of range")    
		lua_table.Animations:PlayAnimation("Run", 30.0, lua_table.MyUID)

		return
	end

	if not start_attack then 
		attack_timer = lua_table.System:GameTime() * 1000
		start_attack = true
	end

	lua_table.Transform:LookAt(lua_table.currentTargetPos[1], lua_table.GhoulPos[2], lua_table.currentTargetPos[3], lua_table.MyUID)

	if attack_timer <= lua_table.System:GameTime() * 1000 and not attacked then

		random_attack = math.random(1, 3)

		if random_attack == 1 then 
			lua_table.System:LOG("Attack1 chosen")
			lua_table.Animations:PlayAnimation("Attack_1", 30.0, lua_table.MyUID)
        elseif random_attack == 2 then 
			lua_table.System:LOG("Attack2 chosen")
			lua_table.Animations:PlayAnimation("Attack_2", 45.0, lua_table.MyUID)
		elseif random_attack == 3 then 
			lua_table.System:LOG("Attack3 chosen")
			lua_table.Animations:PlayAnimation("Attack_3", 30.0, lua_table.MyUID)
		end
		
		attacked = true
	end
	
	if attack_timer + 1000 <= lua_table.System:GameTime() * 1000 and attack_timer + 1100 >= lua_table.System:GameTime() * 1000 then
		lua_table.collider_effect = attack_effects.none
		lua_table.collider_damage = 2
		
		is_front_active = true
		lua_table.GameObject:SetActiveGameObject(true, Front_Collider)
	end

	if attack_timer + 1100 <= lua_table.System:GameTime() * 1000 then 
		is_front_active = false
		lua_table.GameObject:SetActiveGameObject(false, Front_Collider)
	end
	
	-- After he finished, switch state
	if attack_timer + 1500 <= lua_table.System:GameTime() * 1000 then
		lua_table.currentState = State.SEEK	
		lua_table.Animations:PlayAnimation("Run", 30.0, lua_table.MyUID)
		lua_table.System:LOG("Minion state: SEEK (1), cycle to seek")
	end
	
end

local function Stun()
	if start_stun then

		stun_timer = lua_table.System:GameTime() * 1000
		start_stun = false
	end

	if stun_timer + lua_table.stun_duration <= lua_table.System:GameTime() * 1000 then
		lua_table.Animations:PlayAnimation("Run", 30.0, lua_table.MyUID)
	
		lua_table.currentState = State.SEEK	
		lua_table.System:LOG("Minion state: SEEK (1), from stun")
	end
	
end

local function KnockBack()
	if start_knockback then 
		knockback_timer = lua_table.System:GameTime() * 1000
		start_knockback = false
	end

	if knockback_timer <= lua_table.System:GameTime() * 1000 then
		lua_table.currentState = State.STUNNED	
		lua_table.is_knockback = false
		lua_table.System:LOG("Minion state: STUNNED (5), from KD")
		
	else 
		lua_table.Physics:Move(knock_force[1] * lua_table.knock_speed, knock_force[3] * lua_table.knock_speed, lua_table.MyUID)

	end
	
end

local function Die()
	if not start_death then 
		death_timer = lua_table.System:GameTime() * 1000
		lua_table.System:LOG("Im dying")  
		lua_table.Animations:PlayAnimation("Death", 30.0, lua_table.MyUID)
		start_death = true
	end

	if death_timer + 7000 <= lua_table.System:GameTime() * 1000 then
		lua_table.System:LOG("Im dead!!!!!!!!!")  
		lua_table.GameObject:DestroyGameObject(lua_table.MyUID) -- Delete GO from scene
	end
	
end

-- ______________________COLLISIONS______________________
function lua_table:OnTriggerEnter()	
	local collider = lua_table.Physics:OnTriggerEnter(lua_table.MyUID)
    local layer = lua_table.GameObject:GetLayerByID(collider)

    if layer == layers.player_attack then 
		local parent = lua_table.GameObject:GetGameObjectParent(collider)
		local script = lua_table.GameObject:GetScript(parent)
		
		if lua_table.currentState ~= State.DEATH then

			lua_table.health = lua_table.health - script.collider_damage
	
			if script.collider_effect ~= attack_effects.none then
				
				if script.collider_effect == attack_effects.stun then ----------------------------------------------------- React to stun effect
					AttackColliderShutdown()
					lua_table.Animations:PlayAnimation("Hit", 30.0, lua_table.MyUID)
					start_stun = true
					lua_table.currentState = State.STUNNED
							
					lua_table.System:LOG("Minion state: STUNNED (5)")  
				end
		
				if script.collider_effect == attack_effects.knockback then ------------------------------------------------ React to kb effect
					AttackColliderShutdown()

					local tmp = lua_table.Transform:GetPosition(collider)

					local knock_vector = {0, 0, 0}
					knock_vector[1] = lua_table.GhoulPos[1] - tmp[1]
					knock_vector[2] = lua_table.GhoulPos[2] - tmp[2]
					knock_vector[3] = lua_table.GhoulPos[3] - tmp[3]

					local module = math.sqrt(knock_vector[1] ^ 2 + knock_vector[3] ^ 2)

					knock_force[1] = knock_vector[1] / module
					knock_force[2] = knock_vector[2]
					knock_force[3] = knock_vector[3] / module

					lua_table.Animations:PlayAnimation("Hit", 30.0, lua_table.MyUID)

					lua_table.currentState = State.KNOCKBACK
					start_knockback = true
					lua_table.is_knockback = true
					lua_table.System:LOG("Minion state: KNOCKBACK (4)") 
					
				end
		
				if script.collider_effect == attack_effects.taunt then ---------------------------------------------------- React to taunt effect
					AttackColliderShutdown()

					start_taunt = true

					if start_taunt then 
						taunt_timer = lua_table.System:GameTime() * 1000
						lua_table.is_taunt = true
						lua_table.System:LOG("Getting taunted by Jaskier") 
						start_taunt = false
					end
				
				end
	
			else
				AttackColliderShutdown()
				lua_table.Animations:PlayAnimation("Hit", 30.0, lua_table.MyUID)
				lua_table.System:LOG("Hit registered")
			end
		end
    end
end

function lua_table:OnCollisionEnter()
	local collider = lua_table.Physics:OnCollisionEnter(lua_table.MyUID)
	
end

function lua_table:RequestedTrigger(collider_GO)
	lua_table.System:LOG("RequestedTrigger activated")

	local script = lua_table.GameObject:GetScript(collider_GO)
	
	if lua_table.currentState ~= State.DEATH then

		lua_table.health = lua_table.health - script.collider_damage

		if script.collider_effect ~= attack_effects.none then
			
			if script.collider_effect == attack_effects.stun then ----------------------------------------------------- React to stun effect
				AttackColliderShutdown()
				lua_table.Animations:PlayAnimation("Hit", 30.0, lua_table.MyUID)
				start_stun = true
				lua_table.currentState = State.STUNNED
				
				lua_table.System:LOG("Minion state: STUNNED (5)")  
			end
			
			if script.collider_effect == attack_effects.knockback then ------------------------------------------------ React to kb effect
				AttackColliderShutdown()

				local coll_pos = lua_table.Transform:GetPosition(collider_GO)
				local knock_vector = {0, 0, 0}
				knock_vector[1] = lua_table.GhoulPos[1] - coll_pos[1]
				knock_vector[2] = lua_table.GhoulPos[2] - coll_pos[2]
				knock_vector[3] = lua_table.GhoulPos[3] - coll_pos[3]

 				local module = math.sqrt(knock_vector[1] ^ 2 + knock_vector[3] ^ 2)

				knock_force[1] = knock_vector[1] / module
				knock_force[2] = knock_vector[2]
				knock_force[3] = knock_vector[3] / module

				lua_table.Animations:PlayAnimation("Hit", 30.0, lua_table.MyUID)

				lua_table.currentState = State.KNOCKBACK
				start_knockback = true
				lua_table.is_knockback = true
				lua_table.System:LOG("Minion state: KNOCKBACK (4)") 

			end
	
			if script.collider_effect == attack_effects.taunt then ---------------------------------------------------- React to taunt effect
				AttackColliderShutdown()

				start_taunt = true

				if start_taunt then 
					taunt_timer = lua_table.System:GameTime() * 1000
					lua_table.is_taunt = true
					lua_table.System:LOG("Getting taunted by Jaskier") 
					start_taunt = false
				end
				
			end

		else
			AttackColliderShutdown()
			lua_table.Animations:PlayAnimation("Hit", 30.0, lua_table.MyUID)
			lua_table.System:LOG("Hit registered")
		end
	end
end

-- ______________________MAIN CODE______________________
function lua_table:Awake()
	lua_table.System:LOG("Minion AWAKE")
end

function lua_table:Start()
	lua_table.System:LOG("Minion START")

	-- Getting Entity and Player UIDs
	lua_table.MyUID = lua_table.GameObject:GetMyUID()
	lua_table.geralt = lua_table.GameObject:FindGameObject("Geralt")
	lua_table.jaskier = lua_table.GameObject:FindGameObject("Jaskier")

	-- Check if both players are in the scene
	if lua_table.geralt == 0 then 
		lua_table.System:LOG ("Geralt not found in scene, add it")
		else 
			lua_table.System:LOG ("Geralt detected")
	end
	
	if lua_table.jaskier == 0 then 
		lua_table.System:LOG ("Jaskier not found in scene, add it")
		else 
			lua_table.System:LOG ("Jaskier detected")
	end

	lua_table.currentState = State.IDLE
	lua_table.Animations:PlayAnimation("Idle", 30.0, lua_table.MyUID)
	lua_table.System:LOG("Minion state: IDLE (0)") 
	lua_table.health = lua_table.max_hp

	-- Get colliders
	Front_Collider = lua_table.GameObject:FindChildGameObject(lua_table.Minion_Front)

	-- Initialize Nav
	navID = lua_table.Recast:GetAreaFromName("Walkable")
	
end

function lua_table:Update()

	SearchPlayers() -- Constantly calculate distances between entity and players

	-- Check if our entity is dead
	if lua_table.health <= 0 then 
		lua_table.currentState = State.DEATH
		lua_table.System:LOG("Minion state: Death (5)")
	end

	-- Check which state the entity is in and then handle them accordingly
	if lua_table.currentState == State.IDLE then 
		Idle()
	elseif lua_table.currentState == State.SEEK then 
		Seek()
	elseif lua_table.currentState == State.ATTACK then 
		Attack()
	elseif lua_table.currentState == State.KNOCKBACK then  
		KnockBack()
	elseif lua_table.currentState == State.STUNNED then  
		Stun()
	elseif lua_table.currentState == State.DEATH then	
		Die()
	end

	-- ResetState values when currentState ~= State.X
	if lua_table.currentState ~= State.SEEK then
		ResetNavigation()
	end
	if lua_table.currentState ~= State.ATTACK then
		ResetAttack()
	end
	if lua_table.currentState ~= State.KNOCKBACK then
		ResetKnockBack()
	end
	if lua_table.currentState ~= State.STUNNED then
		ResetStun()
	end

	-- Manual reset of taunt
	if taunt_timer + 5000 <= lua_table.System:GameTime() * 1000 then

		
		lua_table.is_taunt = false
		taunt_timer = 0
	
	end

------------------------------------------------
---------------------TESTS----------------------
------------------------------------------------
	-- -- ------------------------------------------------ TEST STUN
	-- if lua_table.Input:KeyUp("s") then
		
	-- 	lua_table.Animations:PlayAnimation("Hit", 30.0, lua_table.MyUID)
	-- 	start_stun = true
	-- 	lua_table.currentState = State.STUNNED
		
	-- 	lua_table.System:LOG("Minion state: STUNNED (5)")  
	-- end

	-- ------------------------------------------------ TEST KD
	-- -- Apply knockback to target, stun it for a second, then return to SEEK
	-- if lua_table.Input:KeyUp("d") then
	-- 	local knock_vector = {0, 0, 0}
	-- 	knock_vector[1] = lua_table.GhoulPos[1] - lua_table.currentTargetPos[1]
	-- 	knock_vector[2] = lua_table.GhoulPos[2] - lua_table.currentTargetPos[2]
	-- 	knock_vector[3] = lua_table.GhoulPos[3] - lua_table.currentTargetPos[3]
						
 	-- 	local module = math.sqrt(knock_vector[1] ^ 2 + knock_vector[3] ^ 2)

	-- 	knock_force[1] = knock_vector[1] / module
	-- 	knock_force[2] = knock_vector[2]
	-- 	knock_force[3] = knock_vector[3] / module

	-- 	lua_table.Animations:PlayAnimation("Hit", 30.0, lua_table.MyUID)

	-- 	lua_table.currentState = State.KNOCKBACK
	-- 	start_knockback = true
	-- 	lua_table.is_knockback = true
	-- 	lua_table.System:LOG("Minion state: KNOCKBACK (4)") 
	
	-- end
	-- ------------------------------------------------ TEST TAUNT
	-- if lua_table.Input:KeyUp("t") then
	-- 	start_taunt = true

	-- 	if start_taunt then 
	-- 		taunt_timer = lua_table.System:GameTime() * 1000
	-- 		lua_table.is_taunt = true
	-- 		lua_table.System:LOG("Getting taunted by Jaskier") 
	-- 		start_taunt = false
	-- 	end
	-- end

end

return lua_table
end