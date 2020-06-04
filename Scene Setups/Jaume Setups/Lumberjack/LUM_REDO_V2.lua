function GetTableLUM_REDO_V2()
local lua_table = {}
lua_table.System = Scripting.System()

lua_table.SystemFunctions = Scripting.System()
lua_table.GameObjectFunctions = Scripting.GameObject()
lua_table.TransformFunctions = Scripting.Transform()
lua_table.PhysicsSystem =  Scripting.Physics()
lua_table.AnimationSystem = Scripting.Animations()
lua_table.SoundSystem = Scripting.Audio()
lua_table.ParticleSystem = Scripting.Particles()
lua_table.NavSystem = Scripting.Navigation()

--------------------General programming Notes-----------------
-- @ If want to do an action, call function: DoAction"X"() that activates a bool to later do that action in the HandleState()
-- @ Every HandleState() Has a ChooseBehaviour() function thta chooses what to do
-- @ If want to change to an state that has been executed before, call function ResetDetection()/ResetPreDetection...etc. it will make a reset of all variables to execute that handle"x"() as if it was the first time
-- @ States won't ever be changed inside ChooseBehaviour() function, states will be changed inside functions such as Handle"X"() functions

-- @ JumpAttack Animation frames
--se para para saltar en el frame: 357-337 voy a 30 frames por segundo
--357 al 363 se prepara cogiendo fuerza para saltar
--363 al 385 esta en el aire
--445 acaba la animaci�


--###Code for late uses###
--if PrintLogs == true then lua_table.SystemFunctions:LOG ("LUMBERJACK x") end

--------------------General programming Notes-----------------


local PrintLogs = false


--########################################### STATES ######################################################


local State = {
	NONE = 0,
	PRE_DETECTION = 1,
	DETECTION = 2,
	COMBAT = 3,
	DEAD = 4
}
	

--########################################### UTILITY VARIABLES ###########################################


local attack_colliders = {
	jump_attack = { GO_name = "Lumberjack_JA", GO_UID = 0 , active = false},
	front1 = { GO_name = "Lumberjack_FA1", GO_UID = 0 , active = false},
	front2 = { GO_name = "Lumberjack_FA2", GO_UID = 0 , active = false}
}

local particles = {
	alertParticles = { GO_name = "alert_scream_particles_lumberjack", GO_UID = 0 , active = false},
	GroundHitParticles1 = { GO_name = "ground_hit_particles_lumberjack1", GO_UID = 0 , active = false},--smoke
	GroundHitParticles2 = { GO_name = "ground_hit_particles_lumberjack2", GO_UID = 0 , active = false},-- ground crack
	stuntParticles = { GO_name = "stunt_particles_lumberjack", GO_UID = 0 , active = false},
	hitParticles = { GO_name = "hit_particles_lumberjack", GO_UID = 0 , active = false}
}

--Colliders
local layers = {
	default = 0,
	player = 1,
	player_attack = 2,
	enemy = 3,
	enemy_attack = 4
}
local AttackEffects = {	
	none = 0,
	stun = 1,
	knockback = 2,
	taunt = 3,
	venom = 4
}

local CurrentAttackEffect = AttackEffects.none


--Anim PlayTime
local AlertDuretion = 2550


--ChooseBehaviour() VARIABLES

local PreDetectionBehaviourChosen = false --HandlePreDetection()
local ChangeDetectionBehaviour = true --HandleDetection()
local ChangeCombatBehaviour = true
--Scream()

local ScreamAnimController = true
local ScreamDone = false
local DoScream = false

--SeekTarget()

local DoSeek = false
local CurrentTargetPosition = {}
local RunAnimationController = true
local DistanceMagnitude = 0

--Navigation

local Navigation_UID = 0
local Corners = {}
local ActualCorner = 2
local CalculatePath = true
local DistanceToCorner = -1
local CalculatePathTimer = 0

--jump_attack()

local MinDistanceToJump = 10
local OptimalDistanceJumpAttack = false
local DoJump = false
local JumpAttackPathCreated = false
local JumpAttack_fps = 50.0
local JumpAttackTimer = 0
local JumpStage = 0
local JumpAttackDone = false
local JumpAttackAuxTarget = {}
local CurrentlyJumping = false
local JumpAttackDuration = 1400 --this number depends on anim velocity and movement speed

--Attack()

local DoAttack = false
local TimeSinceLastAttack = 0
local TimeBetweenAttacks = 0
local AttackIdleAnimationController = true
local FirstAttack = true
local CurrentlyAttacking = false

--Die()

local DoDie = false
local DieStartTimer = 0
local DieAnimation_Controller = false
local StunAnimation_Controller = false

