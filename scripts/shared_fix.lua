local function fadeOut(obj)
    -- Ignora UICorner e outros objetos que não suportam transparência
    if obj:IsA("UICorner") then return end
    
    local properties = {}
    
    -- Propriedades específicas para cada tipo de objeto
    if obj:IsA("Frame") or obj:IsA("TextButton") or obj:IsA("ScrollingFrame") then
        properties.BackgroundTransparency = 1
    end
    
    if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
        properties.TextTransparency = 1
    end
    
    if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
        properties.ImageTransparency = 1
    end
    
    -- Só cria o tween se houver propriedades para animar
    if next(properties) then
        return tweenService:Create(obj, TweenInfo.new(0.5), properties)
    end
end

-- Na função de fechamento:
closeButton.MouseButton1Click:Connect(function()
    local tweens = {}
    for _, obj in ipairs(mainFrame:GetDescendants()) do
        local tween = fadeOut(obj)
        if tween then -- Só adiciona se retornou um tween
            table.insert(tweens, tween)
            tween:Play()
        end
    end
    
    -- Anima o frame principal por último
    tweenService:Create(mainFrame, TweenInfo.new(0.5), {
        BackgroundTransparency = 1
    }):Play()
    
    -- Remove após todas as animações
    task.delay(0.6, function()
        screenGui:Destroy()
    end)
end)
