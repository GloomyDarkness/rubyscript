local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local RunService = game:GetService("RunService")

-- Configurações do farm
local FARM_HEIGHT = 15 -- Altura do voo
local ATTACK_RANGE = 15 -- Alcance do ataque
local FLY_SPEED = 16 -- Velocidade de voo
local TARGET_NAME = "Bandit"

-- Configurações de combate atualizadas
local COMBAT_SETTINGS = {
    equipDelay = 0.2,
    attackDelay = 0.1,
    comboDelay = 0.3,
    maxDistance = ATTACK_RANGE, -- Usa o ATTACK_RANGE definido
    weaponEquipTime = 0.5 -- Tempo para garantir que a arma equipou
}

-- Configurações otimizadas do farm
local FARM_SETTINGS = {
    height = 12,           -- Altura acima do ponto inicial do Bandit
    attackRange = 20,      -- Alcance do ataque
    flySpeed = 0.1,        -- Velocidade de interpolação do voo (0.1 = mais suave)
    targetName = "Bandit",
    minAttackTime = 3,     -- Tempo mínimo atacando mesmo alvo
    maxSearchRadius = 100,  -- Raio de busca
    heightTolerance = 2,   -- Tolerância de variação na altura
    heightCheck = 0.1,     -- Intervalo de verificação de altura (adicionado)
    preReduceHealth = 0.3,  -- Reduz vida para 30% do original
    groupingRadius = 30    -- Raio para agrupar bandits
}

-- Estado do farm
local FarmState = {
    active = false,
    currentTarget = nil,
    attackStartTime = 0,
    connection = nil,
    attacking = false,
    lastHeightCheck = 0,
    originalHeight = 0
}

-- Sistema de posicionamento
local PositionSystem = {
    targetPositions = {}, -- Armazena posições iniciais dos bandits
    
    saveInitialPosition = function(self, bandit)
        if not bandit or not bandit:FindFirstChild("HumanoidRootPart") then return end
        local id = bandit:GetFullName()
        
        if not self.targetPositions[id] then
            self.targetPositions[id] = bandit.HumanoidRootPart.Position + Vector3.new(0, FARM_SETTINGS.height, 0)
        end
        
        return self.targetPositions[id]
    end,
    
    getAttackPosition = function(self, bandit)
        return self.targetPositions[bandit:GetFullName()]
    end,
    
    cleanup = function(self)
        self.targetPositions = {}
    end
}