--Knockback()

local CalculatedKnockback = false
local KnockVector = {}
local NKvec = {}--normalized KnockVector
local KnockbackDone = false
local StunStartTimer = 0
--################################################ VARIABLES ############################################

lua_table.player_1 = "Geralt"
lua_table.player_2 = "Jaskier"

lua_table.Geralt_UID = 0
lua_table.Jaskier_UID = 0
local GeraltPos = {}
local JaskierPos = {}

local CurrentState = State.NONE

local MyPosition = {}
local dt = 0

local GeraltDistance = 0 --updated when call PlayersArround()
local JaskierDistance = 0

local CurrentTarget_UID = 0 
local MinDistanceFromPlayer = 1

local CurrentTime = 0

lua_table.CurrentVelocity = 0
lua_table.Nvec3x = 1
lua_table.Nvec3z = 1

lua_table.CurrentHealth = 0
lua_table.MaxHealth = 350


--#################################################### Utility ###########################################



local function PerfGameTime()
	return lua_table.SystemFunctions:GameTime() * 1000
end



local function CalculateDistanceTo(Position)
	
	A = Position[1] - MyPosition[1]	
	B = Position[3] - MyPosition[3]
	Distance = math.sqrt(A^2+B^2)
	return Distance
end


local function NormalizeDirVector()
	
	Nvec3x = vec3x / distance_to_corner--DistanceMagnitude--
	Nvec3z = vec3z / distance_to_corner--DistanceMagnitude-- -- Normalized values
end



--################################################### DO_SOMETHING #####################################



local function DoScreamNow(bool)
	DoScream = bool
end



local function DoSeekNow(bool)
	DoSeek = bool
end



local function DoJumpNow(bool)
	DoJump = bool
end



local function DoAttackNow(bool)
	DoAttack = bool
end


local function DoDieNow(bool)
	DoDie = bool
end

--#################################################### MAIN FUNCTIONS ####################################



local function SetDefaultValues()

	CurrentState = State.PRE_DETECTION
	lua_table.CurrentHealth = lua_table.MaxHealth

end



local function VariablesUpdate()

	MyPosition = lua_table.TransformFunctions:GetPosition(MyUID)
	dt = lua_table.SystemFunctions:DT()

	
	if CurrentTarget_UID ~= 0
	then
		CurrentTargetPosition = lua_table.TransformFunctions:GetPosition(CurrentTarget_UID)
	end
	
	if CurrentState ~= State.PRE_DETECTION
	then
		DistanceMagnitude = CalculateDistanceTo(CurrentTargetPosition)
	end

	if CalculatePath == false
	then
		if CurrentTime - CalculatePathTimer > 200
		then
			CalculatePath = true
		end
	end

	CurrentTime = PerfGameTime()
end



local function ResetPreDetection()
	
	PreDetectionBehaviourChosen = false
	CurrentTarget_UID = 0
end



local function ResetDetection(ResetScream)
	
	ChangeDetectionBehaviour = true 
	if ResetScream == true
	then
		ScreamAnimController = true
		ScreamDone = false
		DoScream = false
	end
	
	JumpStage = 0
	JumpAttackDone = false
	RunAnimationController = true
	MinDistanceToJump = 10
	OptimalDistanceJumpAttack = false
	DoJump = false
	JumpAttackPathCreated = false
	JumpAttackTimer = 0
	JumpAttackAuxTarget = {}
end



local function ResetCombat()
	DoAttackNow(false)
	ChangeCombatBehaviour = true
	FirstAttack = true
	TimeSinceLastAttack = 0
	TimeBetweenAttacks = 0
end



local function CalculateNewPath(Target) -- target must contain a lua table position variables list
	Corners = lua_table.NavSystem:CalculatePath(MyPosition[1],MyPosition[2],MyPosition[3],Target[1],Target[2],Target[3],1 << Navigation_UID)
	ActualCorner = 2
	CalculatePath = false
	CalculatePathTimer = PerfGameTime()
	if PrintLogs == true then lua_table.SystemFunctions:LOG ("LUMBERJACK Created a new path") end
end



local function FollowPath() --basically update the next corner in the curr path
	--if PrintLogs == true then lua_table.SystemFunctions:LOG ("LUMBERJACK following the path") end

	DistanceMagnitude = CalculateDistanceTo(CurrentTargetPosition)

	local NextCorner = {}
    NextCorner[1] = Corners[ActualCorner][1] - MyPosition[1]
    NextCorner[2] = Corners[ActualCorner][2] - MyPosition[2]
    NextCorner[3] = Corners[ActualCorner][3] - MyPosition[3]

	DistanceToCorner = CalculateDistanceTo(Corners[ActualCorner])

	if DistanceToCorner > 0.20
	then
		lua_table.Nvec3x = NextCorner[1] / DistanceToCorner
        lua_table.Nvec3z = NextCorner[3] / DistanceToCorner
	else
		ActualCorner = ActualCorner +1	
	end

	--lua_table.TransformFunctions:LookAt(MyPosition[1] + NextCorner[1] ,MyPosition[2],MyPosition[3] + NextCorner[3],MyUID)	
