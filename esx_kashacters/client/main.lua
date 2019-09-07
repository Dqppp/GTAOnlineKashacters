local stuff = {
    choosing = true,
    peds = {},
    spawnPositions = {
        vector3(409.43, -1000.46, -100.0), -- vector3(409.94, -1000.42, -99.0), 358.35
        vector3(409.48, -999.34, -100.0), -- vector3(409.87, -1001.05, -99.0)
        vector3(409.48, -998.06, -100.0), -- vector3(409.81, -1002.03, -99.0)
        vector3(409.48, -996.7, -100.0), -- vector3(409.7, -1002.9, -99.0)
    },
    characters = {
        false, false, false, false
    },
    pedboards = {},
    current = 1,
}

local handle
local board
local board_model = GetHashKey("prop_police_id_board")
local board_pos = vector3(0.0,0.0,0.0)
local board_scaleform
local overlay
local overlay_model = GetHashKey("prop_police_id_text")

local function CreateNamedRenderTargetForModel(name, model)
	local handle = 0
	if not IsNamedRendertargetRegistered(name) then
		RegisterNamedRendertarget(name, 0)
	end
	if not IsNamedRendertargetLinked(model) then
		LinkNamedRendertarget(model)
	end
	if IsNamedRendertargetRegistered(name) then
		handle = GetNamedRendertargetRenderId(name)
	end

	return handle
end

local function LoadScaleform (scaleform)
	local handle = RequestScaleformMovie(scaleform)

	if handle ~= 0 then
		while not HasScaleformMovieLoaded(handle) do
			Citizen.Wait(0)
		end
	end

	return handle
end

local function CallScaleformMethod (scaleform, method, ...)
	local t
	local args = { ... }

	BeginScaleformMovieMethod(scaleform, method)

	for k, v in ipairs(args) do
		t = type(v)
		if t == 'string' then
			PushScaleformMovieMethodParameterString(v)
		elseif t == 'number' then
			if string.match(tostring(v), "%.") then
				PushScaleformMovieFunctionParameterFloat(v)
			else
				PushScaleformMovieFunctionParameterInt(v)
			end
		elseif t == 'boolean' then
			PushScaleformMovieMethodParameterBool(v)
		end
	end

	EndScaleformMovieMethod()
end

Citizen.CreateThread(function()
	board_scaleform = LoadScaleform("mugshot_board_01")
	handle = CreateNamedRenderTargetForModel("ID_Text", overlay_model)


	while handle do
		SetTextRenderId(handle)
		Set_2dLayer(4)
		Citizen.InvokeNative(0xC6372ECD45D73BCD, 1)
		DrawScaleformMovie(board_scaleform, 0.405, 0.37, 0.81, 0.74, 255, 255, 255, 255, 0)
		Citizen.InvokeNative(0xC6372ECD45D73BCD, 0)
		SetTextRenderId(GetDefaultScriptRendertargetRenderId())

		Citizen.InvokeNative(0xC6372ECD45D73BCD, 1)
		Citizen.InvokeNative(0xC6372ECD45D73BCD, 0)
		Wait(0)
	end
end)