-- Interface
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoFarmGui"
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 200, 0, 100)
mainFrame.Position = UDim2.new(0.85, -100, 0.1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 10)
uiCorner.Parent = mainFrame

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0.9, 0, 0.4, 0)
toggleButton.Position = UDim2.new(0.05, 0, 0.1, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(85, 170, 255)
toggleButton.Text = "Iniciar Farm"
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 14
toggleButton.Parent = mainFrame

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 8)
buttonCorner.Parent = toggleButton

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0.3, 0)
statusLabel.Position = UDim2.new(0.05, 0, 0.6, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Desativado"
statusLabel.TextColor3 = Color3.new(1, 1, 1)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 12
statusLabel.Parent = mainFrame

-- Adiciona opção de agrupamento à interface
local groupContainer = Instance.new("Frame")
groupContainer.Size = UDim2.new(0.9, 0, 0.3, 0)
groupContainer.Position = UDim2.new(0.05, 0, 0.6, 0)
groupContainer.BackgroundTransparency = 1
groupContainer.Parent = mainFrame

local groupButton = Instance.new("TextButton")
groupButton.Size = UDim2.new(1, 0, 1, 0)
groupButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
groupButton.Text = "Agrupar Bandits"
groupButton.TextColor3 = Color3.new(1, 1, 1)
groupButton.Font = Enum.Font.GothamBold
groupButton.TextSize = 14
groupButton.Parent = groupContainer

local groupCorner = Instance.new("UICorner")
groupCorner.CornerRadius = UDim.new(0, 8)
groupCorner.Parent = groupButton

-- Variáveis de controle
local farming = false
local lastAttack = 0
local weaponEquipped = false
local lastEquipAttempt = 0

-- Sistema de controle do Bandit (corrigido)
local BanditController = {
    modifiedBandits = {},
    initialized = false,
    
    init = function(self)
        if self.initialized then return end
        self.modifiedBandits = {}
        self.initialized = true
    end,
    
    prepareBandit = function(self, bandit)
        if not self.initialized then
            self:init()
        end
        
        if not bandit or not bandit:FindFirstChild("Humanoid") then return end
        local id = bandit:GetFullName()
        
        -- Verifica se já foi modificado
        if self.modifiedBandits[id] then return end
        
        local humanoid = bandit:FindFirstChild("Humanoid")
        local originalHealth = humanoid.Health
        local originalMaxHealth = humanoid.MaxHealth
        
        -- Reduz a vida total e atual
        humanoid.MaxHealth = originalMaxHealth * FARM_SETTINGS.preReduceHealth
        humanoid.Health = humanoid.MaxHealth
        
        -- Desativa movimento
        humanoid.WalkSpeed = 0
        humanoid.JumpPower = 0
        
        -- Remove scripts de movimento
        for _, script in pairs(bandit:GetDescendants()) do
            if script:IsA("Script") and 
               (script.Name:match("AI") or script.Name:match("Control")) then
                script.Disabled = true
            end
        end
        
        self.modifiedBandits[id] = true
        return true
    end,
    
    cleanup = function(self)
        self.modifiedBandits = {}
        self.initialized = false
    end
}

-- Inicializa o BanditController
BanditController:init()

-- Sistema de agrupamento
local GroupingSystem = {
    groupingPoint = nil,
    isGrouping = false,
    
    setGroupingPoint = function(self, position)
        self.groupingPoint = position
    end,
    
    groupBandits = function(self)
        if not self.groupingPoint then return end
        
        for _, enemy in pairs(workspace.Enemies:GetChildren()) do
            if enemy.Name == FARM_SETTINGS.targetName and 
               enemy:FindFirstChild("HumanoidRootPart") and
               enemy:FindFirstChild("Humanoid") then
                
                local distance = (enemy.HumanoidRootPart.Position - self.groupingPoint).Magnitude
                if distance <= FARM_SETTINGS.groupingRadius then
                    enemy.HumanoidRootPart.CFrame = CFrame.new(self.groupingPoint)
                    BanditController:prepareBandit(enemy) -- Desativa movimento do bandit
                end
            end
        end
    end,
    
    toggleGrouping = function(self)
        self.isGrouping = not self.isGrouping
        groupButton.BackgroundColor3 = self.isGrouping and 
            Color3.fromRGB(255, 85, 85) or 
            Color3.fromRGB(60, 60, 60)
    end,
    
    cleanup = function(self)
        self.groupingPoint = nil
        self.isGrouping = false
    end
}

-- Função otimizada para encontrar o Bandit mais próximo
local function findNearestBandit()
    local nearest = nil
    local minDistance = math.huge
    local maxSearchRadius = 1000 -- Limita o raio de busca
    
    if workspace:FindFirstChild("Enemies") then
        local playerPosition = character.HumanoidRootPart.Position
        
        for _, enemy in pairs(workspace.Enemies:GetChildren()) do
            if enemy.Name == TARGET_NAME and 
               enemy:FindFirstChild("HumanoidRootPart") and
               enemy:FindFirstChild("Humanoid") and 
               enemy.Humanoid.Health > 0 then
                
                -- Prepara o Bandit com self
                BanditController:prepareBandit(enemy)
                
                local enemyPosition = enemy.HumanoidRootPart.Position
                local distance = (enemyPosition - playerPosition).Magnitude
                
                -- Só considera inimigos dentro do raio de busca
                if distance < maxSearchRadius and distance < minDistance then
                    -- Verifica se há obstáculos entre o jogador e o inimigo
                    local ray = Ray.new(playerPosition, enemyPosition - playerPosition)
                    local hit = workspace:FindPartOnRayWithIgnoreList(ray, {character, enemy})
                    
                    if not hit then
                        minDistance = distance
                        nearest = enemy
                        
                        -- Define ponto de agrupamento se ainda não existir
                        if GroupingSystem.isGrouping and not GroupingSystem.groupingPoint then
                            GroupingSystem:setGroupingPoint(enemyPosition)
                            GroupingSystem:groupBandits()
                        end
                    end
                end
            end
        end
    end
    
    return nearest
end

-- Função modificada para manter altura durante o voo
local function maintainHeight()
    local currentTime = tick()
    if not FarmState.lastHeightCheck then FarmState.lastHeightCheck = 0 end
    if currentTime - FarmState.lastHeightCheck < FARM_SETTINGS.heightCheck then return end
    
    FarmState.lastHeightCheck = currentTime
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    -- Mantém a altura atual se estiver voando para um alvo
    if FarmState.currentTarget then
        local targetPos = GroupingSystem.groupingPoint or 
                         FarmState.currentTarget.HumanoidRootPart.Position
        local desiredHeight = targetPos.Y + FARM_SETTINGS.height
        
        if math.abs(hrp.Position.Y - desiredHeight) > FARM_SETTINGS.heightTolerance then
            hrp.CFrame = CFrame.new(
                hrp.Position.X,
                desiredHeight,
                hrp.Position.Z,
                hrp.CFrame.LookVector.X,
                0,
                hrp.CFrame.LookVector.Z
            )
        end
    end
end

-- Função otimizada de movimento com voo suave
local function moveToTarget(target)
    if not target or not target:FindFirstChild("HumanoidRootPart") then return false end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    -- Obtém a posição de ataque (seja do grupo ou do alvo individual)
    local targetPos = GroupingSystem.groupingPoint or target.HumanoidRootPart.Position
    local attackPosition = Vector3.new(
        targetPos.X,
        targetPos.Y + FARM_SETTINGS.height,
        targetPos.Z
    )

    -- Calcula distância até o alvo
    local distance = (attackPosition - hrp.Position).Magnitude
    
    -- Se estiver muito próximo, considera que chegou
    if distance < FARM_SETTINGS.attackRange then
        -- Mantém a posição olhando para o alvo
        hrp.CFrame = CFrame.new(
            hrp.Position,
            Vector3.new(targetPos.X, hrp.Position.Y, targetPos.Z)
        )
        return true
    end

    -- Movimento suave usando Lerp
    local newPosition = hrp.Position:Lerp(attackPosition, FARM_SETTINGS.flySpeed)
    hrp.CFrame = CFrame.new(newPosition, targetPos)
    
    -- Retorna false para continuar o movimento
    return false
end

-- Adicionar VirtualInputManager
local vim = game:GetService("VirtualInputManager")

-- Função para verificar se a arma está equipada
local function isWeaponEquipped()
    local tool = character:FindFirstChildOfClass("Tool")
    return tool ~= nil
end

-- Função para equipar arma com verificação
local function equipWeapon()
    if isWeaponEquipped() or tick() - lastEquipAttempt < COMBAT_SETTINGS.weaponEquipTime then
        return true
    end
    
    lastEquipAttempt = tick()
    local vim = game:GetService("VirtualInputManager")
    
    -- Pressiona a tecla 1
    vim:SendKeyEvent(true, Enum.KeyCode.One, false, game)
    task.wait(0.1)
    vim:SendKeyEvent(false, Enum.KeyCode.One, false, game)
    
    -- Espera a arma equipar
    local equipStart = tick()
    repeat
        task.wait()
    until isWeaponEquipped() or tick() - equipStart > COMBAT_SETTINGS.weaponEquipTime
    
    return isWeaponEquipped()
end

-- Função modificada para sequência de ataque mais precisa
local function performAttackSequence()
    if not equipWeapon() then return false end
    
    -- Verifica se está no alcance correto
    local target = findNearestBandit()
    if not target then return false end
    
    local distance = (target.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude
    if distance > ATTACK_RANGE then return false end
    
    -- Garante que está olhando para o alvo
    local targetPos = target.HumanoidRootPart.Position
    character.HumanoidRootPart.CFrame = CFrame.lookAt(
        character.HumanoidRootPart.Position,
        Vector3.new(targetPos.X, character.HumanoidRootPart.Position.Y, targetPos.Z)
    )
    
    -- Sequência de ataques
    if isWeaponEquipped() then
        for i = 1, 3 do
            vim:SendMouseButtonEvent(0, 0, 0, true, game, 1)
            task.wait(COMBAT_SETTINGS.attackDelay)
            vim:SendMouseButtonEvent(0, 0, 0, false, game, 1)
            task.wait(COMBAT_SETTINGS.attackDelay)
        end
        
        task.wait(COMBAT_SETTINGS.comboDelay)
        return true
    end
    
    return false
end

-- Sistema de combate aprimorado com verificações adicionais
local function handleCombat(target)
    if not target or not FarmState.active then return false end
    
    local humanoid = target:FindFirstChild("Humanoid")
    if not humanoid or not humanoid.Parent then return false end
    
    -- Verifica se o alvo ainda está vivo e válido
    if humanoid.Health <= 0 or not target:IsDescendantOf(game) then
        return false
    end
    
    -- Move e ataca apenas se chegou na posição
    if moveToTarget(target) then
        return performAttackSequence()
    end
    
    return true -- Continua tentando se mover
end

-- Farm loop corrigido com verificações de segurança adicionais
local function farmLoop()
    if not FarmState.active then return end

    -- Verifica alvo atual com proteções contra nil
    if FarmState.currentTarget and 
       FarmState.currentTarget:IsDescendantOf(game) then
        
        local humanoid = FarmState.currentTarget:FindFirstChild("Humanoid")
        if humanoid and humanoid.Health > 0 and humanoid.MaxHealth > 0 then
            -- Calcula proporção de vida com proteção
            local healthRatio = humanoid.Health/humanoid.MaxHealth
            
            -- Só continua atacando se tiver vida suficiente
            if healthRatio > 0 then
                if handleCombat(FarmState.currentTarget) then
                    return
                end
            end
        end
    end

    -- Procura novo alvo com verificações de segurança
    local newTarget = findNearestBandit()
    if newTarget and newTarget:FindFirstChild("HumanoidRootPart") then
        FarmState.currentTarget = newTarget
        FarmState.attackStartTime = tick()
        
        -- Atualiza altura com verificação de segurança
        local targetHeight = newTarget.HumanoidRootPart.Position.Y + FARM_SETTINGS.height
        FarmState.originalHeight = targetHeight
        
        -- Define altura mínima caso algo dê errado
        if FarmState.originalHeight < 10 then
            FarmState.originalHeight = character.HumanoidRootPart.Position.Y + FARM_SETTINGS.height
        end
    else
        -- Reseta estado se não encontrar alvo válido
        FarmState.currentTarget = nil
        FarmState.originalHeight = character.HumanoidRootPart.Position.Y + FARM_SETTINGS.height
    end
end

-- Toggle do farm melhorado
local function toggleFarm()
    FarmState.active = not FarmState.active
    
    if FarmState.active then
        -- Ativa farm
        toggleButton.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
        toggleButton.Text = "Parar Farm"
        statusLabel.Text = "Status: Ativo"
        
        -- Limpa conexão anterior se existir
        if FarmState.connection then
            FarmState.connection:Disconnect()
        end
        
        -- Nova conexão
        FarmState.connection = RunService.Heartbeat:Connect(function()
            if character and character:FindFirstChild("HumanoidRootPart") then
                maintainHeight()
                farmLoop()
            end
        end)
    else
        -- Desativa farm
        toggleButton.BackgroundColor3 = Color3.fromRGB(85, 170, 255)
        toggleButton.Text = "Iniciar Farm"
        statusLabel.Text = "Status: Desativado"
        
        -- Limpa estado
        if FarmState.connection then
            FarmState.connection:Disconnect()
            FarmState.connection = nil
        end
        FarmState.currentTarget = nil
        FarmState.attackStartTime = 0
        FarmState.attacking = false
    end
end

-- Conecta o botão
toggleButton.MouseButton1Click:Connect(toggleFarm)

-- Conecta botão de agrupamento
groupButton.MouseButton1Click:Connect(function()
    GroupingSystem:toggleGrouping()
    if not GroupingSystem.isGrouping then
        GroupingSystem:cleanup()
    end
end)

-- Interface arrastável
local dragging = false
local dragStart = nil
local startPos = nil

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

game:GetService("UserInputService").InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Limpeza ao desconectar
player.CharacterRemoving:Connect(function()
    if farming then
        toggleFarm()
    end
end)

-- Adiciona variável para controle da conexão
local farmConnection = nil

-- Adiciona evento para monitorar mudanças no equipamento
character.ChildAdded:Connect(function(child)
    if child:IsA("Tool") then
        weaponEquipped = true
        lastEquipAttempt = 0
    end
end)

character.ChildRemoved:Connect(function(child)
    if child:IsA("Tool") then
        weaponEquipped = false
    end
end)

-- Limpeza melhorada
local function cleanup()
    FarmState.active = false
    if FarmState.connection then
        FarmState.connection:Disconnect()
        FarmState.connection = nil
    end
    FarmState.currentTarget = nil
    PositionSystem:cleanup()
    BanditController:cleanup()
    GroupingSystem:cleanup()
    toggleButton.BackgroundColor3 = Color3.fromRGB(85, 170, 255)
    toggleButton.Text = "Iniciar Farm"
    statusLabel.Text = "Status: Desativado"
    BanditController.cleanup()
end

-- Eventos de limpeza
game:GetService("Players").LocalPlayer.CharacterRemoving:Connect(cleanup)
game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    cleanup()
end)

game:GetService("Players").LocalPlayer.CharacterRemoving:Connect(function()
    if farmConnection then
        farmConnection:Disconnect()
        farmConnection = nil
    end
    farming = false
    toggleButton.BackgroundColor3 = Color3.fromRGB(85, 170, 255)
    toggleButton.Text = "Iniciar Farm"
    statusLabel.Text = "Status: Desativado"
end)
