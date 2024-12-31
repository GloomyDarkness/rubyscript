-- Variáveis principais
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local tweenService = game:GetService("TweenService")
local userInputService = game:GetService("UserInputService")

local teleportEnabled = false

-- Adicione estas variáveis no início do script
local noclipConnection = nil
local movementConnection = nil
local isMoving = false
local noclipEnabled = false

-- Função de noclip
local function setNoclip(enabled)
    if enabled == noclipEnabled then return end
    noclipEnabled = enabled
    
    if enabled then
        noclipConnection = game:GetService("RunService").Stepped:Connect(function()
            if character and humanoidRootPart then
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
        print("Noclip ativado")
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
            
            -- Restaura colisão gradualmente para evitar bugs
            task.delay(0.1, function()
                if character then
                    for _, part in ipairs(character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = true
                        end
                    end
                end
            end)
        end
        print("Noclip desativado")
    end
end

-- Função de movimento suave
local function smoothMove(targetPosition)
    if isMoving then return end
    isMoving = true
    
    -- Ativa noclip antes de mover
    setNoclip(true)
    
    local startPos = humanoidRootPart.Position
    local distance = (targetPosition - startPos).Magnitude
    local moveDuration = math.min(distance / 100, 3) -- Velocidade ajustável
    
    -- Define a orientação para olhar para o destino
    local lookVector = (targetPosition - startPos).Unit
    humanoidRootPart.CFrame = CFrame.new(startPos) * CFrame.lookAt(Vector3.new(0,0,0), lookVector)
    
    -- Movimento suave
    local tween = tweenService:Create(humanoidRootPart, 
        TweenInfo.new(moveDuration, Enum.EasingStyle.Linear),
        {CFrame = CFrame.new(targetPosition + Vector3.new(0, 3, 0))}
    )
    
    -- Efeito de rastro
    local trail = Instance.new("Trail")
    trail.Color = ColorSequence.new(Color3.fromRGB(85, 170, 255))
    trail.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.7),
        NumberSequenceKeypoint.new(1, 1)
    })
    trail.Lifetime = 0.5
    trail.Parent = humanoidRootPart
    
    -- Inicia o movimento
    tween:Play()
    tween.Completed:Connect(function()
        -- Espera um momento antes de desativar o noclip
        task.delay(0.5, function()
            setNoclip(false)
            isMoving = false
        end)
    end)
    
    -- Limpa os efeitos
    trail:Destroy()
end

-- Criação da interface moderna
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportGui"
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Container principal com sombra
local mainContainer = Instance.new("Frame")
mainContainer.Name = "MainContainer"
mainContainer.Size = UDim2.new(0, 220, 0, 60)
mainContainer.Position = UDim2.new(0.5, -110, 0.9, -70)
mainContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainContainer.BorderSizePixel = 0
mainContainer.Parent = screenGui

-- Efeito de sombra
local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.Size = UDim2.new(1.2, 0, 1.2, 0)
shadow.Position = UDim2.new(-0.1, 0, -0.1, 0)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://1316045217"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.6
shadow.Parent = mainContainer

-- Botão principal
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(1, 0, 1, 0)
toggleButton.Position = UDim2.new(0, 0, 0, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(85, 170, 255)
toggleButton.Text = ""
toggleButton.AutoButtonColor = false
toggleButton.Parent = mainContainer

-- Adicione após a criação do mainContainer
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 14
closeButton.Parent = mainContainer

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeButton

-- Adicione os efeitos e função de fechamento
closeButton.MouseButton1Click:Connect(function()
    -- Desativa noclip se estiver ativo
    setNoclip(false)
    isMoving = false
    
    -- Animação de fade out
    tweenService:Create(mainContainer, TweenInfo.new(0.5), {
        BackgroundTransparency = 1
    }):Play()
    
    -- Trata elementos específicos separadamente
    tweenService:Create(shadow, TweenInfo.new(0.5), {
        ImageTransparency = 1
    }):Play()
    
    for _, child in ipairs(mainContainer:GetDescendants()) do
        if child:IsA("TextButton") or child:IsA("TextLabel") then
            tweenService:Create(child, TweenInfo.new(0.5), {
                BackgroundTransparency = 1,
                TextTransparency = 1
            }):Play()
        elseif child:IsA("Frame") then
            tweenService:Create(child, TweenInfo.new(0.5), {
                BackgroundTransparency = 1
            }):Play()
        end
    end
    
    -- Remove a GUI após a animação
    task.delay(0.5, function()
        screenGui:Destroy()
    end)
end)

-- Arredondamento dos cantos
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 10)
uiCorner.Parent = toggleButton

