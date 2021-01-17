FXCore = nil

TriggerEvent(Config.Core, function(obj) FXCore = obj end)


--RegisterCommand( 'comserv', 'admin', function(source, args, user)
--	if args[1] and GetPlayerName(args[1]) ~= nil and tonumber(args[2]) then
--		TriggerEvent('esx_communityservice:sendToCommunityService', tonumber(args[1]), tonumber(args[2]))
--	else
--		TriggerClientEvent('chat:addMessage', source, { args = { _U('system_msn'), _U('invalid_player_id_or_actions') } } )
--	end
--end, function(source, args, user)
--	TriggerClientEvent('chat:addMessage', source, { args = { _U('system_msn'), _U('insufficient_permissions') } })
--end, {help = _U('give_player_community'), params = {{name = "id", help = _U('target_id')}, {name = "actions", help = _U('action_count_suggested')}}})
--_U('system_msn')
FXCore.Commands.Add("comserv", _U('give_player_community'), {{name = "id", help = _U('target_id')}, {name = "actions", help = _U('action_count_suggested')}}, false, function(source, args, user)
	local Player = FXCore.Functions.GetPlayer(source)
	if args[1] and GetPlayerName(args[1]) ~= nil and tonumber(args[2]) then
		TriggerEvent('esx_communityservice:sendToCommunityService', tonumber(args[1]), tonumber(args[2]))
	else
		TriggerClientEvent('chat:addMessage', source, { args = { _U('system_msn'), _U('invalid_player_id_or_actions') } } )
	end
end,"admin")

FXCore.Commands.Add("endcomserv", "End Community Service", { { name = "id", help = _U('target_id') } }, false, function(source, args, user)
	local Player = FXCore.Functions.GetPlayer(source)
	if args[1] then
		if args[1] ~= nil then
		else
			TriggerClientEvent('chat:addMessage', source, { args = { _U('system_msn'), _U('invalid_player_id') } })
		end
	else
		print("SIP")
		TriggerEvent('esx_communityservice:endCommunityServiceCommand', source)
	end
end, "admin")


--TriggerEvent('es:addGroupCommand', 'endcomserv', 'admin', function(source, args, user)
--	if args[1] then
--		if GetPlayerName(args[1]) ~= nil then
--			TriggerEvent('esx_communityservice:endCommunityServiceCommand', tonumber(args[1]))
--		else
--			TriggerClientEvent('chat:addMessage', source, { args = { _U('system_msn'), _U('invalid_player_id')  } } )
--		end
--	else
--		TriggerEvent('esx_communityservice:endCommunityServiceCommand', source)
--	end
--end, function(source, args, user)
--	TriggerClientEvent('chat:addMessage', source, { args = { _U('system_msn'), _U('insufficient_permissions') } })
--end, {help = _U('unjail_people'), params = {{name = "id", help = _U('target_id')}}})
RegisterServerEvent("fx-clothes:loadPlayerSkinjerico") --DO NOT CHANGE THIS
AddEventHandler('fx-clothes:loadPlayerSkinjerico', function(source)
    local src = source
    local Player = FXCore.Functions.GetPlayer(src)
    FXCore.Functions.ExecuteSql(false, "SELECT * FROM `playerskins` WHERE `citizenid` = '"..Player.PlayerData.citizenid.."' AND `active` = 1", function(result)
        if result[1] ~= nil then
            TriggerClientEvent("fx-clothes:loadSkin", src, false, result[1].model, result[1].skin) --CHANGE THIS
        else
            TriggerClientEvent("fx-clothes:loadSkin", src, true) ---CHANGE THIS
        end
    end)
end)




RegisterServerEvent('esx_communityservice:endCommunityServiceCommand')
AddEventHandler('esx_communityservice:endCommunityServiceCommand', function(source)
	if source ~= nil then
		TriggerEvent("fx-clothes:loadPlayerSkinjerico",source) --DO NOT TOUCH THIS
		releaseFromCommunityService(source)

	end
end)

-- unjail after time served
RegisterServerEvent('esx_communityservice:finishCommunityService')
AddEventHandler('esx_communityservice:finishCommunityService', function()
	releaseFromCommunityService(source)
end)





