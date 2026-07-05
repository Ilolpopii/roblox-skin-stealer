-- ============================================================
--  SKIN STEALER v8.0 (С НАСТРОЙКАМИ)
--  - Полная кастомизация
--  - Смена клавиши открытия
--  - Сохранение настроек
-- ============================================================

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- === НАСТРОЙКИ ПО УМОЛЧАНИЮ ===
local DEFAULT_SETTINGS = {
    OpenKey = "RightControl",      -- Клавиша открытия
    Visibility = "Все видят",
    AutoStealOnJoin = false,
    AutoStealAll = false,
    Notifications = true,
    Theme = "Фиолетовый",
    AutoUpdateChance = true,
    ShowStatusInChat = false,
    SoundOnSteal = true,
    AutoSaveSkin = false,
}

-- === ЗАГРУЗКА СОХРАНЕННЫХ НАСТРОЕК ===
local function LoadSettings()
    local success, data = pcall(function()
        return game:GetService("HttpService"):JSONDecode(
            player:GetAttribute("SkinStealerSettings") or "{}"
        )
    end)
    
    if success and data then
        for key, value in pairs(data) do
            if DEFAULT_SETTINGS[key] ~= nil then
                DEFAULT_SETTINGS[key] = value
            end
        end
    end
    return DEFAULT_SETTINGS
end

local SETTINGS = LoadSettings()

-- === СОХРАНЕНИЕ НАСТРОЕК ===
local function SaveSettings()
    pcall(function()
        player:SetAttribute("SkinStealerSettings", 
            game:GetService("HttpService"):JSONEncode(SETTINGS)
        )
    end)
end

-- === ПОИСК КЛАВИШИ ПО НАЗВАНИЮ ===
local function GetKeyByName(name)
    for _, key in pairs(Enum.KeyCode:GetEnumItems()) do
        if key.Name == name then
            return key
        end
    end
    return Enum.KeyCode.RightControl
end

-- === ЦВЕТОВЫЕ ТЕМЫ ===
local THEMES = {
    Фиолетовый = {
        Primary = Color3.fromRGB(150, 0, 255),
        Secondary = Color3.fromRGB(200, 50, 255),
        Dark = Color3.fromRGB(20, 0, 30),
        Glow = Color3.fromRGB(180, 0, 255),
    },
    Синий = {
        Primary = Color3.fromRGB(0, 100, 255),
        Secondary = Color3.fromRGB(50, 150, 255),
        Dark = Color3.fromRGB(0, 20, 40),
        Glow = Color3.fromRGB(0, 150, 255),
    },
    Розовый = {
        Primary = Color3.fromRGB(255, 0, 150),
        Secondary = Color3.fromRGB(255, 80, 200),
        Dark = Color3.fromRGB(40, 0, 20),
        Glow = Color3.fromRGB(255, 0, 200),
    },
    Зеленый = {
        Primary = Color3.fromRGB(0, 255, 100),
        Secondary = Color3.fromRGB(50, 255, 150),
        Dark = Color3.fromRGB(0, 30, 10),
        Glow = Color3.fromRGB(0, 255, 150),
    },
}

local function GetTheme()
    return THEMES[SETTINGS.Theme] or THEMES["Фиолетовый"]
end