end



local function PlayersArround() --Returns a boolean if players are or not arround
	
	ret = false

	lua_table.Geralt_UID = lua_table.GameObjectFunctions:FindGameObject(lua_table.player_1)
    lua_table.Jaskier_UID = lua_table.GameObjectFunctions:FindGameObject(lua_table.player_2)

	if Geralt_UID ~= 0
	then
		GeraltPos = lua_table.TransformFunctions:GetPosition(Geralt_UID)
		GeraltDistance = CalculateDistanceTo(GeraltPos)
	end
	if Jaskier_UID ~= 0
	then
		JaskierPos = lua_table.TransformFunctions:GetPosition(Jaskier_UID)
		JaskierDistance = CalculateDistanceTo(JaskierPos)
	end

	if JaskierDistance < 20 or GeraltDistance < 20
	then
		ret = true	
	end

	return ret
end



local function CalculateAggro() --Called only after players() return true

	ret = false

	JaskierScript = lua_table.GameObjectFunctions:GetScript(Jaskier_UID)
	GeraltScript = lua_table.GameObjectFunctions:GetScript(Geralt_UID)

	--if PrintLogs == true then lua_table.SystemFunctions:LOG ("JaskierScript  "..JaskierScript) end

	if CurrentTarget_UID == 0
	then	
		if JaskierDistance < GeraltDistance
		then
			if JaskierScript.current_state == -3 or JaskierScript.current_state == -4
			then
				CurrentTarget_UID = Geralt_UID
				ret = true
				if PrintLogs == true then lua_table.SystemFunctions:LOG ("LUMBERJACK CurrentTarget = Geralt_UID") end
			else
				CurrentTarget_UID = Jaskier_UID
				ret = true
				if PrintLogs == true then lua_table.SystemFunctions:LOG ("LUMBERJACK CurrentTarget = Jaskier_UID") end
			end	
			CurrentTarget_UID = Jaskier_UID
		elseif GeraltDistance < JaskierDistance
		then
			if GeraltScript.current_state == -3 or GeraltScript.current_state == -4
			then
				CurrentTarget_UID = Jaskier_UID
				ret = true
				if PrintLogs == true then lua_table.SystemFunctions:LOG ("LUMBERJACK CurrentTarget = Jaskier_UID") end
			else
				CurrentTarget_UID = Geralt_UID
				ret = true
				if PrintLogs == true then lua_table.SystemFunctions:LOG ("LUMBERJACK CurrentTarget = Geralt_UID") end
			end	
		end		
	elseif CurrentTarget_UID ~= 0
	then 
		if CurrentTarget_UID == Jaskier_UID
		then
			if JaskierScript.current_state == -3 or JaskierScript.current_state == -4
			then
				if GeraltScript.current_state == -3 or GeraltScript.current_state == -4
				then
					ret = false--both on the ground
				else
					CurrentTarget_UID = Geralt_UID
					ret = true
					if PrintLogs == true then lua_table.SystemFunctions:LOG ("LUMBERJACK change CurrentTarget = Geralt_UID") end
				end	
			end
		elseif CurrentTarget_UID == Geralt_UID
		then
			if GeraltScript.current_state == -3 or GeraltScript.current_state == -4
			then
				if JaskierScript.current_state == -3 or JaskierScript.current_state == -4
				then
					ret = false--both on the ground
				else
					CurrentTarget_UID = Jaskier_UID
					ret = true
					if PrintLogs == true then lua_table.SystemFunctions:LOG ("LUMBERJACK change CurrentTarget = Jaskier_UID") end
				end	
			end
		end
	end

	return ret
end