local containerCorner = Instance.new("UICorner")
containerCorner.CornerRadius = UDim.new(0, 10)
containerCorner.Parent = mainContainer

-- Ícone de teleporte
local icon = Instance.new("ImageLabel")
icon.Size = UDim2.new(0, 30, 0, 30)
icon.Position = UDim2.new(0.1, 0, 0.5, -15)
icon.BackgroundTransparency = 1
icon.Image = "rbxassetid://6034287519" -- Ícone de teleporte
icon.Parent = toggleButton

-- Texto do botão
local buttonText = Instance.new("TextLabel")
buttonText.Size = UDim2.new(0.7, 0, 1, 0)
buttonText.Position = UDim2.new(0.3, 0, 0, 0)
buttonText.BackgroundTransparency = 1
buttonText.Text = "Ativar Teleporte"
buttonText.TextColor3 = Color3.new(1, 1, 1)
buttonText.Font = Enum.Font.GothamBold
buttonText.TextSize = 16
buttonText.Parent = toggleButton

-- Configurações de animação
local function createTween(object, properties, duration)
    return tweenService:Create(object, TweenInfo.new(duration, Enum.EasingStyle.Quad), properties)
end

-- Efeitos de hover
toggleButton.MouseEnter:Connect(function()
    createTween(toggleButton, {BackgroundColor3 = teleportEnabled and 
        Color3.fromRGB(255, 100, 100) or 
        Color3.fromRGB(100, 180, 255)}, 0.3):Play()
end)

toggleButton.MouseLeave:Connect(function()
    createTween(toggleButton, {BackgroundColor3 = teleportEnabled and 
        Color3.fromRGB(255, 85, 85) or 
        Color3.fromRGB(85, 170, 255)}, 0.3):Play()
end)

-- Função para alternar o estado de teleporte
local function toggleTeleport()
    teleportEnabled = not teleportEnabled
    
    -- Animação do botão
    local targetColor = teleportEnabled and Color3.fromRGB(255, 85, 85) or Color3.fromRGB(85, 170, 255)
    createTween(toggleButton, {BackgroundColor3 = targetColor}, 0.3):Play()
    
    -- Animação de escala
    createTween(mainContainer, {Size = UDim2.new(0, 230, 0, 65)}, 0.1):Play()
    wait(0.1)
    createTween(mainContainer, {Size = UDim2.new(0, 220, 0, 60)}, 0.1):Play()
    
    buttonText.Text = teleportEnabled and "Desativar Teleporte" or "Ativar Teleporte"
end

-- Conecta o clique do botão
toggleButton.MouseButton1Click:Connect(toggleTeleport)

-- Função de teleporte com efeito visual
mouse.Button1Down:Connect(function()
    if teleportEnabled and not isMoving then
        local targetPosition = mouse.Hit.Position
        
        -- Efeito visual no ponto de teleporte
        local teleportEffect = Instance.new("Part")
        teleportEffect.Anchored = true
        teleportEffect.CanCollide = false
        teleportEffect.Size = Vector3.new(1, 1, 1)
        teleportEffect.Position = targetPosition
        teleportEffect.Material = Enum.Material.Neon
        teleportEffect.BrickColor = BrickColor.new("Bright blue")
        teleportEffect.Shape = Enum.PartType.Ball
        teleportEffect.Parent = workspace
        
        -- Anima e remove o efeito
        createTween(teleportEffect, {Size = Vector3.new(0, 0, 0), Transparency = 1}, 0.5):Play()
        game:GetService("Debris"):AddItem(teleportEffect, 0.5)
        
        -- Usa movimento suave ao invés de teleporte instantâneo
        smoothMove(targetPosition)
    end
end)

-- Limpeza ao desativar
local function cleanup()
    setNoclip(false)
    isMoving = false
    if movementConnection then
        movementConnection:Disconnect()
    end
end

-- Conecta limpeza quando o personagem morre
player.CharacterRemoving:Connect(cleanup)
