local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- SETTINGS
local EXCLUDED_PLAYER_NAME = "YourUsernameHere" -- Replace with the username to exclude from prompts
local targetPromptName = "cKGrJsPWa`Rd(/'p?zFR@fG*K=jIMDRKd5'mb^K%iixC6]Ag=<%r7f%g<1=r"
local MAX_ACTIVATION_DISTANCE = 5000
local PROMPT_HOLD_DURATION = 0.3

-- Function to get full path of an object
local function getFullPath(instance)
	local path = instance.Name
	local current = instance

	local visited = {}  -- To prevent infinite loops with circular references
	while current.Parent and not visited[current] do
		visited[current] = true
		current = current.Parent
		path = current.Name .. "." .. path
	end

	return "" .. path
end


local function getProperties(instance)
	local properties = {}

	table.insert(properties, "Name: " .. instance.Name)
	table.insert(properties, "Class: " .. instance.ClassName)
	table.insert(properties, "Parent: " .. (instance.Parent and instance.Parent.Name or "None"))
	table.insert(properties, "Full Path: " .. getFullPath(instance))

	local success, result = pcall(function()
		local attrs = {}
		for name, value in pairs(instance:GetAttributes()) do
			table.insert(attrs, name .. ": " .. tostring(value))
		end
		return attrs
	end)

	if success and #result > 0 then
		table.insert(properties, "\nAttributes:")
		for _, attr in ipairs(result) do
			table.insert(properties, "  " .. attr)
		end
	end

	table.insert(properties, "\nProperties:")

	local propertyCount = 0
	local specificProperties = { -- Properties we want to display. Adjust as needed.
		"Size", "Position", "Orientation", "Color", "Transparency", "Material", 
		"Anchored", "CanCollide", "MeshId", "TextureId", "Reflectance", "Plasticity"
	}

	for _, propName in ipairs(specificProperties) do
		local success, propValue = pcall(function()
			return instance[propName]
		end)

		if success and propValue ~= nil then  -- Only add if the property exists and has a value
			local valueString = tostring(propValue)
			if typeof(propValue) == "Vector3" then
				valueString = string.format("(%f, %f, %f)", propValue.X, propValue.Y, propValue.Z)
			elseif typeof(propValue) == "Color3" then
				valueString = string.format("(%f, %f, %f)", propValue.R, propValue.G, propValue.B)
			elseif typeof(propValue) == "UDim2" then
				valueString = string.format("{X: %f, Offset: %i} {Y: %f, Offset: %i}", propValue.X.Scale, propValue.X.Offset, propValue.Y.Scale, propValue.Y.Offset)
			end
			table.insert(properties, "  " .. propName .. ": " .. valueString)
			propertyCount += 1
		end
	end

	if propertyCount == 0 then
		table.insert(properties, "  (No properties found)")
	end

	return table.concat(properties, "\n")
end



local function isPlayerBodyPart(item)
	for _, player in pairs(Players:GetPlayers()) do
		if player.Character and item:IsDescendantOf(player.Character) then
			return true
		end
	end
	return false
end


local function createGuiElement(elementType, properties)
	local element = Instance.new(elementType)

	for property, value in pairs(properties) do
		element[property] = value
	end

	if elementType == "Frame" or elementType == "TextButton" or elementType == "ScrollingFrame" then
		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(0, 6)
		uiCorner.Parent = element
	end

	return element
end