RegisterServerEvent('esx_communityservice:completeService')
AddEventHandler('esx_communityservice:completeService', function()

	local _source = source
	local identifier = FXCore.Functions.GetPlayer(_source).PlayerData.citizenid
	print(identifier)

		exports['ghmattimysql']:execute('SELECT * FROM communityservice WHERE identifier = @identifier', {
		['@identifier'] = identifier
	}, function(result)

		if result[1] then
				exports['ghmattimysql']:execute('UPDATE communityservice SET actions_remaining = actions_remaining - 1 WHERE identifier = @identifier', {
				['@identifier'] = identifier
			})
		else
			print ("ESX_CommunityService :: Problem matching player identifier in database to reduce actions.")
		end
	end)
end)




RegisterServerEvent('esx_communityservice:extendService')
AddEventHandler('esx_communityservice:extendService', function()

	local _source = source
	local identifier = FXCore.Functions.GetPlayer(_source).PlayerData.citizenid

		exports['ghmattimysql']:execute('SELECT * FROM communityservice WHERE identifier = @identifier', {
		['@identifier'] = identifier
	}, function(result)

		if result[1] then
				exports['ghmattimysql']:execute('UPDATE communityservice SET actions_remaining = actions_remaining + @extension_value WHERE identifier = @identifier', {
				['@identifier'] = identifier,
				['@extension_value'] = Config.ServiceExtensionOnEscape
			})
		else
			print ("ESX_CommunityService :: Problem matching player identifier in database to reduce actions.")
		end
	end)
end)






RegisterServerEvent('esx_communityservice:sendToCommunityService')
AddEventHandler('esx_communityservice:sendToCommunityService', function(target, actions_count)
print("llego")
	local identifier = FXCore.Functions.GetPlayer(target).PlayerData.citizenid
	print("llego1")
		exports['ghmattimysql']:execute('SELECT * FROM communityservice WHERE identifier = @identifier', {
		['@identifier'] = identifier
	}, function(result)
		if result[1] then
				exports['ghmattimysql']:execute('UPDATE communityservice SET actions_remaining = @actions_remaining WHERE identifier = @identifier', {
				['@identifier'] = identifier,
				['@actions_remaining'] = actions_count
			})
		else
				exports['ghmattimysql']:execute('INSERT INTO communityservice (identifier, actions_remaining) VALUES (@identifier, @actions_remaining)', {
				['@identifier'] = identifier,
				['@actions_remaining'] = actions_count
			})
		end
	end)
	print("llego2")
	TriggerClientEvent('chat:addMessage', -1, { args = { _U('judge'), _U('comserv_msg', GetPlayerName(target), actions_count) }, color = { 147, 196, 109 } })
	--TriggerClientEvent('esx_policejob:unrestrain', target)
	TriggerClientEvent('esx_communityservice:inCommunityService', target, actions_count)
end)


















RegisterServerEvent('esx_communityservice:checkIfSentenced')
AddEventHandler('esx_communityservice:checkIfSentenced', function()
	local _source = source -- cannot parse source to client trigger for some weird reason
	local identifier = FXCore.Functions.GetPlayer(_source).PlayerData.citizenid -- get steam identifier

		exports['ghmattimysql']:execute('SELECT * FROM communityservice WHERE identifier = @identifier', {
		['@identifier'] = identifier
	}, function(result)
		if result[1] ~= nil and result[1].actions_remaining > 0 then
			--TriggerClientEvent('chat:addMessage', -1, { args = { _U('judge'), _U('jailed_msg', GetPlayerName(_source), ESX.Math.Round(result[1].jail_time / 60)) }, color = { 147, 196, 109 } })
			TriggerClientEvent('esx_communityservice:inCommunityService', _source, tonumber(result[1].actions_remaining))
		end
	end)
end)







function releaseFromCommunityService(target)

	local identifier = FXCore.Functions.GetPlayer(target).PlayerData.citizenid
		exports['ghmattimysql']:execute('SELECT * FROM communityservice WHERE identifier = @identifier', {
		['@identifier'] = identifier
	}, function(result)
		if result[1] then
				exports['ghmattimysql']:execute('DELETE from communityservice WHERE identifier = @identifier', {
				['@identifier'] = identifier
			})

			TriggerClientEvent('chat:addMessage', -1, { args = { _U('judge'), _U('comserv_finished', GetPlayerName(target)) }, color = { 147, 196, 109 } })
		end
	end)

	TriggerClientEvent('esx_communityservice:finishCommunityService', target)
end
