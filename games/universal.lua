local loadstring = function(...)
	local res, err = loadstring(...)
	if err and vape then
		vape:CreateNotification('Vape', 'Failed to load : '..err, 30, 'alert')
	end
	return res
end

local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end

local function downloadFile(path, func)
	if not isfile(path) then
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/pascaldemon1337/VapeV4ForRoblox/'..readfile('newvape/profiles/commit.txt')..'/'..select(1, path:gsub('newvape/', '')), true)
		end)
		if not suc or res == '404: Not Found' then
			error(res)
		end
		if path:find('.lua') then
			res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n'..res
		end
		writefile(path, res)
	end
	return (func or readfile)(path)
end

local run = function(func)
	func()
end

local queue_on_teleport = queue_on_teleport or function() end
local cloneref = cloneref or function(obj)
	return obj
end

local playersService = cloneref(game:GetService('Players'))
local replicatedStorage = cloneref(game:GetService('ReplicatedStorage'))
local runService = cloneref(game:GetService('RunService'))
local inputService = cloneref(game:GetService('UserInputService'))
local tweenService = cloneref(game:GetService('TweenService'))
local lightingService = cloneref(game:GetService('Lighting'))
local marketplaceService = cloneref(game:GetService('MarketplaceService'))
local teleportService = cloneref(game:GetService('TeleportService'))
local httpService = cloneref(game:GetService('HttpService'))
local guiService = cloneref(game:GetService('GuiService'))
local groupService = cloneref(game:GetService('GroupService'))
local textChatService = cloneref(game:GetService('TextChatService'))
local contextService = cloneref(game:GetService('ContextActionService'))
local coreGui = cloneref(game:GetService('CoreGui'))

local isnetworkowner = identifyexecutor and table.find({'AWP', 'Nihon'}, ({identifyexecutor()})[1]) and isnetworkowner or function()
	return true
end

local gameCamera = workspace.CurrentCamera or workspace:FindFirstChildWhichIsA('Camera')
local lplr = playersService.LocalPlayer
local assetfunction = getcustomasset
local vape = shared.vape

local function isFriend(plr)
	if vape.Categories.Friends.Options['Use friends'].Enabled then
		return table.find(vape.Categories.Friends.ListEnabled, plr.Name) and true
	end
end

local function isTarget(plr)
	return table.find(vape.Categories.Targets.ListEnabled, plr.Name) and true
end

local hash = loadstring(downloadFile('newvape/libraries/hash.lua'), 'hash')()
local prediction = loadstring(downloadFile('newvape/libraries/prediction.lua'), 'prediction')()
local entitylib = loadstring(downloadFile('newvape/libraries/entity.lua'), 'entitylibrary')()

vape.Libraries.entity = entitylib
vape.Libraries.prediction = prediction
vape.Libraries.hash = hash

run(function()
	entitylib.getUpdateConnections = function(ent)
		local hum = ent.Humanoid
		return {
			hum:GetPropertyChangedSignal('Health'),
			hum:GetPropertyChangedSignal('MaxHealth'),
			{
				Connect = function()
					ent.Friend = ent.Player and isFriend(ent.Player) or nil
					ent.Target = ent.Player and isTarget(ent.Player) or nil
					return {Disconnect = function() end}
				end
			}
		}
	end

	entitylib.targetCheck = function(ent)
		if ent.TeamCheck then return ent:TeamCheck() end
		if ent.NPC then return true end
		if isFriend(ent.Player) then return false end
		if vape.Categories.Main.Options['Teams by server'].Enabled then
			if not lplr.Team then return true end
			if not ent.Player.Team then return true end
			if ent.Player.Team ~= lplr.Team then return true end
			return #ent.Player.Team:GetPlayers() == #playersService:GetPlayers()
		end
		return true
	end

	entitylib.getEntityColor = function(ent)
		ent = ent.Player
		if not (ent and vape.Categories.Main.Options['Use team color'].Enabled) then return end
		if isFriend(ent, true) then
			return Color3.fromHSV(vape.Categories.Friends.Options['Friends color'].Hue, vape.Categories.Friends.Options['Friends color'].Sat, vape.Categories.Friends.Options['Friends color'].Value)
		end
		return tostring(ent.TeamColor) ~= 'White' and ent.TeamColor.Color or nil
	end

	if vape and vape.Clean then
		vape:Clean(function()
			entitylib.kill()
			entitylib = nil
		end)
	end

	if vape and vape.Clean then
		vape:Clean(vape.Categories.Friends.Update.Event:Connect(function() entitylib.refresh() end))
	end

	if vape and vape.Clean then
		vape:Clean(vape.Categories.Targets.Update.Event:Connect(function() entitylib.refresh() end))
	end

	if vape and vape.Clean then
		vape:Clean(workspace:GetPropertyChangedSignal('CurrentCamera'):Connect(function()
			gameCamera = workspace.CurrentCamera or workspace:FindFirstChildWhichIsA('Camera')
		end))
	end
end)

entitylib.start()

vape.Libraries.sessioninfo = {
	Objects = {},
	AddItem = function(self, name, startvalue)
		self.Objects[name] = {Value = startvalue or 0}
		return {
			Increment = function(_, val)
				self.Objects[name].Value += (val or 1)
			end
		}
	end
}

vape.Libraries.sessioninfo:AddItem('Time Played', os.clock())

local tpSwitch = false
if vape and vape.Clean then
	vape:Clean(lplr.OnTeleport:Connect(function()
		if not tpSwitch then
			tpSwitch = true
			queue_on_teleport("shared.vapeserverhoplist = ''\nshared.vapeserverhopprevious = '"..game.JobId.."'")
		end
	end))
end