local function showCustomGui(player, item)
	local playerGui = player:FindFirstChild("PlayerGui")
	if not playerGui then return end

	local oldGui = playerGui:FindFirstChild("ItemInfoGui")
	if oldGui then oldGui:Destroy() end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ItemInfoGui"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui

	local mainFrame = createGuiElement("Frame", {
		Size = UDim2.new(0, 350, 0, 400),  -- Increased height
		Position = UDim2.new(0.5, -175, 0.5, -200),
		BackgroundColor3 = Color3.fromRGB(35, 40, 45),
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
	})
	mainFrame.Parent = screenGui

	local appearTween = TweenService:Create(mainFrame,
		TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{BackgroundTransparency = 0}
	)
	appearTween:Play()


	local topBar = createGuiElement("Frame", {
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundColor3 = Color3.fromRGB(45, 50, 60),
		BorderSizePixel = 0,
	})
	topBar.Parent = mainFrame

	local titleLabel = createGuiElement("TextLabel", {
		Size = UDim2.new(1, -50, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		BackgroundTransparency = 1,
		Text = "Object Inspector - " .. item.Name,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 16,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
	})
	titleLabel.Parent = topBar

	local closeButton = createGuiElement("TextButton", {
		Size = UDim2.new(0, 30, 0, 30),
		Position = UDim2.new(1, -35, 0, 5),
		Text = "×",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundColor3 = Color3.fromRGB(220, 70, 70),
		TextSize = 24,
		Font = Enum.Font.GothamBold,
	})
	closeButton.Parent = topBar


	closeButton.MouseEnter:Connect(function()
		TweenService:Create(closeButton,
			TweenInfo.new(0.2),
			{Size = UDim2.new(0, 32, 0, 32), Position = UDim2.new(1, -36, 0, 4)}
		):Play()
	end)

	closeButton.MouseLeave:Connect(function()
		TweenService:Create(closeButton,
			TweenInfo.new(0.2),
			{Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, -35, 0, 5)}
		):Play()
	end)

	closeButton.MouseButton1Click:Connect(function()
		local closeTween = TweenService:Create(mainFrame,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{BackgroundTransparency = 1, Position = UDim2.new(0.5, -175, 0.6, -200)} -- Animate off-screen
		)
		closeTween:Play()
		closeTween.Completed:Connect(function()
			screenGui:Destroy()
		end)
	end)


	local propsLabel = createGuiElement("TextLabel", {
		Size = UDim2.new(1, -20, 0, 30),
		Position = UDim2.new(0, 10, 0, 50),
		BackgroundTransparency = 1,
		Text = "Properties",
		TextColor3 = Color3.fromRGB(230, 230, 230),
		TextSize = 16,
		Font = Enum.Font.GothamSemibold,
		TextXAlignment = Enum.TextXAlignment.Left,
	})
	propsLabel.Parent = mainFrame


	local propertiesFrame = createGuiElement("ScrollingFrame", {
		Size = UDim2.new(1, -20, 0, 175),
		Position = UDim2.new(0, 10, 0, 80),
		BackgroundColor3 = Color3.fromRGB(30, 35, 40),
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollBarThickness = 6,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		AutomaticCanvasSize = Enum.AutomaticSize.Y, -- Automatically adjust canvas size
	})
	propertiesFrame.Parent = mainFrame

	local propertiesBox = createGuiElement("TextBox", {
		Size = UDim2.new(1, -15, 0, 150),
		Position = UDim2.new(0, 5, 0, 5),
		BackgroundTransparency = 0,
		BackgroundColor3 = Color3.fromRGB(30, 35, 40),
		Text = getProperties(item),
		TextColor3 = Color3.fromRGB(230, 230, 230),
		TextSize = 14,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = false,
		ClearTextOnFocus = false,
		MultiLine = true,
	})
	propertiesBox.Parent = propertiesFrame


	local applyButton = createGuiElement("TextButton", {
		Size = UDim2.new(0, 80, 0, 25),
		Position = UDim2.new(0.05, 0, 0, 265),-- Adjusted position for other buttons
		Text = "Apply",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundColor3 = Color3.fromRGB(60, 120, 190),
		TextSize = 14,
		Font = Enum.Font.GothamBold,
	})
	applyButton.Parent = mainFrame
	
	
	applyButton.MouseButton1Click:Connect(function()
		
		local errorMsg = createGuiElement("TextLabel", {
			Size = UDim2.new(1, -20, 0, 20),
			Position = UDim2.new(0, 10, 1, -30),
			BackgroundColor3 = Color3.fromRGB(200, 60, 60),
			Text = "Sorry; the code editor feature is still underway :(",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 12,
			Font = Enum.Font.Gotham,
		})
		errorMsg.Parent = mainFrame
		delay(3, function()
			TweenService:Create(errorMsg, TweenInfo.new(0.5), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
			delay(0.6, function()
			errorMsg:Destroy()
			end)
		end)
		
		
		--local lines = propertiesBox.Text:split("\n")
		--for _, line in ipairs(lines) do
		--	local prop, value = line:match("(.+):%s*(.+)")

		--	-- Ensure that the property exists on the item and is not a function
		--	if prop and value and item and item[prop] ~= nil and typeof(item[prop]) ~= "function" then
		--		local success, convertedValue = pcall(function()
		--			if typeof(item[prop]) == "Vector3" then
		--				local x, y, z = value:match("%(([%d%.%-]+), ([%d%.%-]+), ([%d%.%-]+)%)")
		--				if x and y and z then
		--					return Vector3.new(tonumber(x), tonumber(y), tonumber(z))
		--				else
		--					error("Invalid Vector3 format")
		--				end
		--			elseif typeof(item[prop]) == "Color3" then
		--				local r, g, b = value:match("%(([%d%.%-]+), ([%d%.%-]+), ([%d%.%-]+)%)")
		--				if r and g and b then
		--					return Color3.new(tonumber(r), tonumber(g), tonumber(b))
		--				else
		--					error("Invalid Color3 format")
		--				end
		--			elseif typeof(item[prop]) == "UDim2" then
		--				local xs, xo, ys, yo = value:match("%{X:%s*([%d%.%-]+),%s*Offset:%s*([%d%.%-]+)%s*}%s*{Y:%s*([%d%.%-]+),%s*Offset:%s*([%d%.%-]+)%s*}")
		--				if xs and xo and ys and yo then
		--					return UDim2.new(tonumber(xs), tonumber(xo), tonumber(ys), tonumber(yo))
		--				else
		--					error("Invalid UDim2 format")
		--				end
		--			elseif typeof(item[prop]) == "boolean" then
		--				if value:lower() == "true" then return true end
		--				if value:lower() == "false" then return false end
		--				error("Invalid boolean value")
		--			else
		--				return tonumber(value) or value
		--			end
		--		end)

		--		if success then
		--			item[prop] = convertedValue
		--		else
		--			local errorMsg = createGuiElement("TextLabel", {
		--				Size = UDim2.new(1, -20, 0, 20),
		--				Position = UDim2.new(0, 10, 1, -30),
		--				BackgroundColor3 = Color3.fromRGB(200, 60, 60),
		--				Text = "Error setting " .. prop .. ": " .. tostring(convertedValue):sub(1, 50),
		--				TextColor3 = Color3.fromRGB(255, 255, 255),
		--				TextSize = 12,
		--				Font = Enum.Font.Gotham,
		--			})
		--			errorMsg.Parent = mainFrame

		--			delay(3, function()
		--				TweenService:Create(errorMsg, TweenInfo.new(0.5), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
		--				delay(0.6, function()
		--					errorMsg:Destroy()
		--				end)
		--			end)
		--			return
		--		end
		--	end
		--end

		--propertiesBox.Text = getProperties(item)
		
	end)




	local deleteButton = createGuiElement("TextButton", {
		Size = UDim2.new(0, 80, 0, 25),
		Position = UDim2.new(0.3, 0, 0, 265),-- Adjusted position
		Text = "Delete",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundColor3 = Color3.fromRGB(180, 70, 70), -- Red color
		TextSize = 14,
		Font = Enum.Font.GothamBold,
	})
	deleteButton.Parent = mainFrame

	deleteButton.MouseButton1Click:Connect(function()
		item:Destroy()
		screenGui:Destroy() -- Close the GUI after deleting 
	end)


	-- ... (rest of GUI code: Copy Button, Interactions Section, Clone Button, Save Button, Dragging, Keyboard shortcut remains the same)
	local copyButton = createGuiElement("TextButton", {
		Size = UDim2.new(0, 100, 0, 25),
		Position = UDim2.new(1, -110, 0, 265),  -- Adjusted position
		Text = "Copy Info",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundColor3 = Color3.fromRGB(60, 120, 190),
		TextSize = 14,
		Font = Enum.Font.GothamBold,
	})
	copyButton.Parent = mainFrame

	copyButton.MouseButton1Click:Connect(function()
		local success = pcall(setclipboard(tostring(propertiesBox.text)))

		if success then
			TweenService:Create(copyButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 180, 75)}):Play() -- Green flash
		else
			TweenService:Create(copyButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(180, 70, 70)}):Play() -- Red flash
		end
		TweenService:Create(copyButton, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0.3),
			{BackgroundColor3 = Color3.fromRGB(60, 120, 190)}):Play() -- Back to normal
	end)


	local actionsLabel = createGuiElement("TextLabel", {
		Size = UDim2.new(1, -20, 0, 30),
		Position = UDim2.new(0, 10, 0, 300),  -- Moved down slightly
		BackgroundTransparency = 1,
		Text = "Interactions",
		TextColor3 = Color3.fromRGB(230, 230, 230),
		TextSize = 16,
		Font = Enum.Font.GothamSemibold,
		TextXAlignment = Enum.TextXAlignment.Left,
	})
	actionsLabel.Parent = mainFrame


	local buttonsContainer = createGuiElement("ScrollingFrame", {
		Size = UDim2.new(1, -20, 0, 60), -- Height adjusted to fit buttons
		Position = UDim2.new(0, 10, 0, 330),  -- Moved down slightly
		BackgroundTransparency = 1,
	})
	buttonsContainer.Parent = mainFrame


	local function createActionButton(text, posX, posY, bgColor, action, action2)
		local btn = createGuiElement("TextButton", {
			Size = UDim2.new(0, 100, 0, 25),
			Position = UDim2.new(0, posX, 0, posY),
			Text = text,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundColor3 = bgColor,
			TextSize = 14,
			Font = Enum.Font.GothamBold,
		})
		btn.Parent = buttonsContainer

		btn.MouseEnter:Connect(function()
			TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = bgColor:Lerp(Color3.fromRGB(255, 255, 255), 0.2)}):Play()
		end)

		btn.MouseLeave:Connect(function()
			TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = bgColor}):Play()
		end)

		btn.MouseButton1Click:Connect(function()
			local success, err = pcall(action)
			if not success then
				local errorMsg = createGuiElement("TextLabel", {
					Size = UDim2.new(1, -20, 0, 20),
					Position = UDim2.new(0, 10, 1, -30), -- Position at the bottom of mainFrame
					BackgroundColor3 = Color3.fromRGB(200, 60, 60),
					Text = "Error: " .. tostring(err):sub(1, 30), -- Limit error message length
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextSize = 12,
					Font = Enum.Font.Gotham,
				})
				errorMsg.Parent = mainFrame
				
				warn("[DEBUG] [ERROR LOG] : " .. err)


				delay(3, function()
					TweenService:Create(errorMsg, TweenInfo.new(0.5), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
					delay(0.6, function()
						errorMsg:Destroy()
					end)
				end)
			end
		end)
		
		btn.MouseButton2Click:Connect(function()
			if action2 == nil then
				return
			end
			
			local success, err = pcall(action2)
			if not success then
				local errorMsg = createGuiElement("TextLabel", {
					Size = UDim2.new(1, -20, 0, 20),
					Position = UDim2.new(0, 10, 1, -30), -- Position at the bottom of mainFrame
					BackgroundColor3 = Color3.fromRGB(200, 60, 60),
					Text = "Error: " .. tostring(err):sub(1, 30), -- Limit error message length
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextSize = 12,
					Font = Enum.Font.Gotham,
				})
				errorMsg.Parent = mainFrame


				delay(3, function()
					TweenService:Create(errorMsg, TweenInfo.new(0.5), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
					delay(0.6, function()
						errorMsg:Destroy()
					end)
				end)
			end
		end)
		
		

		return btn
	end


	local resizeBtn = createActionButton("Resize", 0, 0, Color3.fromRGB(70, 130, 180), function()
		
		-- left click
		
		if item:IsA("BasePart") then
			item.Size = item.Size * 1.2
			propertiesBox.Text = getProperties(item) -- update display
		end
	end, function()
		
		-- right click
		
		if item:IsA("BasePart") then
			item.Size = item.Size / 1.2
			propertiesBox.Text = getProperties(item) -- update display
		end
	end)
	
	


	local colorBtn = createActionButton("Change Color", 110, 0, Color3.fromRGB(60, 180, 75), function()
		if item:IsA("BasePart") then
			item.Color = Color3.new(math.random(), math.random(), math.random())
			propertiesBox.Text = getProperties(item) -- update display
		end
	end)


	local unanchorBtn = createActionButton("Unanchor", 220, 0, Color3.fromRGB(180, 70, 70), function()
		if item:IsA("BasePart") then
			item.Anchored = false
			propertiesBox.Text = getProperties(item) -- update display
		end
	end)

	local cloneBtn = createActionButton("Clone", 0, 30, Color3.fromRGB(150, 80, 200), function()
		local clone = item:Clone()

		if clone:IsA("BasePart") then
			clone.Position = item.Position + Vector3.new(0, item.Size.Y * 1.5, 0)
		end

		clone.Parent = item.Parent

		TweenService:Create(closeButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 180, 75)}):Play()-- Flash close button green for success
		TweenService:Create(closeButton, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0.3),
			{BackgroundColor3 = Color3.fromRGB(220, 70, 70)}):Play() -- back to normal
	end)
	
	local dragBtn = createActionButton("Draggable", 220, 30, Color3.fromRGB(70, 190, 90), function()
		-- Check if the item has a ProximityPrompt with the target name
		local prompt = item:FindFirstChild(targetPromptName)
		if prompt and prompt:IsA("ProximityPrompt") then
			prompt:Destroy()  -- Destroy the specific ProximityPrompt
		end

		-- Destroy the GUI if it exists
		if mainFrame then
			mainFrame:Destroy()
		end

		-- If there's already a DragDetector, don't add another
		if item:FindFirstChild("DragDetector") then
			return
		end

		-- Create a DragDetector
		local dragDetector = Instance.new("DragDetector")
		dragDetector.Parent = item
		dragDetector.MaxActivationDistance = math.huge  -- Allows dragging from any distance

		-- Variable to hold the offset from the initial position
		local offset = Vector3.new()

		-- When dragging starts, store the initial offset
		dragDetector.DragStart:Connect(function(_, startPos)
			offset = item.Position - startPos
		end)

		-- Update position during dragging
		dragDetector.DragContinue:Connect(function(_, _, dragPos)
			-- Update the X, Y, Z positions dynamically based on the mouse position
			local newPos = UDim2.new(
				0, dragPos.X + offset.X,  -- X position
				0, dragPos.Y + offset.Y   -- Y position
			)
			item.Position = newPos
		end)

		print("Drag enabled!")
	end)



	local saveBtn = createActionButton("Save Object", 110, 30, Color3.fromRGB(90, 120, 190), function()

		local workspaceFolder = workspace:FindFirstChild(player.Name .. "_Storage")
		if not workspaceFolder then
			workspaceFolder = Instance.new("Folder")
			workspaceFolder.Name = player.Name .. "_Storage"
			workspaceFolder.Parent = workspace
		end


		item.Parent = workspaceFolder
		screenGui:Destroy()
	end)
	
	local removeBtn = createActionButton("Remove tag", 0, 60, Color3.fromRGB(190, 0, 0), function()
		
		-- Check if the item has a ProximityPrompt with the target name
		local prompt = item:FindFirstChild(targetPromptName)
		if prompt and prompt:IsA("ProximityPrompt") then
			prompt:Destroy()  -- Destroy the specific ProximityPrompt
		end

		screenGui:Destroy()
		
	end)
	
	local teleportBtn = createActionButton("Teleport to..", 110, 60, Color3.fromRGB(120, 60, 180), function() 
		local playerList = {} 
		for _, player in pairs(game:GetService("Players"):GetPlayers()) do
			if player.Character and player.Character.PrimaryPart then
				table.insert(playerList, player.Name)
			end
		end

		if #playerList == 0 then return end 

		local selectionFrame = createGuiElement("Frame", {
			Size = UDim2.new(0, 220, 0, 180),
			Position = UDim2.new(0.5, -110, 0.5, -90),
			BackgroundColor3 = Color3.fromRGB(40, 40, 40),
			BorderSizePixel = 2,
			BorderColor3 = Color3.fromRGB(90, 90, 90),
			Parent = mainFrame
		})

		createGuiElement("TextLabel", {
			Size = UDim2.new(1, 0, 0, 30),
			BackgroundTransparency = 0.2,
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			BorderSizePixel = 0,
			Text = "Select a Player",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 16,
			Font = Enum.Font.GothamBold,
			Parent = selectionFrame
		})

		-- X (Close) Button
		local closeButton = createGuiElement("TextButton", {
			Size = UDim2.new(0, 30, 0, 30),
			Position = UDim2.new(1, -30, 0, 0),
			BackgroundColor3 = Color3.fromRGB(200, 60, 60),
			Text = "X",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 18,
			Font = Enum.Font.GothamBold,
			Parent = selectionFrame
		})
		closeButton.MouseButton1Click:Connect(function()
			selectionFrame:Destroy()
		end)

		-- Player Buttons
		for i, playerName in pairs(playerList) do
			local button = createGuiElement("TextButton", {
				Size = UDim2.new(1, -10, 0, 25),
				Position = UDim2.new(0, 5, 0, 35 + (i - 1) * 30),
				BackgroundColor3 = Color3.fromRGB(80, 120, 180),
				Text = playerName,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = 14,
				Font = Enum.Font.Gotham,
				Parent = selectionFrame
			})

			button.MouseButton1Click:Connect(function()
				local targetPlayer = game:GetService("Players"):FindFirstChild(playerName)
				if targetPlayer and targetPlayer.Character and targetPlayer.Character.PrimaryPart then
					item.Position = targetPlayer.Character.PrimaryPart.Position + Vector3.new(0, 3, 0)
				end
				selectionFrame:Destroy()
			end)
		end
	end)
	
	local flingBtn = createActionButton("Fling Item", 220, 60, Color3.fromRGB(200, 50, 50), function() 
		
		screenGui:Destroy()
		
		if item and item:IsA("BasePart") then
			-- Unanchor the item to allow physics to affect it
			item.Anchored = false

			-- Apply a random fling direction with high velocity and spin
			local randomDirection = Vector3.new(
				math.random(-1000, 1000), -- Random direction on X
				math.random(500, 1000),   -- Random upward force on Y
				math.random(-1000, 1000)  -- Random direction on Z
			)
			item.AssemblyLinearVelocity = randomDirection

			-- Apply random spinning effect by setting angular velocity
			local randomSpin = Vector3.new(
				math.random(-2000, 2000), -- Random rotation speed on X-axis
				math.random(-2000, 2000), -- Random rotation speed on Y-axis
				math.random(-2000, 2000)  -- Random rotation speed on Z-axis
			)
			item.AssemblyAngularVelocity = randomSpin
		end
	end)
	
	-- Freeze Button (Position 0, 0)
	local freezeBtn = createActionButton("Freeze Item", 0, 90, Color3.fromRGB(100, 100, 255), function() 
		if item and item:IsA("BasePart") then
			-- Anchor the item to prevent movement
			item.Anchored = true

			-- Remove all children (making it useless and blocking further interactions)
			for _, child in ipairs(item:GetChildren()) do
				child:Destroy()
			end

			-- Disable any future interactions (collisions, touch events, etc)
			item.CanCollide = false

			-- Make the item completely frozen, no more physics
			item.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
			item.AssemblyAngularVelocity = Vector3.new(0, 0, 0)

			-- Optional: Display a message to the user that the item is "frozen"
			local freezeMessage = Instance.new("BillboardGui")
			freezeMessage.Adornee = item
			freezeMessage.Size = UDim2.new(0, 200, 0, 50)
			freezeMessage.StudsOffset = Vector3.new(0, 5, 0)
			freezeMessage.AlwaysOnTop = true

			local freezeLabel = Instance.new("TextLabel")
			freezeLabel.Parent = freezeMessage
			freezeLabel.Text = "Item Frozen!"
			freezeLabel.Size = UDim2.new(1, 0, 1, 0)
			freezeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			freezeLabel.TextScaled = true
			freezeLabel.BackgroundTransparency = 1
			freezeMessage.Parent = workspace

			-- Optional: Destroy the message after 3 seconds
			wait(3)
			freezeMessage:Destroy()
		end
	end)
	
	-- Strip Button (Position 220, 0)
	local stripBtn = createActionButton("Strip Item", 110, 90, Color3.fromRGB(255, 255, 100), function() 
		if item and item:IsA("BasePart") then
			-- Get the current color of the item
			local currentColor = item.Color

			-- Remove any textures, decals, or materials attached to the item
			for _, child in ipairs(item:GetChildren()) do
				if child:IsA("Decal") or child:IsA("Texture") then
					child:Destroy()  -- Remove the texture or decal
				end
			end

			-- Reset material settings to default (but keep the original color)
			item.Material = Enum.Material.Plastic  -- Default material for an item
			item.Color = currentColor  -- Keep the original color

			-- Reset any special surface properties
			item.Transparency = 0  -- Set transparency to 0 (fully visible)
			item.Reflectance = 0  -- Remove reflectance

			-- Reset any custom meshes to default
			for _, child in ipairs(item:GetChildren()) do
				if child:IsA("MeshPart") then
					child.MeshId = ""  -- Remove any mesh attached
				end
			end
		end
	end)
	
	-- Toggle Invisibility Button (Position 220, 30)
	local toggleInvisBtn = createActionButton("Toggle Invis", 220, 90, Color3.fromRGB(255, 100, 100), function()
		if item and item:IsA("BasePart") then
			-- Toggle transparency between 1 (invisible) and 0 (visible)
			if item.Transparency == 0 then
				item.Transparency = 1  -- Make the item invisible
			else
				item.Transparency = 0  -- Make the item visible again
			end
		end
	end)
	
	local shrinkBtn = createActionButton("Shrink", 0, 120, Color3.fromRGB(150, 150, 255), function()
		if item and item:IsA("BasePart") then
			-- Gradually shrink the item over time
			for i = 100, 1, -1 do
				item.Size = item.Size * (i / 100)
				wait(0.05)  -- Adjust the speed of shrinking
			end
			item:Destroy()  -- Optionally destroy the item after shrinking
		end
	end)
	
	--local morphBtn = createActionButton("Morph", 0, 0, Color3.fromRGB(70, 130, 180), function()
	--	-- Left-click to morph into a block
	--	local player = game.Players.LocalPlayer
	--	local character = player.Character or player.CharacterAdded:Wait()

	--	-- Only proceed if we have a character and humanoid root part
	--	if character and character:FindFirstChild("HumanoidRootPart") then
	--		-- Check if already morphed
	--		if not workspace:FindFirstChild("MorphedPart" .. player.UserId) then
	--			-- Create the morph block
	--			local morphPart = Instance.new("Part")
	--			morphPart.Size = Vector3.new(4, 4, 4)
	--			morphPart.Position = character.HumanoidRootPart.Position
	--			morphPart.Anchored = false
	--			morphPart.CanCollide = true
	--			morphPart.Color = Color3.fromRGB(255, 0, 0)
	--			morphPart.Name = "MorphedPart" .. player.UserId

	--			-- Create weld to attach the block to the character
	--			local weld = Instance.new("WeldConstraint")
	--			weld.Part0 = morphPart
	--			weld.Part1 = character.HumanoidRootPart
	--			weld.Parent = morphPart

	--			morphPart.Parent = workspace

	--			-- Make the player model invisible
	--			for _, part in pairs(character:GetDescendants()) do
	--				if part:IsA("BasePart") then
	--					-- Store original transparency in an attribute to restore later
	--					part:SetAttribute("OriginalTransparency", part.Transparency)
	--					part.Transparency = 1
	--				end
	--			end
	--		end
	--	end
	--end, function()
	--	-- Right-click to turn back to normal
	--	local player = game.Players.LocalPlayer
	--	local character = player.Character or player.CharacterAdded:Wait()

	--	-- Check if already morphed
	--	local morphPart = workspace:FindFirstChild("MorphedPart" .. player.UserId)
	--	if morphPart and character then
	--		-- Remove the morph block
	--		morphPart:Destroy()

	--		-- Make the player visible again
	--		for _, part in pairs(character:GetDescendants()) do
	--			if part:IsA("BasePart") then
	--				-- Restore original transparency value
	--				local origTransparency = part:GetAttribute("OriginalTransparency")
	--				if origTransparency ~= nil then
	--					part.Transparency = origTransparency
	--				else
	--					part.Transparency = 0
	--				end
	--			end
	--		end
	--	end
	end)




	local dragging = false
	local dragStart, startPos

	topBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = mainFrame.Position
		end
	end)

	topBar.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if input.KeyCode == Enum.KeyCode.Escape and not gameProcessed then
			screenGui:Destroy()
		end
	end)

	screenGui.AncestryChanged:Connect(function(_, newParent)
		if not newParent then -- when the GUI is destroyed
			-- rip
		end
	end)