CreateBoard = function(ped)
    
    RequestModel(board_model)
    while not HasModelLoaded(board_model) do Wait(0) end
    RequestModel(overlay_model)
    while not HasModelLoaded(overlay_model) do Wait(0) end
    board = CreateObject(board_model, GetEntityCoords(ped), false, true, false)
    overlay = CreateObject(overlay_model, GetEntityCoords(ped), false, true, false)
    AttachEntityToEntity(overlay, board, -1, 4103, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)

    ClearPedWetness(ped)
    ClearPedBloodDamage(ped)
    ClearPlayerWantedLevel(PlayerId())
    SetCurrentPedWeapon(ped, GetHashKey("weapon_unarmed"), 1)
    AttachEntityToEntity(board, ped, GetPedBoneIndex(ped, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0, 0, 0, 0, 2, 1)
    
    CallScaleformMethod(board_scaleform, 'SET_BOARD', 'XXXX-XX-XX', 'Firstname Lastname', 'Bank: 0', 'Cash: 0' , 0, 0, 116)
end

LongHelpText = function(text)
    AddTextEntry("klf_long_help_text", text)
    DisplayHelpTextThisFrame("klf_long_help_text", false)
end

NextCharacter = function()
    local dict = "mp_character_creation@customise@male_a"
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Wait(0) end
    -- TaskPlayAnim(stuff.peds[stuff.current], dict, "drop_intro", 8.0, 8.0, -1, 50, 0, false, false, false)
    TaskPlayAnim(stuff.peds[stuff.current], dict, "drop_intro", 8.0, 8.0, -1, 14, 0, false, false, false)
    if stuff.current == 4 then
        stuff.current = 1
    else
        stuff.current = stuff.current + 1
    end

    AttachEntityToEntity(overlay, board, -1, 4103, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
    AttachEntityToEntity(board, stuff.peds[stuff.current], GetPedBoneIndex(stuff.peds[stuff.current], 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0, 0, 0, 0, 2, 1)
    TaskPlayAnim(stuff.peds[stuff.current], dict, "drop_outro", 8.0, 8.0, -1, 14, 0, false, false, false)
end


Citizen.CreateThread(function()
    while not NetworkIsSessionStarted() or not DoesEntityExist(PlayerPedId()) do Wait(0) end
    ShutdownLoadingScreen()
    Wait(0)
    ShutdownLoadingScreenNui()
    while not IsScreenFadedOut() do Wait(0) DoScreenFadeOut(0) end
    TriggerEvent('skinchanger:loadDefaultModel', true)
    TriggerServerEvent('loaf_character:getChars')

    Citizen.CreateThread(function()
        while true do
            Wait(0)
            if stuff.choosing then
                if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), 415.52, -998.38, -99.4, true) <= 1.5 then
                    SetEntityCoords(PlayerPedId(), 415.52, -998.38, -99.4)
                    SetEntityVisible(PlayerPedId(), false, false)
                end
                for i = 0, 31 do
                    DisableAllControlActions(i)
                end
                for i = 1, #stuff.spawnPositions do
                    SetEntityCoords(stuff.peds[i], stuff.spawnPositions[i])
                end
                if stuff.characters[stuff.current] == false then
                    CallScaleformMethod(board_scaleform, 'SET_BOARD', 'XXXX-XX-XX', 'Firstname Lastname', 'Bank: 0', 'Cash: 0' , 0, 0, 116)
                else
                    local ch = stuff.characters[stuff.current]
                    CallScaleformMethod(board_scaleform, 'SET_BOARD', ch.dateofbirth, ch.firstname .. ' ' .. ch.lastname, 'Bank: ' .. ch.bank, 'Cash: ' .. ch.money , 0, 0, 116)
                end
                if stuff.characters[stuff.current] == false then
                    LongHelpText('~INPUT_CELLPHONE_RIGHT~ Next character\n~INPUT_FRONTEND_RDOWN~ Create character', false, -1)
                else
                    local name = ('%s %s'):format(stuff.characters[stuff.current].firstname, stuff.characters[stuff.current].lastname)
                    LongHelpText(('~INPUT_CELLPHONE_RIGHT~ Next character\n~INPUT_FRONTEND_RDOWN~ Play as ~h~%s\n~INPUT_FRONTEND_RRIGHT~ ~h~Remove ~h~%s'):format(name, name), false, -1)
                end
                if IsDisabledControlJustReleased(0, 175) then
                    NextCharacter()
                elseif IsDisabledControlJustReleased(0, 191) then
                    if stuff.characters[stuff.current] == false then
                        stuff.choosing = false
                        DoScreenFadeOut(0)
                        TriggerServerEvent('kashactersS:CharacterChosen', stuff.current, false)
                    else
                        stuff.choosing = false
                        TriggerServerEvent('kashactersS:CharacterChosen', stuff.current, true)
                    end
                elseif IsDisabledControlJustReleased(0, 194) and stuff.characters[stuff.current] ~= false then
                    while true do
                        Wait(0)
                        local name = ('%s %s'):format(stuff.characters[stuff.current].firstname, stuff.characters[stuff.current].lastname)
                        LongHelpText(('Are you sure you want to remove ~h~%s~h~?\nPress ~INPUT_FRONTEND_RDOWN~ to remove ~h~%s~h~\nPress ~INPUT_FRONTEND_RRIGHT~ to cancel'):format(name, name), false, -1)
                        if IsDisabledControlJustReleased(0, 191) then
                            DoScreenFadeOut(1500)
                            while not IsScreenFadedOut() do Wait(0) end
                            for i = 1, #stuff.peds do
                                DeletePed(stuff.peds[i])
                            end
                            stuff.characters = {false, false, false, false}
                            for i = 1, #stuff.pedboards do
                                DeleteObject(stuff.pedboards[i])
                            end
                            DeleteObject(board)
                            DeleteObject(overlay)
                            stuff.pedboards = {}
                            Wait(250)
                            TriggerServerEvent("kashactersS:DeleteCharacter", stuff.current)
                            break
                        elseif IsDisabledControlJustReleased(0, 194) then
                            break
                        end
                    end
                end
            end
        end
    end)
end)

RegisterNetEvent('loaf_character:loadCharacters')
AddEventHandler('loaf_character:loadCharacters', function(characters, respawning)
    while not IsScreenFadedOut() do Wait(0) DoScreenFadeOut(0) end
    for i = 1, #stuff.spawnPositions do
        ClearAreaOfEverything(stuff.spawnPositions[i], 25.0, false, false, false, false)
        local modelHash = 1885233650
        RequestModel(modelHash)
        while not HasModelLoaded(modelHash) do Wait(0) end
        SetPlayerModel(PlayerId(), modelHash)
        SetPedDefaultComponentVariation(PlayerPedId())
        SetEntityVisible(PlayerPedId(), true, false)
        stuff.peds[i] = CreatePed(5, modelHash, stuff.spawnPositions[i], 270.0, false)
        SetEntityAsMissionEntity(stuff.peds[i], true, true)
        SetEntityInvincible(stuff.peds[i], true)
        SetPedHearingRange(stuff.peds[i], 0.0)
        SetPedSeeingRange(stuff.peds[i], 0.0)
        SetPedAlertness(stuff.peds[i], 0.0)
        SetBlockingOfNonTemporaryEvents(stuff.peds[i], true)
        SetPedCombatAttributes(stuff.peds[i], 46, true)
        SetPedFleeAttributes(stuff.peds[i], 0, 0)

        local dict = "mp_character_creation@customise@male_a"
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do Wait(0) end
        TaskPlayAnim(stuff.peds[i], dict, "drop_loop", 8.0, 8.0, -1, 14, 0, false, false, false)

        stuff.pedboards[i] = CreateObject(GetHashKey("prop_police_id_board"), GetEntityCoords(stuff.peds[i]), false, true, false)
        AttachEntityToEntity(stuff.pedboards[i], stuff.peds[i], GetPedBoneIndex(stuff.peds[i], 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0, 0, 0, 0, 2, 1)

        local overlay_model = GetHashKey("prop_police_id_text")
    end
    CreateBoard(stuff.peds[stuff.current])
    TaskPlayAnim(stuff.peds[stuff.current], "mp_character_creation@customise@male_a", "drop_outro", 8.0, 8.0, -1, 14, 0, false, false, false)
    for i = 1, #characters do
        local id = tonumber(characters[i].identifier:sub(5,5))
        stuff.characters[id] = characters[i]
        if characters[i].skin == nil then
            characters[i].skin = '{"skin":0,"sex":0,"torso_2":0,"beard_3":0,"complexion_2":0,"bracelets_1":-1,"chest_3":0,"glasses_1":0,"lipstick_1":0,"hair_1":0,"face":0,"bodyb_1":0,"blush_2":0,"decals_1":0,"chest_2":0,"eyebrows_1":0,"bproof_2":0,"hair_color_2":0,"chain_2":0,"beard_4":0,"lipstick_3":0,"makeup_4":0,"blemishes_1":0,"moles_2":0,"sun_1":0,"helmet_2":0,"tshirt_2":0,"eyebrows_3":0,"lipstick_2":0,"blush_1":0,"moles_1":0,"torso_1":0,"eyebrows_2":0,"arms":0,"age_1":0,"eye_color":0,"hair_color_1":0,"complexion_1":0,"helmet_1":-1,"blemishes_2":0,"makeup_3":0,"lipstick_4":0,"ears_2":0,"bracelets_2":0,"shoes_1":0,"beard_2":0,"bodyb_2":0,"watches_1":-1,"pants_1":0,"arms_2":0,"makeup_1":0,"pants_2":0,"shoes_2":0,"tshirt_1":0,"bproof_1":0,"sun_2":0,"bags_1":0,"makeup_2":0,"age_2":0,"watches_2":0,"eyebrows_4":0,"glasses_2":0,"decals_2":0,"blush_3":0,"chain_1":0,"ears_1":-1,"chest_1":0,"beard_1":0,"mask_1":0,"mask_2":0,"bags_2":0,"hair_2":0}'
        end
        local skin = json.decode(characters[i].skin)
        if skin.sex == 1 then
            DeletePed(stuff.peds[id])
            local modelHash = GetHashKey('mp_f_freemode_01')
            RequestModel(modelHash)
            while not HasModelLoaded(modelHash) do Wait(0) end
            DeleteObject(stuff.pedboards[id])
            stuff.peds[id] = CreatePed(5, modelHash, stuff.spawnPositions[id], 270.0, false)
            stuff.pedboards[id] = CreateObject(GetHashKey("prop_police_id_board"), GetEntityCoords(stuff.peds[id]), false, true, false)
            AttachEntityToEntity(stuff.pedboards[id], stuff.peds[id], GetPedBoneIndex(stuff.peds[id], 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0, 0, 0, 0, 2, 1)
            local dict = "mp_character_creation@customise@male_a"
            RequestAnimDict(dict)
            while not HasAnimDictLoaded(dict) do Wait(0) end
            TaskPlayAnim(stuff.peds[id], dict, "drop_loop", 8.0, 8.0, -1, 14, 0, false, false, false)
        end
        TriggerEvent('skinchanger:loadPedSkin', stuff.peds[id], skin)
    end
    local cam = {}
    if not respawning then
        cam = CreateCam("DEFAULT_SCRIPTED_Camera", 1)
        SetCamCoord(cam, 415.54, -998.27, -98.5)
        RenderScriptCams(1, 0, 0, 1, 1)
        PointCamAtCoord(cam, 408.89, -998.42, -99.0)
    end
    local timer = GetGameTimer() + 1500
    while timer >= GetGameTimer() do SetEntityCoords(PlayerPedId(), 415.52, -998.38, -99.4) Wait(50) end
    DoScreenFadeIn(1500)
    if not respawning then
        PlaySoundFrontend(-1, "Zoom", "MP_CCTV_SOUNDSET", 1)
        while GetCamFov(cam) >= 27.0 do
            Wait(0)
            SetCamFov(cam, GetCamFov(cam)-0.05)
        end
        StopSound()
    end
end)

RegisterNetEvent('kashactersC:SpawnCharacter')
AddEventHandler('kashactersC:SpawnCharacter', function(spawn)
    RenderScriptCams(0, 0, 1, 1, 1)
    ClearTimecycleModifier("scanline_cam_cheap")
    SetFocusEntity(GetPlayerPed(PlayerId()))
    DoScreenFadeOut(0)
    SetEntityVisible(PlayerPedId(), true, false)
    TriggerServerEvent('es:firstJoinProper')
    TriggerEvent('es:allowedToSpawn')
    SetEntityCoords(PlayerPedId(), spawn.x, spawn.y, spawn.z)
    FreezeEntityPosition(PlayerPedId(), false)
    for i = 1, #stuff.peds do
        DeletePed(stuff.peds[i])
    end
    ESX = nil
    while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Wait(0)
    end
    while not NetworkIsSessionStarted() or ESX.GetPlayerData().job == nil do Wait(0) end
    DoScreenFadeIn(1500)
end)