local function ApplyVelocity()

	if CurrentAttackEffect == AttackEffects.none
	then

		if CurrentState == State.PRE_DETECTION
		then
			lua_table.Nvec3x = lua_table.Nvec3x * 0
			lua_table.Nvec3z = lua_table.Nvec3z * 0
		end
		if CurrentState == State.DETECTION 
		then
			lua_table.Nvec3x = lua_table.Nvec3x * lua_table.CurrentVelocity
			lua_table.Nvec3z = lua_table.Nvec3z * lua_table.CurrentVelocity
		end
		if CurrentState == State.COMBAT
		then
			lua_table.Nvec3x = lua_table.Nvec3x * lua_table.CurrentVelocity
			lua_table.Nvec3z = lua_table.Nvec3z * lua_table.CurrentVelocity
		end
	elseif CurrentAttackEffect == AttackEffects.knockback and CalculatedKnockback == true -- no entra aqui
	then
		lua_table.Nvec3x = NKvec[1] * lua_table.CurrentVelocity
		lua_table.Nvec3z = NKvec[3] * lua_table.CurrentVelocity
	end
end


local function CalculateJumpAttackVelocity()
	-- @ JumpAttack Animation frames
	--se para para saltar en el frame: 357-337 = 20 frames voy a 30 frames por segundo
	--357 al 363 = 6 frames se prepara cogiendo fuerza para saltar
	--363 al 385 = 22 frames esta en el aire
	--445 acaba la animaci�
	--TOTAL TIME IN 30FPS = 3.550 SEC	
	MilisecondsPerframe = 1000/JumpAttack_fps -- if fps = 30, = 33.3333
	JA_TimeFirstPart = MilisecondsPerframe * 20
	JA_TimeSecondPart = MilisecondsPerframe * 6
	JA_TimeThirdPart = MilisecondsPerframe * 32--22
	JA_TimeForthPart = MilisecondsPerframe * 60 
	JA_TotalTime = MilisecondsPerframe * 108

	Timer = CurrentTime - JumpAttackTimer

	if CalculatePath == true
		then
			CalculateNewPath(CurrentTargetPosition)
			JumpAttackAuxTarget = CurrentTargetPosition
			if JumpStage ~= 4
			then
				lua_table.TransformFunctions:LookAt(MyPosition[1] + (CurrentTargetPosition[1] - MyPosition[1]),MyPosition[2],MyPosition[3] + (CurrentTargetPosition[3] - MyPosition[3]),MyUID)
			end
		end

	if JumpStage == 0 -- Simplement Chuska'l 
	then
		if Timer < JA_TimeFirstPart 
		then
			JumpStage = 1
			lua_table.CurrentVelocity = 5
			if PrintLogs == true then lua_table.SystemFunctions:LOG ("LUMBERJACK  PART  1  ###############################################"..JA_TimeFirstPart) end
			JumpAttackTimer = CurrentTime  
		end
	elseif  JumpStage == 1
	then
		if Timer > JA_TimeFirstPart
		then
			JumpStage = 2
			lua_table.CurrentVelocity = 0
			if PrintLogs == true then lua_table.SystemFunctions:LOG ("LUMBERJACK  PART  2  ###############################################"..JA_TimeSecondPart) end
			JumpAttackTimer = CurrentTime
		end
	elseif  JumpStage == 2
	then
		if Timer > JA_TimeSecondPart
		then
			JumpStage = 3
			lua_table.CurrentVelocity = 11.6
			if PrintLogs == true then lua_table.SystemFunctions:LOG ("LUMBERJACK  PART  3  ###############################################"..JA_TimeThirdPart) end
			JumpAttackTimer = CurrentTime
		end
	elseif  JumpStage == 3
	then
		if Timer > JA_TimeThirdPart 
		then
			JumpStage = 4
			lua_table.CurrentVelocity = 0
			if PrintLogs == true then lua_table.SystemFunctions:LOG ("LUMBERJACK  PART  4  ############################################### "..JA_TimeForthPart) end
			JumpAttackTimer = CurrentTime
		end
	end

	--frame = lua_table.AnimationSystem:GetCurrentFrame(MyUID)
	--if PrintLogs == true then lua_table.SystemFunctions:LOG ("LUMBERJACK FRAMES:                                   CURRENTfRAME = "..frame) end
	--if PrintLogs == true then lua_table.SystemFunctions:LOG ("LUMBERJACK JA_TIME:                                  DebugTime = "..Timer) end

end



local function Scream()
	
	if ScreamAnimController == true
	then
		lua_table.AnimationSystem:PlayAnimation("ALERT", 30.0,MyUID)
		ScreamAnimController = false
		ChangeDetectionBehaviour = false
		ScreamTimeController = PerfGameTime()
	end

	if CurrentTime - ScreamTimeController > AlertDuretion
	then
		ScreamDone = true
		ChangeDetectionBehaviour = true
		if PrintLogs == true then lua_table.SystemFunctions:LOG ("LUMBERJACK ScreamDone = true") end
	end
end