-- === СОЗДАНИЕ ГЛАВНОГО GUI ===
local function CreateMainGUI()
    local colors = GetTheme()
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "SkinStealerGUI"
    gui.Parent = player.PlayerGui
    gui.ResetOnSpawn = false
    gui.Enabled = false
    
    -- Основной фрейм
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 700, 0, 600)
    frame.Position = UDim2.new(0.5, -350, 0.5, -300)
    frame.BackgroundColor3 = colors.Dark
    frame.BackgroundTransparency = 0.05
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true
    frame.Parent = gui
    
    -- Неоновая рамка
    local glowFrame = Instance.new("Frame")
    glowFrame.Size = UDim2.new(1, 4, 1, 4)
    glowFrame.Position = UDim2.new(0, -2, 0, -2)
    glowFrame.BackgroundColor3 = colors.Glow
    glowFrame.BackgroundTransparency = 0.5
    glowFrame.BorderSizePixel = 0
    glowFrame.Parent = frame
    
    -- Заголовок
    local titleFrame = Instance.new("Frame")
    titleFrame.Size = UDim2.new(1, 0, 0, 45)
    titleFrame.BackgroundColor3 = colors.Primary
    titleFrame.BackgroundTransparency = 0.2
    titleFrame.BorderSizePixel = 0
    titleFrame.Parent = frame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.7, 0, 1, 0)
    title.Position = UDim2.new(0.05, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "✦ SKIN STEALER v8.0 ✦"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = titleFrame
    
    -- Кнопка настроек (шестеренка)
    local settingsBtn = Instance.new("TextButton")
    settingsBtn.Size = UDim2.new(0.08, 0, 0.8, 0)
    settingsBtn.Position = UDim2.new(0.87, 0, 0.1, 0)
    settingsBtn.BackgroundColor3 = colors.Secondary
    settingsBtn.Text = "⚙️"
    settingsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    settingsBtn.TextScaled = true
    settingsBtn.Font = Enum.Font.GothamBold
    settingsBtn.BorderSizePixel = 0
    settingsBtn.Parent = titleFrame
    
    -- === ПАНЕЛЬ БЫСТРЫХ ДЕЙСТВИЙ ===
    local perksFrame = Instance.new("Frame")
    perksFrame.Size = UDim2.new(0.9, 0, 0.1, 0)
    perksFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
    perksFrame.BackgroundColor3 = colors.Dark
    perksFrame.BackgroundTransparency = 0.3
    perksFrame.BorderSizePixel = 1
    perksFrame.BorderColor3 = colors.Secondary
    perksFrame.Parent = frame
    
    local perks = {
        {text = "🎲 Рандом", callback = function() StealRandom() end},
        {text = "👥 Все", callback = function() StealAll() end},
        {text = "💾 Сохранить", callback = function() SaveCurrentSkin() end},
        {text = "📂 Загрузить", callback = function() LoadSkinFromLibrary() end},
        {text = "🔄 Сброс", callback = function() ResetSkin() end},
    }
    
    for i, perk in ipairs(perks) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.18, 0, 0.8, 0)
        btn.Position = UDim2.new(0.02 + (i-1) * 0.195, 0, 0.1, 0)
        btn.BackgroundColor3 = colors.Primary
        btn.Text = perk.text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextScaled = true
        btn.Font = Enum.Font.GothamBold
        btn.BorderSizePixel = 0
        btn.Parent = perksFrame
        btn.MouseButton1Click:Connect(perk.callback)
    end
    
    -- === ПОЛЕ ПОИСКА ===
    local searchFrame = Instance.new("Frame")
    searchFrame.Size = UDim2.new(0.85, 0, 0.06, 0)
    searchFrame.Position = UDim2.new(0.075, 0, 0.23, 0)
    searchFrame.BackgroundColor3 = colors.Dark
    searchFrame.BackgroundTransparency = 0.5
    searchFrame.BorderSizePixel = 2
    searchFrame.BorderColor3 = colors.Primary
    searchFrame.Parent = frame
    
    local searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(0.7, -10, 1, 0)
    searchBox.Position = UDim2.new(0.02, 0, 0, 0)
    searchBox.BackgroundTransparency = 1
    searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    searchBox.Text = "🔮 Введите ник..."
    searchBox.TextWrapped = true
    searchBox.Font = Enum.Font.Gotham
    searchBox.ClearTextOnFocus = true
    searchBox.Parent = searchFrame
    
    local searchBtn = Instance.new("TextButton")
    searchBtn.Size = UDim2.new(0.25, 0, 0.8, 0)
    searchBtn.Position = UDim2.new(0.73, 0, 0.1, 0)
    searchBtn.BackgroundColor3 = colors.Primary
    searchBtn.Text = "🔍 ИСКАТЬ"
    searchBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    searchBtn.TextScaled = true
    searchBtn.Font = Enum.Font.GothamBold
    searchBtn.BorderSizePixel = 0
    searchBtn.Parent = searchFrame
    
    -- === РЕЗУЛЬТАТЫ ===
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(0.9, 0, 0.32, 0)
    scrollFrame.Position = UDim2.new(0.05, 0, 0.32, 0)
    scrollFrame.BackgroundColor3 = colors.Dark
    scrollFrame.BackgroundTransparency = 0.3
    scrollFrame.BorderSizePixel = 1
    scrollFrame.BorderColor3 = colors.Secondary
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.ScrollBarImageColor3 = colors.Primary
    scrollFrame.Parent = frame
    
    -- === СТАТУС ===
    local statusFrame = Instance.new("Frame")
    statusFrame.Size = UDim2.new(0.9, 0, 0.05, 0)
    statusFrame.Position = UDim2.new(0.05, 0, 0.68, 0)
    statusFrame.BackgroundColor3 = colors.Dark
    statusFrame.BackgroundTransparency = 0.5
    statusFrame.BorderSizePixel = 1
    statusFrame.BorderColor3 = colors.Secondary
    statusFrame.Parent = frame
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, 0, 1, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "💜 Готов к работе"
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    statusLabel.TextScaled = true
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.Parent = statusFrame
    
    -- === НИЖНЯЯ ПАНЕЛЬ ===
    local bottomFrame = Instance.new("Frame")
    bottomFrame.Size = UDim2.new(0.9, 0, 0.18, 0)
    bottomFrame.Position = UDim2.new(0.05, 0, 0.76, 0)
    bottomFrame.BackgroundColor3 = colors.Dark
    bottomFrame.BackgroundTransparency = 0.5
    bottomFrame.BorderSizePixel = 1
    bottomFrame.BorderColor3 = colors.Secondary
    bottomFrame.Parent = frame
    
    -- Переключатель видимости
    local visibilityBtn = Instance.new("TextButton")
    visibilityBtn.Size = UDim2.new(0.22, 0, 0.4, 0)
    visibilityBtn.Position = UDim2.new(0.02, 0, 0.05, 0)
    visibilityBtn.BackgroundColor3 = colors.Primary
    visibilityBtn.Text = "👁️ Все видят"
    visibilityBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    visibilityBtn.TextScaled = true
    visibilityBtn.Font = Enum.Font.GothamBold
    visibilityBtn.BorderSizePixel = 0
    visibilityBtn.Parent = bottomFrame
    
    -- Автокража
    local autoStealBtn = Instance.new("TextButton")
    autoStealBtn.Size = UDim2.new(0.22, 0, 0.4, 0)
    autoStealBtn.Position = UDim2.new(0.27, 0, 0.05, 0)
    autoStealBtn.BackgroundColor3 = colors.Primary
    autoStealBtn.Text = "🔄 Авто: Выкл"
    autoStealBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    autoStealBtn.TextScaled = true
    autoStealBtn.Font = Enum.Font.GothamBold
    autoStealBtn.BorderSizePixel = 0
    autoStealBtn.Parent = bottomFrame
    
    -- Уведомления
    local notifBtn = Instance.new("TextButton")
    notifBtn.Size = UDim2.new(0.22, 0, 0.4, 0)
    notifBtn.Position = UDim2.new(0.52, 0, 0.05, 0)
    notifBtn.BackgroundColor3 = colors.Primary
    notifBtn.Text = "🔔 Увед: Вкл"
    notifBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    notifBtn.TextScaled = true
    notifBtn.Font = Enum.Font.GothamBold
    notifBtn.BorderSizePixel = 0
    notifBtn.Parent = bottomFrame
    
    -- Инфо
    local infoBtn = Instance.new("TextButton")
    infoBtn.Size = UDim2.new(0.22, 0, 0.4, 0)
    infoBtn.Position = UDim2.new(0.77, 0, 0.05, 0)
    infoBtn.BackgroundColor3 = colors.Secondary
    infoBtn.Text = "ℹ️ Инфо"
    infoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    infoBtn.TextScaled = true
    infoBtn.Font = Enum.Font.GothamBold
    infoBtn.BorderSizePixel = 0
    infoBtn.Parent = bottomFrame
    
    -- Индикатор клавиши
    local keyIndicator = Instance.new("TextLabel")
    keyIndicator.Size = UDim2.new(0.45, 0, 0.35, 0)
    keyIndicator.Position = UDim2.new(0.02, 0, 0.55, 0)
    keyIndicator.BackgroundColor3 = colors.Dark
    keyIndicator.BackgroundTransparency = 0.5
    keyIndicator.BorderSizePixel = 1
    keyIndicator.BorderColor3 = colors.Primary
    keyIndicator.Text = "⌨️ Открытие: " .. SETTINGS.OpenKey
    keyIndicator.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyIndicator.TextScaled = true
    keyIndicator.Font = Enum.Font.Gotham
    keyIndicator.Parent = bottomFrame
    
    -- Кнопка смены клавиши
    local changeKeyBtn = Instance.new("TextButton")
    changeKeyBtn.Size = UDim2.new(0.2, 0, 0.35, 0)
    changeKeyBtn.Position = UDim2.new(0.5, 0, 0.55, 0)
    changeKeyBtn.BackgroundColor3 = colors.Primary
    changeKeyBtn.Text = "🔄 Сменить"
    changeKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    changeKeyBtn.TextScaled = true
    changeKeyBtn.Font = Enum.Font.GothamBold
    changeKeyBtn.BorderSizePixel = 0
    changeKeyBtn.Parent = bottomFrame
    
    -- === МЕНЮ НАСТРОЕК (ОВЕРЛЕЙ) ===
    local settingsOverlay = Instance.new("Frame")
    settingsOverlay.Size = UDim2.new(0.85, 0, 0.7, 0)
    settingsOverlay.Position = UDim2.new(0.075, 0, 0.15, 0)
    settingsOverlay.BackgroundColor3 = colors.Dark
    settingsOverlay.BackgroundTransparency = 0.1
    settingsOverlay.BorderSizePixel = 2
    settingsOverlay.BorderColor3 = colors.Glow
    settingsOverlay.Visible = false
    settingsOverlay.Parent = frame
    
    -- Заголовок настроек
    local settingsTitle = Instance.new("TextLabel")
    settingsTitle.Size = UDim2.new(1, 0, 0.08, 0)
    settingsTitle.BackgroundColor3 = colors.Primary
    settingsTitle.BackgroundTransparency = 0.3
    settingsTitle.Text = "⚙️ НАСТРОЙКИ"
    settingsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    settingsTitle.TextScaled = true
    settingsTitle.Font = Enum.Font.GothamBold
    settingsTitle.Parent = settingsOverlay
    
    -- Контейнер для настроек (скролл)
    local settingsScroll = Instance.new("ScrollingFrame")
    settingsScroll.Size = UDim2.new(0.95, 0, 0.82, 0)
    settingsScroll.Position = UDim2.new(0.025, 0, 0.1, 0)
    settingsScroll.BackgroundColor3 = colors.Dark
    settingsScroll.BackgroundTransparency = 0.5
    settingsScroll.BorderSizePixel = 0
    settingsScroll.CanvasSize = UDim2.new(0, 0, 0, 450)
    settingsScroll.Parent = settingsOverlay
    
    -- Список настроек
    local settingsList = {}
    local settingConfigs = {
        {key = "AutoStealOnJoin", label = "Автокража при входе", type = "toggle"},
        {key = "AutoStealAll", label = "Автокража у всех", type = "toggle"},
        {key = "Notifications", label = "Уведомления", type = "toggle"},
        {key = "AutoUpdateChance", label = "Автообновление шанса", type = "toggle"},
        {key = "ShowStatusInChat", label = "Статус в чат", type = "toggle"},
        {key = "SoundOnSteal", label = "Звук при краже", type = "toggle"},
        {key = "AutoSaveSkin", label = "Автосохранение скина", type = "toggle"},
        {key = "Theme", label = "Тема", type = "dropdown", options = {"Фиолетовый", "Синий", "Розовый", "Зеленый"}},
    }
    
    local function CreateSettingItem(config, index)
        local item = Instance.new("Frame")
        item.Size = UDim2.new(1, 0, 0, 40)
        item.Position = UDim2.new(0, 0, 0, (index-1) * 45 + 5)
        item.BackgroundColor3 = colors.Dark
        item.BackgroundTransparency = 0.5
        item.BorderSizePixel = 0
        item.Parent = settingsScroll
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.5, 0, 1, 0)
        label.Position = UDim2.new(0.02, 0, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = config.label
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextScaled = true
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = item
        
        if config.type == "toggle" then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0.15, 0, 0.7, 0)
            btn.Position = UDim2.new(0.82, 0, 0.15, 0)
            btn.BackgroundColor3 = SETTINGS[config.key] and colors.Success or colors.Danger
            btn.Text = SETTINGS[config.key] and "Вкл" or "Выкл"
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.TextScaled = true
            btn.Font = Enum.Font.GothamBold
            btn.BorderSizePixel = 0
            btn.Parent = item
            btn.MouseButton1Click:Connect(function()
                SETTINGS[config.key] = not SETTINGS[config.key]
                btn.BackgroundColor3 = SETTINGS[config.key] and colors.Success or colors.Danger
                btn.Text = SETTINGS[config.key] and "Вкл" or "Выкл"
                SaveSettings()
                statusLabel.Text = "✅ " .. config.label .. ": " .. (SETTINGS[config.key] and "Вкл" or "Выкл")
            end)
            settingsList[config.key] = btn
            
        elseif config.type == "dropdown" then
            local dropdown = Instance.new("TextButton")
            dropdown.Size = UDim2.new(0.2, 0, 0.7, 0)
            dropdown.Position = UDim2.new(0.77, 0, 0.15, 0)
            dropdown.BackgroundColor3 = colors.Primary
            dropdown.Text = SETTINGS[config.key] or config.options[1]
            dropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
            dropdown.TextScaled = true
            dropdown.Font = Enum.Font.GothamBold
            dropdown.BorderSizePixel = 0
            dropdown.Parent = item
            
            local currentIndex = 1
            for i, opt in ipairs(config.options) do
                if opt == SETTINGS[config.key] then
                    currentIndex = i
                    break
                end
            end
            
            dropdown.MouseButton1Click:Connect(function()
                currentIndex = currentIndex % #config.options + 1
                SETTINGS[config.key] = config.options[currentIndex]
                dropdown.Text = SETTINGS[config.key]
                SaveSettings()
                statusLabel.Text = "🎨 Тема: " .. SETTINGS.Theme
                -- Пересоздаем GUI если меняется тема
                if config.key == "Theme" then
                    gui:Destroy()
                    gui, searchBox, scrollFrame, statusLabel, visibilityBtn,
                    autoStealBtn, notifBtn, infoBtn, changeKeyBtn, keyIndicator,
                    settingsBtn, settingsOverlay = CreateMainGUI()
                    gui.Enabled = true
                end
            end)
            settingsList[config.key] = dropdown
        end
    end
    
    for i, config in ipairs(settingConfigs) do
        CreateSettingItem(config, i)
    end
    
    -- Кнопка закрытия настроек
    local closeSettingsBtn = Instance.new("TextButton")
    closeSettingsBtn.Size = UDim2.new(0.15, 0, 0.06, 0)
    closeSettingsBtn.Position = UDim2.new(0.8, 0, 0.92, 0)
    closeSettingsBtn.BackgroundColor3 = colors.Danger
    closeSettingsBtn.Text = "✕ Закрыть"
    closeSettingsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeSettingsBtn.TextScaled = true
    closeSettingsBtn.Font = Enum.Font.GothamBold
    closeSettingsBtn.BorderSizePixel = 0
    closeSettingsBtn.Parent = settingsOverlay
    closeSettingsBtn.MouseButton1Click:Connect(function()
        settingsOverlay.Visible = false
    end)
    
    -- === ОБРАБОТЧИКИ ===
    settingsBtn.MouseButton1Click:Connect(function()
        settingsOverlay.Visible = not settingsOverlay.Visible
        if settingsOverlay.Visible then
            settingsScroll.CanvasSize = UDim2.new(0, 0, 0, #settingConfigs * 45 + 10)
        end
    end)
    
    -- Смена клавиши
    local waitingForKey = false
    changeKeyBtn.MouseButton1Click:Connect(function()
        waitingForKey = not waitingForKey
        changeKeyBtn.Text = waitingForKey and "⏳ Нажми клавишу..." or "🔄 Сменить"
        keyIndicator.Text = waitingForKey and "⏳ Ожидание нажатия..." or "⌨️ Открытие: " .. SETTINGS.OpenKey
    end)
    
    -- Отслеживание нажатия для смены клавиши
    game:GetService("UserInputService").InputBegan:Connect(function(input)
        if input.KeyCode ~= Enum.KeyCode.Unknown and waitingForKey then
            SETTINGS.OpenKey = input.KeyCode.Name
            SaveSettings()
            waitingForKey = false
            changeKeyBtn.Text = "🔄 Сменить"
            keyIndicator.Text = "⌨️ Открытие: " .. SETTINGS.OpenKey
            statusLabel.Text = "✅ Клавиша изменена на: " .. SETTINGS.OpenKey
        end
    end)
    
    -- Возвращаем все компоненты
    return gui, searchBox, scrollFrame, statusLabel, visibilityBtn, 
           autoStealBtn, notifBtn, infoBtn, changeKeyBtn, keyIndicator,
           settingsBtn, settingsOverlay
end

-- === СОЗДАНИЕ GUI ===
local gui, searchBox, scrollFrame, statusLabel, visibilityBtn, 
      autoStealBtn, notifBtn, infoBtn, changeKeyBtn, keyIndicator,
      settingsBtn, settingsOverlay = CreateMainGUI()

-- ============================================================
-- === ВСЕ ФУНКЦИИ (из предыдущих версий) ===
-- ============================================================

-- (Здесь вставляются все функции из предыдущих версий: 
--  StealSkin, SearchPlayers, SaveCurrentSkin, LoadSkinFromLibrary,
--  StealRandom, StealAll, ResetSkin, Notify, и т.д.)
-- Для краткости они опущены, но должны быть в полной версии

-- === ОТКРЫТИЕ ПО НАСТРОЕННОЙ КЛАВИШЕ ===
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == GetKeyByName(SETTINGS.OpenKey) then
        gui.Enabled = not gui.Enabled
        if gui.Enabled then
            statusLabel.Text = "💜 Нажми " .. SETTINGS.OpenKey .. " для закрытия"
            keyIndicator.Text = "⌨️ Открытие: " .. SETTINGS.OpenKey
        end
    end
end)

-- === ИНФО ===
infoBtn.MouseButton1Click:Connect(function()
    Notify("ℹ️ Skin Stealer v8.0", 
           "Клавиша: " .. SETTINGS.OpenKey .. 
           "\nТема: " .. SETTINGS.Theme ..
           "\nВсего украдено: " .. STATS.Success)
end)

print("[Xeno] Skin Stealer v8.0 loaded!")
print("⌨️ Клавиша открытия: " .. SETTINGS.OpenKey)
print("💜 Нажми " .. SETTINGS.OpenKey .. " для открытия меню")