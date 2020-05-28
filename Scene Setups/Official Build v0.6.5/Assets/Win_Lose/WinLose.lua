function GetTableWinLose()
    local lua_table = {}
    lua_table.System = Scripting.System()
    lua_table.GO = Scripting.GameObject()
    lua_table.Transform = Scripting.Transform()
    lua_table.UI = Scripting.Interface()
    lua_table.Input = Scripting.Inputs()
    lua_table.Scene = Scripting.Scenes()
    lua_table.Physics = Scripting.Physics()
    lua_table.Audio = Scripting.Audio()
    
    lua_table.level1_uid = 0
    lua_table.level2_uid = 0
    lua_table.mm_uid = 0

    local pos = 0
    local winlose = 0

    local geralt_pos0 = 0
    local geralt_pos1 = 0
    local geralt_pos2 = 0
        
    local jaskier_pos0 = 0
    local jaskier_pos1 = 0
    local jaskier_pos2 = 0

    local fade = 0
    local win = 0
    local lose = 0
    local mainmenu = 0
    local nextlevel = 0
    local only_mainmenu = 0
    
    local Geralt = 0
    local geralt_script = 0
    local geralt_x = 0
    local geralt_y = 0
    local geralt_z = 0
    
    local Jaskier = 0
    local jaskier_script = 0
    local jaskier_x = 0
    local jaskier_y = 0
    local jaskier_z = 0

    local Kikimora = 0
    local kikimora_script = 0

    local FinalEnemy = 0
    local finalenemy_script = 0
    
    local is_win = false
    local is_lose = false
    
    local win_flag = false
    local lose_flag = false
    local fade_flag = false
    local fade_alpha = 0

    local load_level1 = false
    local load_level2 = false
    local load_mainmenu = false

    local play_win = false
    local play_lose = false
    
    local function Victory()
        lua_table.System:PauseGame()
        
        --victory sound
        --lua_table.Audio:PlayAudioEventGO("Play_Win_Menu_Music", winlose)
    
        --win animation
        lua_table.GO:SetActiveGameObject(true, win)
        if win_flag == false
        then
            if play_win == true
            then
                play_win = false
                lua_table.UI:PlayUIAnimation(win)
            end

            if lua_table.UI:UIAnimationFinished(win) == true
            then
                play_win = true
                win_flag = true
            end
        end

        --fade
        if win_flag == true
        then
            lua_table.GO:SetActiveGameObject(true, fade)
            if fade_flag == false
            then
                fade_alpha = fade_alpha + 0.01
                lua_table.UI:ChangeUIComponentAlpha("Image", fade_alpha, fade)
        
                if fade_alpha >= 1.0
                then
                    fade_flag = true
                end
            end
        end
    
        --buttons
        if fade_flag == true
        then
            if current_level == 1
            then
                lua_table.GO:SetActiveGameObject(true, mainmenu)
                lua_table.GO:SetActiveGameObject(true, nextlevel)
            elseif current_level == 2
            then
                lua_table.GO:SetActiveGameObject(true, only_mainmenu)
            end
        end
    end
    
    local function Defeat()
        lua_table.System:PauseGame()
    
        --defeat sound
        --lua_table.Audio:PlayAudioEventGO("Play_Lost_Menu_Music", winlose)

        --lose animation
        lua_table.GO:SetActiveGameObject(true, lose)
        if lose_flag == false
        then
            if play_lose == true
            then
                play_lose = false
                lua_table.UI:PlayUIAnimation(lose)
            end

            if lua_table.UI:UIAnimationFinished(lose) == true
            then
                play_lose = true
                lose_flag = true
            end
        end

        --fade
        if lose_flag == true
        then
            lua_table.GO:SetActiveGameObject(true, fade)
            if fade_flag == false
            then
                fade_alpha = fade_alpha + 0.01
                lua_table.UI:ChangeUIComponentAlpha("Image", fade_alpha, fade)
        
                if fade_alpha >= 1.0
                then
                    fade_flag = true
                end
            end
        end
    
        --reset level
        if fade_flag == true
        then
            --reset variables
            lose_flag = false
            fade_flag = false
            fade_alpha = 0
        
            --set ui inactive
            lua_table.GO:SetActiveGameObject(false, lose)
            lua_table.GO:SetActiveGameObject(false, fade)
        
            --unpause game
            lua_table.System:ResumeGame()
        
            --load current level
            if current_level == 1
            then
                load_level1 = true
            elseif current_level == 2
            then
                load_level2 = true
            end
        end
    end
    
    function lua_table:GoToMainMenu()
        --reset variables
        is_win = false
        win_flag = false
        fade_flag = false
        fade_alpha = 0
    
        --set ui inactive
        lua_table.GO:SetActiveGameObject(false, win)
        lua_table.GO:SetActiveGameObject(false, fade)
        lua_table.GO:SetActiveGameObject(false, mainmenu)
        lua_table.GO:SetActiveGameObject(false, nextlevel)
        lua_table.GO:SetActiveGameObject(false, only_mainmenu)
    
        --unpause game
        lua_table.System:ResumeGame()
    
        --load main menu
        last_checkpoint = 0
        load_mainmenu = true
    end
    
    function lua_table:GoToNextLevel()
        --reset variables
        is_win = false
        win_flag = false
        fade_flag = false
        fade_alpha = 0
    
        --set ui inactive
        lua_table.GO:SetActiveGameObject(false, win)
        lua_table.GO:SetActiveGameObject(false, fade)
        lua_table.GO:SetActiveGameObject(false, mainmenu)
        lua_table.GO:SetActiveGameObject(false, nextlevel)
        lua_table.GO:SetActiveGameObject(false, only_mainmenu)
    
        --unpause game
        lua_table.System:ResumeGame()
    
        --load next level (level 2)
        last_checkpoint = 0
        current_level = 2
        load_level2 = true
    end
    
    local function GetCheckpointPos()
        if last_checkpoint == nil or last_checkpoint == 0
        then
            pos = lua_table.Transform:GetPosition(geralt_pos0)
            geralt_x = pos[1]
            geralt_y = pos[2]
            geralt_z = pos[3]

            pos = lua_table.Transform:GetPosition(jaskier_pos0)
            jaskier_x = pos[1]
            jaskier_y = pos[2]
            jaskier_z = pos[3]
        elseif last_checkpoint == 1
        then
            pos = lua_table.Transform:GetPosition(geralt_pos1)
            geralt_x = pos[1]
            geralt_y = pos[2]
            geralt_z = pos[3]

            pos = lua_table.Transform:GetPosition(jaskier_pos1)
            jaskier_x = pos[1]
            jaskier_y = pos[2]
            jaskier_z = pos[3]
        elseif last_checkpoint == 2
        then
            pos = lua_table.Transform:GetPosition(geralt_pos2)
            geralt_x = pos[1]
            geralt_y = pos[2]
            geralt_z = pos[3]

            pos = lua_table.Transform:GetPosition(jaskier_pos2)
            jaskier_x = pos[1]
            jaskier_y = pos[2]
            jaskier_z = pos[3]
        end
    end
    
    function lua_table:Checkpoint()
        --get characters' respawn pos
        GetCheckpointPos()
    
        --Geralt Dead
        if geralt_script.current_state <= -4
        then
            --revive Geralt
            lua_table.GO:SetActiveGameObject(true, lua_table.GO:FindGameObject("Geralt_Mesh"))
            lua_table.GO:SetActiveGameObject(true, lua_table.GO:FindGameObject("Geralt_Pivot"))
            geralt_script:Start()
            lua_table.Physics:SetActiveController(true, Geralt)
    
            --set Geralt's pos in last checkpoint
            lua_table.Physics:SetCharacterPosition(geralt_x, geralt_y, geralt_z, Geralt)
        end
    
        --Jaskier Dead
        if jaskier_script.current_state <= -4
        then
            --revive Jaskier
            lua_table.GO:SetActiveGameObject(true, lua_table.GO:FindGameObject("Jaskier_Mesh"))
            lua_table.GO:SetActiveGameObject(true, lua_table.GO:FindGameObject("Jaskier_Pivot"))
            jaskier_script:Start()
            lua_table.Physics:SetActiveController(true, Jaskier)
    
            --set Jaskier's pos in last checkpoint
            lua_table.Physics:SetCharacterPosition(jaskier_x, jaskier_y, jaskier_z, Jaskier)
        end
    end
    
    -------------------------------------------------
    function lua_table:Awake()
        winlose = lua_table.GO:GetMyUID()

        --UI
        win = lua_table.GO:FindGameObject("Victory")
        lose = lua_table.GO:FindGameObject("Defeat")
        fade = lua_table.GO:FindGameObject("Fade")
        mainmenu = lua_table.GO:FindGameObject("MainMenu")
        nextlevel = lua_table.GO:FindGameObject("NextLevel")
        only_mainmenu = lua_table.GO:FindGameObject("OnlyMainMenu")
        
        --Geralt
        Geralt = lua_table.GO:FindGameObject("Geralt")
        if Geralt > 0
        then
            geralt_script = lua_table.GO:GetScript(Geralt)
        end
        
        --Jaskier
        Jaskier = lua_table.GO:FindGameObject("Jaskier")
        if Jaskier > 0
        then
            jaskier_script = lua_table.GO:GetScript(Jaskier)
        end
        
        --Win Condition
        if current_level == 1
        then
            FinalEnemy = lua_table.GO:FindGameObject("FinalEnemy")
            if FinalEnemy > 0
            then
                finalenemy_script = lua_table.GO:GetScript(FinalEnemy)
            end
        elseif current_level == 2
        then
            Kikimora = lua_table.GO:FindGameObject("Kikimora")
            if Kikimora > 0
            then
                kikimora_script = lua_table.GO:GetScript(Kikimora)
            end
        end

        --Respawn Pos
        geralt_pos0 = lua_table.GO:FindGameObject("GeraltPos0")
        geralt_pos1 = lua_table.GO:FindGameObject("GeraltPos1")
        geralt_pos2 = lua_table.GO:FindGameObject("GeraltPos2")
            
        jaskier_pos0 = lua_table.GO:FindGameObject("JaskierPos0")
        jaskier_pos1 = lua_table.GO:FindGameObject("JaskierPos1")
        jaskier_pos2 = lua_table.GO:FindGameObject("JaskierPos2")
    end
    
    function lua_table:Start()
        --respawn on last checkpoint
        GetCheckpointPos()
        lua_table.Physics:SetCharacterPosition(geralt_x, geralt_y, geralt_z, Geralt)
        lua_table.Physics:SetCharacterPosition(jaskier_x, jaskier_y, jaskier_z, Jaskier)
    end
    
    function lua_table:Update()
        -- DEBUG --
        if lua_table.Input:KeyRepeat("F1")
        then
            is_win = true
        elseif lua_table.Input:KeyRepeat("F2")
        then
            is_lose = true
        end
        -----------

        --check win/lose bools
        if is_win == true
        then
            Victory()
        elseif is_lose == true
        then
            Defeat()
        end
        
        --win condition
        if current_level == 1 and FinalEnemy > 0 and finalenemy_script.current_state == 5 and is_win == false
        then
            is_win = true
        elseif current_level == 2 and Kikimora > 0 and kikimora_script.dead == true and is_win == false
        then
            is_win = true
        end
    
        --lose condition
        if Geralt > 0 and Jaskier > 0 and geralt_script.current_state <= -3 and jaskier_script.current_state <= -3 and is_lose == false
        then
            is_lose = true
        end

        --change scene
        if load_level1 == true
        then
            load_level1 = false
            is_lose = false
            lua_table.Scene:LoadScene(lua_table.level1_uid)
        elseif load_level2 == true
        then
            load_level2 = false
            is_lose = false
            lua_table.Scene:LoadScene(lua_table.level2_uid)
        elseif load_mainmenu == true
        then
            load_mainmenu = false
            lua_table.Scene:LoadScene(lua_table.mm_uid)
        end
    end
    
    return lua_table
    end