local function SeekTarget()
	
	if CalculatePath == true
	then
		CalculateNewPath(CurrentTargetPosition)
	end
	
	lua_table.CurrentVelocity = 6.5
	FollowPath()

	if RunAnimationController == true
	then
		lua_table.AnimationSystem:PlayAnimation("RUN",40.0,MyUID)
		ChangeDetectionBehaviour = false
		RunAnimationController = false
	end

	lua_table.TransformFunctions:LookAt(MyPosition[1] + (CurrentTargetPosition[1] - MyPosition[1]),MyPosition[2],MyPosition[3] + (CurrentTargetPosition[3] - MyPosition[3]),MyUID)

	DistanceMagnitude = CalculateDistanceTo(CurrentTargetPosition)
	if DistanceMagnitude < (MinDistanceToJump + 1) and DistanceMagnitude > MinDistanceToJump + 0.5
	then
		ChangeDetectionBehaviour = true
		OptimalDistanceJumpAttack = true
	end 

end



local function JumpAttack()

	if JumpAttackPathCreated == false --Create a path the first time this function is created
	then
		CalculateNewPath(CurrentTargetPosition)
		JumpAttackAuxTarget = CurrentTargetPosition
		JumpAttackTimer = PerfGameTime()
		JumpAttackPathCreated = true
		CurrentlyJumping = true
		--lua_table.AnimationSystem:SetBlendTime(0.0,MyUID)
		lua_table.AnimationSystem:PlayAnimation("JUMP_ATTACK",JumpAttack_fps,MyUID)
	end

	DistanceAuxTarget = CalculateDistanceTo(JumpAttackAuxTarget)
	A = CurrentTime - JumpAttackTimer

	if JumpAttackPathCreated == true
	then		
		CalculateJumpAttackVelocity() -- VELOCITY AND PATH TO MAKE IT MORE DIFFICULT
		if DistanceAuxTarget > MinDistanceFromPlayer and CurrentTime - JumpAttackTimer < JumpAttackDuration
		then
			FollowPath()
		elseif DistanceAuxTarget < MinDistanceFromPlayer or CurrentTime - JumpAttackTimer > JumpAttackDuration
		then    
			JumpAttackDone = true
			lua_table.CurrentVelocity = 0
			if PrintLogs == true then lua_table.SystemFunctions:LOG ("LUMBERJACK JumpAttackDone = true ") end
		end
	end
	--when jump attack ends, reset all seek bools if distance to target is enought to be in attack mode
end


local function Attack()
	if CurrentTime - TimeSinceLastAttack > (TimeBetweenAttacks + 1000) or FirstAttack == true --Choms found here the troyan horse
	then
		CurrentlyAttacking = true
		FirstAttack = false
		Dice = lua_table.SystemFunctions:RandomNumberInRange(0,10)
		if Dice < 5 
		then
			lua_table.AnimationSystem:PlayAnimation("ATTACK_1",30.0, MyUID)
			TimeBetweenAttacks = 1500 --time animation duration
			TimeSinceLastAttack = PerfGameTime()
			AttackIdleAnimationController = true
		elseif Dice >= 5  
		then
			lua_table.AnimationSystem:PlayAnimation("ATTACK_2",40.0, MyUID)
			TimeBetweenAttacks = 2100 --time animation duration
			TimeSinceLastAttack = PerfGameTime()
			AttackIdleAnimationController = true
		end
	elseif CurrentTime - TimeSinceLastAttack > TimeBetweenAttacks and CurrentTime - TimeSinceLastAttack < (TimeBetweenAttacks + 1000)
	then
		if AttackIdleAnimationController == true
		then
			CurrentlyAttacking = false
			lua_table.AnimationSystem:PlayAnimation("IDLE",30.0,MyUID)
			AttackIdleAnimationController = false
		end		
	end
	lua_table.TransformFunctions:LookAt(MyPosition[1] + (CurrentTargetPosition[1] - MyPosition[1]),MyPosition[2],MyPosition[3] + (CurrentTargetPosition[3] - MyPosition[3]),MyUID)
end


local function Die()
	
	if DieAnimation_Controller == false
	then	
		lua_table.AnimationSystem:PlayAnimation("DEATH",30.0,MyUID)
		DieAnimation_Controller = true
	end

	if CurrentTime - DieStartTimer > 5000
	then
		lua_table.GameObjectFunctions:DestroyGameObject(MyUID)	
	end
end

