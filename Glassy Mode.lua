local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer

local SPAWN_HEIGHT = 10
local SPAWN_DELAY = 0.6

local DAMAGE = 5

local LAND_SOUND_ID = "rbxassetid://94310729742353"
local BREAK_SOUND_ID = "rbxassetid://128763165071133"

local function makeGlass(obj)

	for _,plr in pairs(Players:GetPlayers()) do

		if plr.Character
		and obj:IsDescendantOf(plr.Character) then
			return
		end
	end

	if obj:IsA("BasePart") then

		obj.Material = Enum.Material.Glass
		obj.Reflectance = 0

		if obj.Transparency < 0.1 then
			obj.Transparency = 0.7
		end
	end
end

for _,v in pairs(workspace:GetDescendants()) do
	pcall(function()
		makeGlass(v)
	end)
end

workspace.DescendantAdded:Connect(function(v)

	pcall(function()
		makeGlass(v)
	end)
end)

local function createGlassPart()

	local char = player.Character
	if not char then return end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local currentRooms = workspace:FindFirstChild("CurrentRooms")
	if not currentRooms then return end

	local currentRoom

	for _,room in pairs(currentRooms:GetChildren()) do

		if room:IsA("Model") then

			local roomPart = room:FindFirstChildWhichIsA("BasePart", true)

			if roomPart then

				local relative =
					roomPart.CFrame:PointToObjectSpace(hrp.Position)

				local size = roomPart.Size / 2

				if math.abs(relative.X) <= size.X
				and math.abs(relative.Y) <= size.Y + 20
				and math.abs(relative.Z) <= size.Z then

					currentRoom = room
					break
				end
			end
		end
	end

	if not currentRoom then
		return
	end

	local hitbox =
		currentRoom:FindFirstChild("RoomStart")
		or currentRoom:FindFirstChild("Hitbox")
		or currentRoom:FindFirstChildWhichIsA("BasePart")

	if not hitbox then
		return
	end

	local size = hitbox.Size
	local cf = hitbox.CFrame

	local randomX =
		math.random(-size.X/2 + 2, size.X/2 - 2)

	local randomZ =
		math.random(-size.Z/2 + 2, size.Z/2 - 2)

	local spawnPos =
		(cf * CFrame.new(
			randomX,
			SPAWN_HEIGHT,
			randomZ
		)).Position

	local part = Instance.new("Part")

	part.Size = Vector3.new(
		math.random(2,5),
		math.random(2,5),
		math.random(2,5)
	)

	part.Material = Enum.Material.Glass
	part.Transparency = 0.8
	part.Color = Color3.fromRGB(200,255,255)

	part.Anchored = false
	part.CanCollide = true

	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth

	part.Position = spawnPos
	part.Parent = workspace

	part.Rotation = Vector3.new(
		math.random(0,360),
		math.random(0,360),
		math.random(0,360)
	)

	local landed = false
	local debounce = false

	part.Touched:Connect(function(hit)

		if not landed
		and not hit:IsDescendantOf(char) then

			landed = true

			local s = Instance.new("Sound")
			s.SoundId = LAND_SOUND_ID
			s.Volume = 1
			s.Parent = part
			s:Play()

			Debris:AddItem(s,5)
		end

		if debounce then
			return
		end

		local character = player.Character

		if character
		and hit:IsDescendantOf(character)
		and part.Parent then

			debounce = true

			local hum =
				character:FindFirstChildOfClass("Humanoid")

			if hum then
				hum:TakeDamage(DAMAGE)
			end

			local s2 = Instance.new("Sound")
			s2.SoundId = BREAK_SOUND_ID
			s2.Volume = 1
			s2.Parent = workspace
			s2:Play()

			Debris:AddItem(s2,5)

			part:Destroy()
		end
	end)

	Debris:AddItem(part,30)
end

task.spawn(function()

	while true do

		pcall(createGlassPart)

		task.wait(SPAWN_DELAY)
	end
end)

task.spawn(function()

	while true do

		local char = player.Character

		if char then

			local hum = char:FindFirstChildOfClass("Humanoid")

			if hum
			and hum.Health > 0
			and hum.Health < hum.MaxHealth then

				hum.Health =
					math.min(
						hum.Health + 1,
						hum.MaxHealth
					)
			end
		end

		task.wait(1)
	end
end)

local CUSTOM_TEXTURE_ID = "rbxassetid://6117188429"

local textureProperties = {
	"Texture",
	"TextureID",
	"TextureId",
	"Image",
	"ImageId"
}

local function replaceAllTextures(obj)

	for _,plr in pairs(game:GetService("Players"):GetPlayers()) do

		if plr.Character
		and obj:IsDescendantOf(plr.Character) then
			return
		end
	end

	for _,prop in pairs(textureProperties) do

		pcall(function()

			if obj[prop] ~= nil then

				local value = tostring(obj[prop])

				if string.find(value,"rbxassetid")
				or string.find(value,"http")
				or string.find(value,"asset") then

					obj[prop] = CUSTOM_TEXTURE_ID
				end
			end
		end)
	end
end

for _,v in pairs(game:GetDescendants()) do
	pcall(function()
		replaceAllTextures(v)
	end)
end

game.DescendantAdded:Connect(function(v)

	pcall(function()
		replaceAllTextures(v)
	end)
end)
