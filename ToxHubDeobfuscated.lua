local workspace = cloneref(workspace) or workspace
local RunService = cloneref(game:GetService("RunService")) or game:GetService("RunService")
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage")) or game:GetService("ReplicatedStorage")
local Players = cloneref(game:GetService("Players")) or game:GetService("Players")
local InsertService = cloneref(game:GetService("InsertService")) or game:GetService("InsertService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local ReGui = loadstring(game:HttpGet('https://raw.githubusercontent.com/depthso/Dear-ReGui/refs/heads/main/ReGui.lua'))()
local PrefabsId = "rbxassetid://" .. ReGui.PrefabsId

ReGui:Init({
	Prefabs = InsertService:LoadLocalAsset(PrefabsId)
})

local TabsWindow = ReGui:TabsWindow({
	Title = "ToxHub",
	Size = UDim2.fromOffset(400, 200),
	NoClose = false
})

local function Notif(Textt)
	local notif = ReGui:PopupModal({
		Title = "ToxHub",
		NoClose = false,
	})
	
	notif:Label({
		Text = Textt,
		TextWrapped = true
	})

	notif:Button({
		Text = "Okay",
		Callback = function()
			notif:ClosePopup()
		end,
	})
end

local scpFolder = workspace.scpFolder

local GunConfigurations = ReplicatedStorage.Framework.Assets.GunSystem.Config.Default

local Weapon_Functions = {}
Weapon_Functions = {
	Get_Weapon = function()
		local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		
		local PurchasableWeapons = {"UMP", "SCAR-L", "P90"} -- Cheapest to most expensive

		for _,Weapon in pairs(Character:GetChildren()) do
			if Weapon:IsA("Tool") and GunConfigurations:FindFirstChild(Weapon.Name) then
				return Weapon
			end
		end

		for _,Weapon in pairs(LocalPlayer:FindFirstChildOfClass("Backpack"):GetChildren()) do
			if Weapon:IsA("Tool") and GunConfigurations:FindFirstChild(Weapon.Name) then
				return Weapon
			end
		end

		local PurchasedWeapon

		for _,ShopGun in ipairs(PurchasableWeapons) do
			if LocalPlayer.PlayerGui.Panel.List.Shop.Holder.Currency[ShopGun].Stock.TextTransparency == 1 then
				PurchasedWeapon = ShopGun
				break
			end
		end

		if LocalPlayer.Cash.Value < tonumber(string.match(LocalPlayer.PlayerGui.Panel.List.Shop.Holder.Currency[PurchasedWeapon].Price.Text, "%d+")) then Notif("Not enough money") return end

		local args = {
			[1] = "Buy",
			[2] = {
				[1] = PurchasedWeapon
			}
		}
		ReplicatedStorage.Shop:InvokeServer(unpack(args))
		firetouchinterest(workspace.Belt.Orders:WaitForChild(LocalPlayer.Name):WaitForChild("boxinterior"), Character["HumanoidRootPart"], 0)
		return LocalPlayer.Backpack:WaitForChild(PurchasedWeapon)
	end;

	Kill_Player = function(Target)
		local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		
		if not Target.Character or Target == LocalPlayer or LocalPlayer.Team == Target.Team then Notif("Issue regarding Target") return end

		local Weapon = Weapon_Functions.Get_Weapon()
		if not Weapon then return end

		local TargetCharacter = Target.Character

		repeat
			Weapon.Parent = Character

			while not Weapon:GetAttribute("Ammo") do RunService.RenderStepped:Wait() end
			if Weapon:GetAttribute("Ammo") <= 0 then
				ReplicatedStorage.Framework.Assets.GunSystem.Remotes.WeaponEvent:InvokeServer("Reload")
			end

			local args = {{
				{Hit = TargetCharacter.HumanoidRootPart, Position = TargetCharacter:GetPivot()}
			}}

			ReplicatedStorage.Framework.Assets.GunSystem.Remotes.BulletEvent:FireServer(unpack(args))

			RunService.RenderStepped:Wait()
		until TargetCharacter.Humanoid.Health <= 0 or not TargetCharacter or not Character

		Weapon.Parent = LocalPlayer.Backpack
	end;
}

local SCP_Functions = {}

SCP_Functions.SCP_409 = {}
SCP_Functions.SCP_409 = {
	Get_Infected = function()
		local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		
		if Character:FindFirstChild("scp323_model") or Character:FindFirstChild("SCP-035Hat") then Notif("Cannot be another SCP") return end
		
		if Character:FindFirstChild("409") then return end

		local SCP409_Hitbox = workspace.scpFolder["SCP-409"].Hitbox

		local OriginalPosition = Character:GetPivot()
		repeat
			Character:PivotTo(SCP409_Hitbox.CFrame)
			firetouchinterest(SCP409_Hitbox, Character["HumanoidRootPart"], 1)
			firetouchinterest(SCP409_Hitbox, Character["HumanoidRootPart"], 0)
			RunService.RenderStepped:Wait()
		until Character:FindFirstChild("409")
		Character:PivotTo(OriginalPosition)
	end,

	Kill_Player = function(Target)
		local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		
		if not Character:FindFirstChild("409") then SCP_Functions.SCP_409.Get_Infected(); Character:WaitForChild("409") end
		if not Target.Character or Target == LocalPlayer then Notif("Issue regarding Target") return end

		local TargetCharacter = Target.Character

		local OriginalPosition = Character:GetPivot()
		repeat
			Character["HumanoidRootPart"].CFrame = Target.Character["HumanoidRootPart"].CFrame
			RunService.RenderStepped:Wait()
		until Target.Character:FindFirstChild("409")
		Character:PivotTo(OriginalPosition)
	end,
}

SCP_Functions.SCP_323 = {}
SCP_Functions.SCP_323 = {
	Get_SCP_323_Head = function()
		local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		
		for _,Player in pairs(Players:GetPlayers()) do
			if not Player.Character then return end
			if Player.Character:FindFirstChild("SCP-323") or Player.Character:FindFirstChild("scp323_model") then
				Notif("SCP unavailable")
				return
			end
		end

		local SCP323_Head = workspace.scp323.Transparency == 0 and workspace.scp323 or workspace["SCP-323"]:FindFirstChildOfClass("UnionOperation")
		local SCP323_Head_ClickDetector

		if not SCP323_Head then return end

		if SCP323_Head == workspace.scp323 then
			SCP323_Head_ClickDetector = SCP323_Head:FindFirstChildOfClass("ClickDetector")
		else
			SCP323_Head_ClickDetector = SCP323_Head:FindFirstChildOfClass("ClickDetector")
		end

		local CooldownGiveUp = false
		task.spawn(function()
			task.wait(.3)
			if Character:FindFirstChild("SCP-323") then return end
			CooldownGiveUp = true
			Notif("SCP unavailable")
		end)

		local OriginalPosition = Character:GetPivot()
		repeat
			Character:PivotTo(SCP323_Head.CFrame)
			fireclickdetector(SCP323_Head_ClickDetector)
			RunService.RenderStepped:Wait()
		until Character:FindFirstChild("SCP-323") or CooldownGiveUp
		Character:PivotTo(OriginalPosition)
	end,

	Morph_To_SCP_323X = function()
		local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		
		if not Character:FindFirstChild("scp323_model") or Character["scp323_model"]["Torso"]:FindFirstChildOfClass("ParticleEmitter") then Notif("You have to be SCP-323") return end

		local PortalStuff = scpFolder.Solis.Part

		local OriginalPosition = Character:GetPivot()
		Character:PivotTo(PortalStuff.CFrame)
		RunService.RenderStepped:Wait()
		firetouchinterest(PortalStuff, Character["HumanoidRootPart"], 0)
		repeat RunService.RenderStepped:Wait() until Character["scp323_model"]["Torso"]:FindFirstChildOfClass("ParticleEmitter") or
			Character:PivotTo(OriginalPosition)
	end,

	Kill_Player = function(Target)
		local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		
		if not Character:FindFirstChild("scp323_model") then Notif("You have to be SCP-323") return end
		if not Target.Character or Target == LocalPlayer then Notif("Issue regarding Target") return end

		local TargetCharacter = Target.Character

		local OriginalPosition = Character:GetPivot()
		repeat
			Character:PivotTo(TargetCharacter:GetPivot() * CFrame.new(0, -14, 0))
			local args = {
				[1] = TargetCharacter,
				[2] = TargetCharacter["HumanoidRootPart"]
			}
			workspace.scp323.click323.script323.damageEvent:FireServer(unpack(args))
			RunService.RenderStepped:Wait()
		until TargetCharacter.Humanoid.Health <= 0
		Character:PivotTo(OriginalPosition)
	end,
}

SCP_Functions.SCP_035 = {
	Morph_To_SCP_035 = function()
		local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

		if workspace.scpFolder["SCP-035"].Other["SCP-035"].Handle.Transparency == 1 then Notif("SCP unavailable") return end

		local OriginPos = Character["HumanoidRootPart"].Position

		repeat
			Character["HumanoidRootPart"].CFrame = CFrame.new(workspace.scpFolder["SCP-035"].HelpMe.Position)
			wait()
			fireproximityprompt(workspace.scpFolder["SCP-035"].Main.Prompt)
		until Character:FindFirstChild("SCP-035Hat")
		Character["HumanoidRootPart"].CFrame = CFrame.new(OriginPos)
	end,
}

local PlayerTab = TabsWindow:CreateTab({Name = "Player"})
local SCPsTab = TabsWindow:CreateTab({Name = "SCPs"})

-- Players Tab

local PlayerTabTargetTextBox = PlayerTab:InputText({
	Label = "Target Username";
	Value = Players.LocalPlayer.Name
})

PlayerTab:Separator()

local PlayerTabKillMethod = PlayerTab:Combo({
	Label = "Kill Method",
	Selected = "Gun Kill",
	Items = {
		"Gun Kill",
	}
})

local PlayerTabKillButton = PlayerTab:Button({
	Text = "Kill Target",
	Callback = function()
		if PlayerTabKillMethod.Selected == "Gun Kill" then
			Weapon_Functions.Kill_Player( Players[PlayerTabTargetTextBox.Value] )
		end
	end
})

PlayerTab:Separator()
PlayerTab:Label({Text = "More Kill Methods in the Player Header of the SCPs Tab."})

-- SCPs Tab

local SCPsTabPlayerHeader = SCPsTab:CollapsingHeader({Title = "Player"})

local SCPsTabTargetTextBox = SCPsTabPlayerHeader:InputText({
	Label = "Target Username";
	Value = Players.LocalPlayer.Name
})

SCPsTabPlayerHeader:Separator()

local SCPsTabKillMethod = SCPsTabPlayerHeader:Combo({
	Label = "Kill Method",
	Selected = "SCP-409 Kill",
	Items = {
		"SCP-409 Kill",
		"SCP-323 Kill"
	}
})

local SCPsTabKillButton = SCPsTabPlayerHeader:Button({
	Text = "Kill Target",
	Callback = function()
		if SCPsTabKillMethod.Selected == "SCP-409 Kill" then
			SCP_Functions.SCP_409.Kill_Player( Players[SCPsTabTargetTextBox.Value] )
		elseif SCPsTabKillMethod.Selected == "SCP-323 Kill" then
			SCP_Functions.SCP_323.Kill_Player( Players[SCPsTabTargetTextBox.Value] )
			end
	end
})

local SCPsTabMorphsHeader = SCPsTab:CollapsingHeader({Title = "Morphs"})

local SCPsTabMorphSelector = SCPsTabMorphsHeader:Combo({
	Label = "SCP to Morph into",
	Selected = "SCP-409",
	Items = {
		"SCP-409",
		"SCP-035",
		"SCP-323",
	}
})

SCPsTabMorphButton = SCPsTabMorphsHeader:Button({
	Text = "Morph into Selected SCP",
	Callback = function()
		if SCPsTabMorphSelector.Selected == "SCP-409" then
			SCP_Functions.SCP_409.Get_Infected()
		elseif SCPsTabMorphSelector.Selected == "SCP-323" then
			SCP_Functions.SCP_323.Get_SCP_323_Head()
		elseif SCPsTabMorphSelector.Selected == "SCP-035" then
			SCP_Functions.SCP_035.Morph_To_SCP_035()
		end
	end,
})

SCPsTabMorphsHeader:Separator({Text = "SCP-323"})
local SCPsTabMorphHeaderSCP323TreeNodeMorph323XButton = SCPsTabMorphsHeader:Button({
	Text = "Morph into X Variant",
	Callback = function()
		SCP_Functions.SCP_323.Morph_To_SCP_323X()
	end,
})

local BreachesHeader = SCPsTab:CollapsingHeader({Title = "Breaches"})

local BreachesHeaderSelector = BreachesHeader:Combo({
	Label = "SCP to Breach",
	Selected = "SCP-096",
	Items = {
		"SCP-096",
		"SCP-076"
	}
})

local BreachesBreachButton = BreachesHeader:Button({
	Text = "Breach",
	Callback = function()
		
		local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		
		if BreachesHeaderSelector.Selected == "SCP-096" then
			
			local Gun = Weapon_Functions.Get_Weapon()
			if not Gun then return end
			
			Gun.Parent = Character
			local args = {
				[1] = {
					[1] = {
						["Hit"] = workspace.scpFolder["SCP-096"].Torso,
					}
				}
			}
			ReplicatedStorage.Framework.Assets.GunSystem.Remotes.BulletEvent:FireServer(unpack(args))
			wait()
			Gun.Parent = LocalPlayer.Backpack
			wait()
			if workspace.scpFolder["SCP-096"]:GetAttribute("State") ~= "Panicing" then
				if workspace["SCP-096_Photo"].Part.Transparency == 1 then
					Notif("Could not find a way to trigger SCP-096")
					return
				end
				local OriginalPosition = Character:WaitForChild("HumanoidRootPart").Position
				Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(workspace["SCP-096_Photo"].Part.Position)
				wait(.2)
				fireproximityprompt(workspace["SCP-096_Photo"].Part:FindFirstChildOfClass("ProximityPrompt"))
				task.wait()
				Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(OriginalPosition)
				local Picture = LocalPlayer.Backpack:WaitForChild("Picture")
				Picture.Parent = Character
				task.wait()
				Picture.Parent = LocalPlayer.Backpack
			end
			
		elseif BreachesHeaderSelector.Selected == "SCP-076" then
			
			local RespawnTime = 0
			for _ = 1, 3 do
				repeat task.wait()

					local root = Character:WaitForChild("HumanoidRootPart")
					local prompt = workspace:WaitForChild("Coffin076"):WaitForChild("Main"):FindFirstChild("ProximityPrompt")
					if prompt then
						root.CFrame = prompt.Parent.CFrame fireproximityprompt(prompt)
					end

				until Character:FindFirstChild("Humanoid") and Character.Humanoid.Health <= 0

				Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
				task.wait(RespawnTime)
				ReplicatedStorage:WaitForChild("RespawnFunction"):InvokeServer()
				RespawnTime += 1
			end
			task.delay(2, function()
				ReplicatedStorage:WaitForChild("RespawnFunction"):InvokeServer()
			end)
			
		end
	end
})

local MiscHeader = SCPsTab:CollapsingHeader({Title = "Miscellaneous"})

MiscHeader:Separator({Text = "SCP-1162"})
MiscHeader:Button({
	Text = "Get Random Tool",
	Callback = function()
		local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

		local OriginPos = Character["HumanoidRootPart"].Position
		local OriginWS = Character["Humanoid"].WalkSpeed

		Character["Humanoid"]:UnequipTools()
		fireclickdetector(workspace["Tool Givers"]["Coffee Givers"]["Secondary VA Coffee"].ClickDetector)
		LocalPlayer.Backpack:waitForChild("Coffee").Parent = Character
		Character["HumanoidRootPart"].CFrame = CFrame.new(scpFolder["SCP-1162"].Main.Position) * CFrame.new(2, 0, 0)
		Character["Humanoid"].WalkSpeed = 0
		scpFolder["SCP-1162"].Main.Prompt.RequiresLineOfSight = false
		workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, workspace.CurrentCamera.CFrame.Position + Vector3.new(-1, 0, 0))
		wait()
		scpFolder["SCP-1162"].Main.Prompt:InputHoldBegin()
		wait(1 + wait())
		scpFolder["SCP-1162"].Main.Prompt:InputHoldEnd()
		Character["Humanoid"].WalkSpeed = OriginWS
		Character["HumanoidRootPart"].CFrame = CFrame.new(OriginPos)
		scpFolder["SCP-1162"].Main.Prompt.RequiresLineOfSight = true
	end,
})