local function ChooseBehaviour() --Called only inside State machine's functions

	if CurrentState == State.PRE_DETECTION
	then
		if PreDetectionBehaviourChosen == false
		then
			if PrintLogs == true then lua_table.SystemFunctions:LOG ("LUMBERJACK Changing Behaviour of State.PRE_DETECTION") end
			Dice = lua_table.SystemFunctions:RandomNumberInRange(0,10)
			if Dice >= 7
			then
				lua_table.AnimationSystem:PlayAnimation("UNARMED_IDLE",30.0,MyUID)
				PreDetectionBehaviourChosen = true
			elseif Dice >= 3 and Dice < 7
			then
				lua_table.AnimationSystem:PlayAnimation("LOOKING_ARROUND",30.0,MyUID)
				PreDetectionBehaviourChosen = true
			elseif Dice < 3
			then
				lua_table.AnimationSystem:PlayAnimation("IDLE",30.0,MyUID)
				PreDetectionBehaviourChosen = true
			end
		end
	end
	-------------------------------------------------------------------------------------------------------------------------------------------------------------
	if CurrentState == State.DETECTION
	then
		if  ChangeDetectionBehaviour == true --every time a behaviour function is done, this changes to false, if want to change behaviour change to true
		then
			if PrintLogs == true then lua_table.SystemFunctions:LOG ("LUMBERJACK Changing Behaviour of State.DETECTION") end
			if ScreamDone == false
			then
				DoScreamNow(true)
			end
			if ScreamDone == true
			then 
				DoScreamNow(false)
				if DoSeek == false and DoJump == false
				then
					DoSeekNow(true)
				end
				if DoSeek == true and OptimalDistanceJumpAttack == true
				then
					if DoJump == false
					then
						DoSeekNow(false)
						DoJumpNow(true)
					end
				end
			end		
		end
	end
	---------------------------------------------------------------------------------------------------------------------------------------------------------------
	if CurrentState == State.COMBAT
	then
		if ChangeCombatBehaviour == true
		then
			--if PrintLogs == true then lua_table.SystemFunctions:LOG ("LUMBERJACK Changing Behaviour of State.COMBAT") end
			if DoAttack == false
			then
				DoAttackNow(true)
				TimeSinceLastAttack = PerfGameTime()
			end
		end
	end
	---------------------------------------------------------------------------------------------------------------------------------------------------------------
	if CurrentState == State.DEAD
	then
		if DoDie == false
		then
			if PrintLogs == true then lua_table.SystemFunctions:LOG ("LUMBERJACK Changing Behaviour of State.DEAD") end
			DoDieNow(true)
			DieStartTimer = PerfGameTime()
		end
	end

end



--#################################################### STATE MACHINE FUNCTIONS ###########################



local function HandlePreDetection()
	
	ChooseBehaviour()
	
	if PlayersArround() == true
	then	
		if CalculateAggro() == true
		then
			CurrentState = State.DETECTION
		else 
			if PrintLogs == true then lua_table.SystemFunctions:LOG ("LUMBERJACK NO POSSIBLE TARGET AVAIABLE") end
		end
	end
end



local  function HandleDetection()
	
	ChooseBehaviour()

	if DoScream == true
	then
		--While doing scream rotate towards the player
		lua_table.TransformFunctions:LookAt(MyPosition[1] + (CurrentTargetPosition[1] - MyPosition[1]),MyPosition[2],MyPosition[3] + (CurrentTargetPosition[3] - MyPosition[3]),MyUID)
		Scream()
	end

	if DoSeek == true
	then
		--if PrintLogs == true then lua_table.SystemFunctions:LOG ("LUMBERJACK SeekTarget()") end
		SeekTarget()	
	end	

	if DoJump == true and JumpAttackDone == false
	then
		if PrintLogs == true then lua_table.SystemFunctions:LOG ("LUMBERJACK JUMP_ATTACK()") end
		JumpAttack()
	end
	if JumpAttackDone == true
	then	
		CurrentlyJumping = false
		if DistanceMagnitude < 2 
		then
			CurrentState = State.COMBAT
			ResetDetection(false)--RESET DETECTION VARIABLES without Scream
			lua_table.CurrentVelocity = 0	
		elseif DistanceMagnitude > 2
		then
			Dice = lua_table.SystemFunctions:RandomNumberInRange(1,10)
			if Dice < 2 
			then
				ResetDetection(true)--RESET DETECTION VARIABLES with Scream
			else
				ResetDetection(false)--RESET DETECTION VARIABLES without Scream
			end
			lua_table.CurrentVelocity = 0
		end
	end
	if CurrentlyJumping == false and DistanceMagnitude < 2
	then
		CurrentState = State.COMBAT
		ResetDetection(false)--RESET DETECTION VARIABLES without Scream
		lua_table.CurrentVelocity = 0
	end
end

local function HandleCombat()
	
	if DistanceMagnitude > 2 and CurrentlyAttacking == false
	then
		CurrentState = State.DETECTION
		ResetCombat()
	end

	ChooseBehaviour()
	
	if DoAttack == true
	then
		Attack()
	end