end




local function addProximityPrompt(item)
	if not item:IsA("BasePart") or isPlayerBodyPart(item) or item:FindFirstChild("CustomProximityPrompt") then return end


	if item:IsA("Terrain") or item.Name:match("^Workspace") or item.Name:match("^Camera") then return end


	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "cKGrJsPWa`Rd(/'p?zFR@fG*K=jIMDRKd5'mb^K%iixC6]Ag=<%r7f%g<1=r"
	prompt.HoldDuration = PROMPT_HOLD_DURATION
	prompt.MaxActivationDistance = MAX_ACTIVATION_DISTANCE
	prompt.KeyboardKeyCode = Enum.KeyCode.BackSlash
	prompt.GamepadKeyCode = Enum.KeyCode.ButtonX
	prompt.ObjectText = item.Name
	prompt.ActionText = "Inspect"
	prompt.RequiresLineOfSight = false
	prompt.Enabled = true
	prompt.Parent = item

	prompt.Triggered:Connect(function(player)
		if player and player:IsA("Player") then
			showCustomGui(player, item)
		end
	end)
end


local function scanWorkspace()
	for _, object in pairs(workspace:GetDescendants()) do
		if object:IsA("BasePart") then
			addProximityPrompt(object)
		end
	end
end



local function initialize()
	local function showNotification(player)
		local playerGui = player:FindFirstChild("PlayerGui")
		if not playerGui then return end

		local notifGui = Instance.new("ScreenGui")
		notifGui.Name = "InspectorNotification"
		notifGui.Parent = playerGui

		local notifFrame = createGuiElement("Frame", {
			Size = UDim2.new(0, 250, 0, 50),
			Position = UDim2.new(0.5, -125, 0, -60), -- Initial position off-screen
			BackgroundColor3 = Color3.fromRGB(40, 120, 200),
		})
		notifFrame.Parent = notifGui

		local notifText = createGuiElement("TextLabel", {
			Size = UDim2.new(1, -20, 1, 0),
			Position = UDim2.new(0, 10, 0, 0),
			BackgroundTransparency = 1,
			Text = "Object Inspector Loaded - Press \ (backslash) to inspect objects",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 14,
			Font = Enum.Font.GothamBold,
			TextWrapped = true,
		})
		notifText.Parent = notifFrame

		local slideTween = TweenService:Create(notifFrame,
			TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{Position = UDim2.new(0.5, -125, 0, 20)} -- Slide in
		)
		slideTween:Play()

		delay(5, function()
			TweenService:Create(notifFrame,
				TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{Position = UDim2.new(0.5, -125, 0, -60)} -- Slide out
			):Play()

			delay(0.6, function()  -- slight delay to let slide out animation finish
				notifGui:Destroy()
			end)
		end)


	end

	scanWorkspace()

	workspace.DescendantAdded:Connect(function(object)
		if object:IsA("BasePart") then
			delay(0.1, function()  -- Slight delay to let the object fully initialize
				addProximityPrompt(object)
			end)
		end
	end)


	for _, player in pairs(Players:GetPlayers()) do
		showNotification(player)  -- Show notification to existing players
	end

	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function()
			showNotification(player)  -- notification for new players
		end)
	end)

	print("Object Inspector successfully loaded!")
end


initialize()

