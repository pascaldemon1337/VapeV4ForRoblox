local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local OWNER_ID = 4211452992

local detectedUserIds = {}

local function createTag(player, label, color)
    local head = player.Character and player.Character:FindFirstChild("Head")
    if not head or head:FindFirstChild("VapeTag") then return end

    local tag = Instance.new("BillboardGui")
    tag.Name = "VapeTag"
    tag.Size = UDim2.new(0, 100, 0, 20)
    tag.StudsOffset = Vector3.new(0, 3, 0)
    tag.AlwaysOnTop = true
    tag.Adornee = head
    tag.ResetOnSpawn = false
    tag.Parent = head

    local labelObj = Instance.new("TextLabel")
    labelObj.Size = UDim2.new(1, 0, 1, 0)
    labelObj.BackgroundTransparency = 1
    labelObj.Text = label
    labelObj.TextColor3 = color
    labelObj.TextStrokeTransparency = 0
    labelObj.Font = Enum.Font.GothamBold
    labelObj.TextScaled = true
    labelObj.Parent = tag
end

local function tryTagPlayer(player)
    if table.find(detectedUserIds, player.UserId) then
        createTag(player, "VAPE USER", Color3.fromRGB(255, 255, 0))
    end
end

local function handlePlayer(player)
    player.CharacterAdded:Connect(function()
        tryTagPlayer(player)
    end)
    if player.Character then
        tryTagPlayer(player)
    end
end

if LocalPlayer.UserId == OWNER_ID then
    for _, p in ipairs(Players:GetPlayers()) do
        handlePlayer(p)
    end
    Players.PlayerAdded:Connect(handlePlayer)
end

local function autoDetectOwner()
    for _, player in ipairs(Players:GetPlayers()) do
        if player.UserId == OWNER_ID and player ~= LocalPlayer then
            local success, ownerName = pcall(function()
                return Players:GetNameFromUserIdAsync(OWNER_ID)
            end)

            if success and ownerName then
                StarterGui:SetCore("ChatMakeSystemMessage", {
                    Text = "/w " .. ownerName .. " detect me",
                    Color = Color3.new(0, 255, 0),
                    Font = Enum.Font.SourceSansBold,
                    TextSize = 18
                })
            end
        end
    end
end

if LocalPlayer.UserId ~= OWNER_ID then
    task.delay(1, autoDetectOwner)
    Players.PlayerAdded:Connect(function(player)
        if player.UserId == OWNER_ID then
            task.delay(1, autoDetectOwner)
        end
    end)
end

-- Owner listens for private messages saying "detect me"
TextChatService.OnIncomingMessage = function(message)
    if LocalPlayer.UserId ~= OWNER_ID then return end

    local source = message.TextSource
    if not source or message.Metadata ~= "TextChatMessageMetadata.Private" then return end

    local speaker = Players:GetPlayerByUserId(source.UserId)
    if not speaker or message.Text:lower() ~= "detect me" then return end

    if not table.find(detectedUserIds, speaker.UserId) then
        table.insert(detectedUserIds, speaker.UserId)
        tryTagPlayer(speaker)
    end
end

local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local LocalPlayer = Players.LocalPlayer
local OWNER_ID = 4211452992

-- Shared user list (cross-client)
shared.VapeUserIds = shared.VapeUserIds or {}
if not table.find(shared.VapeUserIds, LocalPlayer.UserId) then
    table.insert(shared.VapeUserIds, LocalPlayer.UserId)
local isfile = isfile or function(file)
	local suc, res = pcall(function() return readfile(file) end)
	return suc and res ~= nil and res ~= ''
end

local delfile = delfile or function(file)
	writefile(file, '')
end

local function downloadFile(path, func)
	if not isfile(path) then
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/Noveign/VapeV4ForRoblox/' .. readfile('newvape/profiles/commit.txt') .. '/' .. select(1, path:gsub('newvape/', '')), true)
		end)
		if not suc or res == '404: Not Found' then
			error(res)
		end
		if path:find('%.lua') then
			res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n' .. res
		end
		writefile(path, res)
	end
	return (func or readfile)(path)
end

local function wipeFolder(path)
	if not isfolder(path) then return end
	for _, file in listfiles(path) do
		if file:find('loader') then continue end
		if isfile(file) and select(1, readfile(file):find('--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.')) == 1 then
			delfile(file)
		end
	end
end

for _, folder in {'newvape', 'newvape/games', 'newvape/profiles', 'newvape/assets', 'newvape/libraries', 'newvape/guis'} do
	if not isfolder(folder) then makefolder(folder) end
end

if not shared.VapeDeveloper then
	local _, subbed = pcall(function()
		return game:HttpGet('https://github.com/Noveign/VapeV4ForRoblox')
	end)
	local commit = subbed:find('currentOid')
	commit = commit and subbed:sub(commit + 13, commit + 52) or nil
	commit = commit and #commit == 40 and commit or 'main'
	if commit == 'main' or (isfile('newvape/profiles/commit.txt') and readfile('newvape/profiles/commit.txt') or '') ~= commit then
		wipeFolder('newvape')
		wipeFolder('newvape/games')
		wipeFolder('newvape/guis')
		wipeFolder('newvape/libraries')
	end
	writefile('newvape/profiles/commit.txt', commit)
end

return loadstring(downloadFile('newvape/main.lua'))()