end



local function HandleDead()
	
	ChooseBehaviour()

	if DoDie == true
	then
		Die()
	end
end



local function knockback()
	
	if CalculatedKnockback == false
	then
		CalculatedKnockback = true
		lua_table.SystemFunctions:LOG("AttackEffects.knockback START")
		KnockVector[1] = GeraltPos[1] - MyPosition[1]--x
		KnockVector[3] = GeraltPos[3] - MyPosition[3]--z
		
		GPos = lua_table.TransformFunctions:GetPosition(lua_table.Geralt_UID)
		NKvec[1] =  KnockVector[1] / CalculateDistanceTo(GPos)
		NKvec[3] =  KnockVector[3] / CalculateDistanceTo(GPos)
		NKvec[2] =  0
		
		TimeKnockBackStarted = PerfGameTime()
	end

	lua_table.CurrentVelocity = 10

	lua_table.TransformFunctions:LookAt(MyPosition[1] + (CurrentTargetPosition[1] - MyPosition[1]),MyPosition[2],MyPosition[3] + (CurrentTargetPosition[3] - MyPosition[3]),MyUID)
	
	lua_table.SystemFunctions:LOG("AttackEffects.knockback CURRENTLY")

	if CurrentTime - TimeKnockBackStarted > 500 or DistanceMagnitude > 15
	then
		lua_table.SystemFunctions:LOG("AttackEffects.knockback END")
		--CalculatedKnockback = false
		KnockbackDone = true
		CurrentAttackEffect = AttackEffects.none
	end
end



local function Stun()

	if StunAnimation_Controller == false
	then
		lua_table.AnimationSystem:PlayAnimation("HIT",10.0,MyUID)
		StunAnimation_Controller = true
		StunStartTimer = PerfGameTime()
	end
	
	if CurrentTime - StunStartTimer > 1000 
	then
		CurrentAttackEffect = AttackEffects.none
		StunAnimation_Controller = false
	end
	

end



--#################################################### MAIN CODE #########################################



function lua_table:RequestedTrigger(collider_GO)

	if PrintLogs == true then lua_table.SystemFunctions:LOG ("LUMBERJACK lua_table:RequestedTriggerEnter()") end
	if CurrentState ~= State.DEAD and lua_table.GameObjectFunctions:GetLayerByID(collider_GO) == 2 --player attack
	then
		local collider_parent = lua_table.GameObjectFunctions:GetGameObjectParent(collider_GO)
 		local player_script = {}

		if collider_parent ~= 0 
		then
			player_script = lua_table.GameObjectFunctions:GetScript(collider_parent)
		else
		 	player_script = lua_table.GameObjectFunctions:GetScript(collider_GO)
		end
		lua_table.CurrentHealth = lua_table.CurrentHealth - player_script.collider_damage
		lua_table.SystemFunctions:LOG("PEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE")

		if player_script.collider_effect ~= AttackEffects.none --and lua_table.CurrentSpecialEffect == SpecialEffect.NONE
		then
			if player_script.collider_effect ~= AttackEffects.NONE
			then
				if player_script.collider_effect == AttackEffects.taunt
				then
					CurrentTarget_UID = lua_table.Jaskier_UID
				end
				if player_script.collider_effect == AttackEffects.stun 
				then
					lua_table.SystemFunctions:LOG("player_script.collider_effect == AttackEffects.stun")
					CurrentAttackEffect = AttackEffects.stun
				end
				if player_script.collider_effect == AttackEffects.knockback --and lua_table.CurrentSpecialEffect == SpecialEffect.NONE
				then
					lua_table.SystemFunctions:LOG("player_script.collider_effect == AttackEffects.knockback")
					CurrentAttackEffect = AttackEffects.knockback
				end
			end
		end
	end
end


function lua_table:OnTriggerEnter()	

	if PrintLogs == true then lua_table.SystemFunctions:LOG ("LUMBERJACK lua_table:OnTriggerEnter()	") end
	local collider_GO = lua_table.PhysicsSystem:OnTriggerEnter(MyUID)
	
	if CurrentState ~= State.DEAD and lua_table.GameObjectFunctions:GetLayerByID(collider_GO) == 2 --player attack
	then
		local collider_parent = lua_table.GameObjectFunctions:GetGameObjectParent(collider_GO)
 		local player_script = {}

		if collider_parent ~= 0 
		then
			player_script = lua_table.GameObjectFunctions:GetScript(collider_parent)
		else
		 	player_script = lua_table.GameObjectFunctions:GetScript(collider_GO)
		end
		lua_table.CurrentHealth = lua_table.CurrentHealth - player_script.collider_damage
		if PrintLogs == true then lua_table.SystemFunctions:LOG ("LUMBERJACK DAMAGE TAKEN = -  	") end
		lua_table.SystemFunctions:LOG("DAMAGE TAKEN = -  "..player_script.collider_damage)

		if player_script.collider_effect ~= AttackEffects.none --and lua_table.CurrentSpecialEffect == SpecialEffect.NONE
		then
			if player_script.collider_effect ~= AttackEffects.NONE
			then
				if player_script.collider_effect == AttackEffects.stun 
				then

					CurrentAttackEffect = AttackEffects.stun
				end
				if player_script.collider_effect == AttackEffects.knockback --and lua_table.CurrentSpecialEffect == SpecialEffect.NONE
				then
					lua_table.SystemFunctions:LOG("player_script.collider_effect == AttackEffects.knockback")
					if PrintLogs == true then lua_table.SystemFunctions:LOG ("LUMBERJACK player_script.collider_effect == AttackEffects.knockback  	") end
					CurrentAttackEffect = AttackEffects.knockback
				end
			end
		end
	end
	--lua_table.SystemFunctions:LOG("OnTriggerEnter()".. collider_GO)
end


function lua_table:OnCollisionEnter()
	local collider = lua_table.PhysicsSystem:OnCollisionEnter(MyUID)
	--lua_table.SystemFunctions:LOG("T: ".. collider)
end




function lua_table:Awake()
	
	lua_table.SystemFunctions:LOG("LUMBERJACK AWAKE")

    ---GET PLAYERS ID---
	Geralt_UID = lua_table.GameObjectFunctions:FindGameObject(lua_table.player_1)
    Jaskier_UID = lua_table.GameObjectFunctions:FindGameObject(lua_table.player_2) 

	if Geralt_UID == 0 
	then 
		if PrintLogs == true then lua_table.SystemFunctions:LOG ("LUMBERJACK A random Lumberjack Script: Null Geralt id, called from Lumberjack AWAKE") end
	end
    if Jaskier_UID == 0 
	then 
		if PrintLogs == true then lua_table.SystemFunctions:LOG ("LUMBERJACK A random Lumberjack Script: Null Jaskier id, called from Lumberjack AWAKE") end
    end

    ---GET LUMBERJACK ID---
	MyUID = lua_table.GameObjectFunctions:GetMyUID()
	if MyUID == 0 
	then 
		if PrintLogs == true then lua_table.SystemFunctions:LOG ("A random Lumberjack Script: Null id for the GameObject that contains the Lumberjack Script, called from Lumberjack AWAKE") end
	end

	---SET COLLIDERS---
	--attack_colliders.jump_attack.GO_UID = lua_table.GameObjectFunctions:FindChildGameObject(attack_colliders.jump_attack.GO_name)
	--attack_colliders.front1.GO_UID = lua_table.GameObjectFunctions:FindChildGameObject(attack_colliders.front1.GO_name)
	--attack_colliders.front2.GO_UID = lua_table.GameObjectFunctions:FindChildGameObject(attack_colliders.front1.GO_name)
end



function lua_table:Start()
	
	SetDefaultValues()
end



function lua_table:Update()

	VariablesUpdate() -- postions for example
	
	if lua_table.CurrentHealth < 1
	then
		CurrentState = State.DEAD
	end

	if CurrentAttackEffect == AttackEffects.none
	then
		if CurrentState == State.NONE
		then
			if PrintLogs == true then lua_table.SystemFunctions:LOG ("LUMBERJACK STATE NONE") end
		elseif CurrentState == State.PRE_DETECTION
		then
			HandlePreDetection()
		elseif CurrentState == State.DETECTION
		then
			HandleDetection()
		elseif CurrentState == State.COMBAT
		then
			HandleCombat()
		elseif CurrentState == State.DEAD
		then
			HandleDead()
		end
	elseif CurrentAttackEffect == AttackEffects.knockback
	then
		knockback()
		if KnockbackDone == true
		then
			CalculateNewPath(CurrentTargetPosition) --When ending knockback need a new path to move
			lua_table.CurrentVelocity = 0
			KnockbackDone = false
			CalculatedKnockback = false
		end
	elseif CurrentAttackEffect == AttackEffects.stun
	then
		CurrentAttackEffect = AttackEffects.none
		Stun()
	end
	

	--MOVE
	ApplyVelocity()
	lua_table.PhysicsSystem:Move(lua_table.Nvec3x* dt,lua_table.Nvec3z* dt,MyUID)
	
end

return lua_table
end