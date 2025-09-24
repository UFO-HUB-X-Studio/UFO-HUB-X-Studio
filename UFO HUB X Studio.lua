--========================================================
-- UFO HUB X — FULL (now with Home button + AFK switch)
--========================================================

-------------------- Services --------------------
local TS      = game:GetService("TweenService")
local UIS     = game:GetService("UserInputService")
local CG      = game:GetService("CoreGui")
local Camera  = workspace.CurrentCamera
local Players = game:GetService("Players")
local LP      = Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")

-------------------- CONFIG --------------------
local LOGO_ID      = 112676905543996  -- โลโก้
local X_OFFSET     = 18               -- ขยับ UI ใหญ่ไปขวา (+ขวา, -ซ้าย)
local Y_OFFSET     = -40              -- ขยับ UI ใหญ่ขึ้น/ลง (ลบ=ขึ้น, บวก=ลง)
local TOGGLE_GAP   = 60               -- ระยะห่าง ปุ่ม ↔ ขอบซ้าย UI ใหญ่
local TOGGLE_DY    = -70              -- ยกปุ่มขึ้นจากกึ่งกลางแนวตั้ง (ลบ=สูงขึ้น)
local CENTER_TWEEN = true
local CENTER_TIME  = 0.25
local TOGGLE_DOCKED = true            -- เริ่มแบบเกาะซ้าย

-- AFK
local INTERVAL_SEC = 5*60             -- กี่วินาทีต่อหนึ่งครั้งคลิก (5 นาที)

-------------------- Helpers --------------------
local function safeParent(gui)
    local ok=false
    if syn and syn.protect_gui then pcall(function() syn.protect_gui(gui) end) end
    if gethui then ok = pcall(function() gui.Parent = gethui() end) end
    if not ok then gui.Parent = CG end
end
local function make(class, props, children)
    local o = Instance.new(class)
    for k,v in pairs(props or {}) do o[k] = v end
    for _,c in ipairs(children or {}) do c.Parent = o end
    return o
end
local function tweenPos(obj, pos)
    TS:Create(obj, TweenInfo.new(CENTER_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = pos}):Play()
end

-------------------- Theme --------------------
local ACCENT = Color3.fromRGB(0,255,140)
local BG     = Color3.fromRGB(12,12,12)
local FG     = Color3.fromRGB(230,230,230)
local SUB    = Color3.fromRGB(22,22,22)
local D_GREY = Color3.fromRGB(16,16,16)
local OFFCOL = Color3.fromRGB(210,60,60)

-------------------- ScreenGuis --------------------
local mainGui   = make("ScreenGui", {Name="UFOHubX_Main", ResetOnSpawn=false, ZIndexBehavior=Enum.ZIndexBehavior.Sibling}, {})
local toggleGui = make("ScreenGui", {Name="UFOHubX_Toggle", ResetOnSpawn=false, ZIndexBehavior=Enum.ZIndexBehavior.Sibling}, {})
safeParent(mainGui); safeParent(toggleGui)

-------------------- MAIN WINDOW --------------------
local main = make("Frame", {
    Name="Main", Parent=mainGui, Size=UDim2.new(0,620,0,380),
    BackgroundColor3=BG, BorderSizePixel=0, Active=true, Draggable=true
},{
    make("UICorner",{CornerRadius=UDim.new(0,16)}),
    make("UIStroke",{Thickness=2, Color=ACCENT, Transparency=0.08}),
    make("UIGradient",{Rotation=90, Color=ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(18,18,18)),
        ColorSequenceKeypoint.new(1, BG)
    }})
})

-- Top bar ------------------------------------------------
local top = make("Frame", {Parent=main, Size=UDim2.new(1,0,0,50), BackgroundTransparency=1},{})

make("ImageLabel", {
    Parent=top, BackgroundTransparency=1, Image="rbxassetid://"..LOGO_ID,
    Size=UDim2.new(0,26,0,26), Position=UDim2.new(0,16,0,12)
}, {})

-- ชื่อ 2 สี: UFO (เขียว) + HUB X (ขาว)
local titleFrame = make("Frame", {
    Parent=top, BackgroundTransparency=1, Size=UDim2.new(1,-160,1,0),
    Position=UDim2.new(0,50,0,0)
},{})
make("UIListLayout", {Parent=titleFrame, FillDirection=Enum.FillDirection.Horizontal,
    HorizontalAlignment=Enum.HorizontalAlignment.Left, VerticalAlignment=Enum.VerticalAlignment.Center,
    Padding=UDim.new(0,8)}, {})
make("TextLabel", {Parent=titleFrame, BackgroundTransparency=1, AutomaticSize=Enum.AutomaticSize.X,
    Size=UDim2.new(0,0,1,0), Font=Enum.Font.GothamBold, TextSize=22, Text="UFO", TextColor3=ACCENT}, {})
make("TextLabel", {Parent=titleFrame, BackgroundTransparency=1, AutomaticSize=Enum.AutomaticSize.X,
    Size=UDim2.new(0,0,1,0), Font=Enum.Font.GothamBold, TextSize=22, Text="HUB X", TextColor3=Color3.new(1,1,1)}, {})

local underline = make("Frame", {Parent=top, Size=UDim2.new(1,0,0,2), Position=UDim2.new(0,0,1,-2), BackgroundColor3=ACCENT},{
    make("UIGradient",{Transparency=NumberSequence.new{
        NumberSequenceKeypoint.new(0,0.7), NumberSequenceKeypoint.new(0.5,0), NumberSequenceKeypoint.new(1,0.7)
    }})
})

local function neonButton(parent, text, xOff)
    return make("TextButton", {
        Parent=parent, Text=text, Font=Enum.Font.GothamBold, TextSize=18, TextColor3=FG,
        BackgroundColor3=SUB, Size=UDim2.new(0,36,0,36), Position=UDim2.new(1,xOff,0,7), AutoButtonColor=false
    },{make("UICorner",{CornerRadius=UDim.new(0,10)}), make("UIStroke",{Color=ACCENT, Transparency=0.75})})
end
local btnMini  = neonButton(top, "–", -88)
local btnClose = neonButton(top, "",  -46)
btnClose.BackgroundColor3 = Color3.fromRGB(210,35,50)
local function mkX(rot)
    local b = Instance.new("Frame")
    b.Parent=btnClose; b.AnchorPoint=Vector2.new(0.5,0.5)
    b.Position=UDim2.new(0.5,0,0.5,0); b.Size=UDim2.new(0,18,0,2)
    b.BackgroundColor3=Color3.new(1,1,1); b.BorderSizePixel=0; b.Rotation=rot
    Instance.new("UICorner", b).CornerRadius=UDim.new(0,1)
end
mkX(45); mkX(-45)

-- Sidebar ------------------------------------------------
local left = make("Frame", {Parent=main, Size=UDim2.new(0,170,1,-60), Position=UDim2.new(0,12,0,55),
    BackgroundColor3=Color3.fromRGB(18,18,18)},
    {make("UICorner",{CornerRadius=UDim.new(0,12)}), make("UIStroke",{Color=ACCENT, Transparency=0.85})})
make("UIListLayout",{Parent=left, Padding=UDim.new(0,10)})

-- Content ------------------------------------------------
local content = make("Frame", {Parent=main, Size=UDim2.new(1,-210,1,-70), Position=UDim2.new(0,190,0,60),
    BackgroundColor3=D_GREY},
    {make("UICorner",{CornerRadius=UDim.new(0,12)}), make("UIStroke",{Color=ACCENT, Transparency=0.8})})

local pgHome = make("Frame",{Parent=content, Size=UDim2.new(1,-20,1,-20), Position=UDim2.new(0,10,0,10),
    BackgroundTransparency=1, Visible=true}, {})

-------------------- Toggle Button (dock + drag) --------------------
local btnToggle = make("ImageButton", {
    Parent=toggleGui, Size=UDim2.new(0,64,0,64),
    BackgroundColor3=SUB, AutoButtonColor=false, ClipsDescendants=true,
    Active=true, Draggable=true
},{
    make("UICorner",{CornerRadius=UDim.new(0,10)}),
    make("UIStroke",{Color=ACCENT, Thickness=2, Transparency=0.1})
})
make("ImageLabel", {
    Parent=btnToggle, BackgroundTransparency=1,
    Size=UDim2.new(1,-6,1,-6), Position=UDim2.new(0,3,0,3),
    Image="rbxassetid://"..LOGO_ID, ScaleType=Enum.ScaleType.Stretch
},{ make("UICorner",{CornerRadius=UDim.new(0,8)}) })

-------------------- Behaviors --------------------
local hidden=false
local function setHidden(s) hidden=s; mainGui.Enabled = not hidden end
btnToggle.MouseButton1Click:Connect(function() setHidden(not hidden) end)
UIS.InputBegan:Connect(function(i,gp) if not gp and i.KeyCode==Enum.KeyCode.RightControl then setHidden(not hidden) end end)

-- ย่อ/ขยาย
local collapsed=false
local originalSize = main.Size
btnMini.MouseButton1Click:Connect(function()
    collapsed = not collapsed
    if collapsed then
        left.Visible=false; content.Visible=false; underline.Visible=false
        TS:Create(main, TweenInfo.new(.2), {Size=UDim2.new(0,620,0,56)}):Play()
        btnMini.Text="▢"
    else
        left.Visible=true; content.Visible=true; underline.Visible=true
        TS:Create(main, TweenInfo.new(.2), {Size=originalSize}):Play()
        btnMini.Text="–"
    end
end)
btnClose.MouseButton1Click:Connect(function() setHidden(true) end)

-------------------- จัดกลาง + dock ปุ่ม --------------------
local function dockToggleToMain()
    local mPos  = main.AbsolutePosition
    local mSize = main.AbsoluteSize
    local tX = math.floor(mPos.X - btnToggle.AbsoluteSize.X - TOGGLE_GAP)
    local tY = math.floor(mPos.Y + (mSize.Y - btnToggle.AbsoluteSize.Y)/2 + TOGGLE_DY)
    btnToggle.Position = UDim2.fromOffset(tX, tY)
end

local function centerMain(animated)
    local vp = Camera.ViewportSize
    local targetMain = UDim2.fromOffset(
        math.floor((vp.X - main.AbsoluteSize.X)/2) + X_OFFSET,
        math.floor((vp.Y - main.AbsoluteSize.Y)/2) + Y_OFFSET
    )
    if animated and CENTER_TWEEN then tweenPos(main, targetMain) else main.Position = targetMain end
    if TOGGLE_DOCKED then dockToggleToMain() end
end

centerMain(false)
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function() centerMain(false) end)
main.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 and TOGGLE_DOCKED then
        dockToggleToMain()
    end
end)
btnToggle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        TOGGLE_DOCKED = false -- ลากเอง → ปลด dock
    end
end)
UIS.InputBegan:Connect(function(i,gp)
    if gp then return end
    if i.KeyCode==Enum.KeyCode.F9 then
        TOGGLE_DOCKED = true; centerMain(true)
    elseif i.KeyCode==Enum.KeyCode.F8 then
        TOGGLE_DOCKED = not TOGGLE_DOCKED
        if TOGGLE_DOCKED then dockToggleToMain() end
    end
end)
-- ===== Force order: Home(1) -> Shop(2) -> Fishing(3) =====
local function forceLeftOrder()
    if not left then return end

    -- ensure list exists and uses LayoutOrder
    local list = left:FindFirstChildOfClass("UIListLayout")
    if not list then
        list = Instance.new("UIListLayout")
        list.Parent = left
    end
    list.FillDirection = Enum.FillDirection.Vertical
    list.Padding = UDim.new(0, 10)
    list.HorizontalAlignment = Enum.HorizontalAlignment.Center
    list.VerticalAlignment   = Enum.VerticalAlignment.Top
    list.SortOrder = Enum.SortOrder.LayoutOrder  -- สำคัญ!

    -- fetch our buttons
    local btnHome    = left:FindFirstChild("UFOX_HomeBtn")
    local btnShop    = left:FindFirstChild("UFOX_ShopBtn")
    local btnFishing = left:FindFirstChild("UFOX_FishingBtn")

    -- set layout orders
    if btnHome    then btnHome.LayoutOrder    = 1 end
    if btnShop    then btnShop.LayoutOrder    = 2 end
    if btnFishing then btnFishing.LayoutOrder = 3 end

    -- push other stray children (ถ้ามี) ให้ไปท้ายสุด
    local bump = 100
    for _,child in ipairs(left:GetChildren()) do
        if child:IsA("GuiObject") and not (child == btnHome or child == btnShop or child == btnFishing or child:IsA("UIListLayout") or child:IsA("UICorner")) then
            child.LayoutOrder = bump
            bump += 1
        end
    end
end

-- เรียกทันที + เรียกซ้ำเมื่อมีการเพิ่มของใหม่
forceLeftOrder()
left.ChildAdded:Connect(function() task.defer(forceLeftOrder) end)
----------------------------------------------------------------
-- 🏠 HOME BUTTON (ยาวขึ้น + ขอบเขียวคม)
----------------------------------------------------------------
do
    -- ลบของเก่าถ้ามี
    local old = left:FindFirstChild("UFOX_HomeBtn")
    if old then old:Destroy() end

    -- ปุ่ม: ยาวแทบเต็มกรอบ (เหลือขอบซ้ายขวา 2px)
    local btnHome = make("TextButton",{
        Name="UFOX_HomeBtn", Parent=left, AutoButtonColor=false,
        Size=UDim2.new(1,-4,0,48),      -- ✅ ยาวขึ้น
        Position=UDim2.fromOffset(2,10),-- ✅ ลงล่างนิด/ชิดซ้ายนิด
        BackgroundColor3=SUB, Font=Enum.Font.GothamBold,
        TextSize=16, TextColor3=FG, Text="", ClipsDescendants=true
    },{
        make("UICorner",{CornerRadius=UDim.new(0,10)}),
        make("UIStroke",{                 -- ✅ ขอบเขียวกลับมาและคมชัด
            Color=ACCENT, Thickness=2, Transparency=0,
            ApplyStrokeMode=Enum.ApplyStrokeMode.Border
        })
    })

    -- ไอคอน + ข้อความภายในปุ่ม
    local row = make("Frame",{
        Parent=btnHome, BackgroundTransparency=1,
        Size=UDim2.new(1,-16,1,0), Position=UDim2.new(0,8,0,0)
    },{
        make("UIListLayout",{
            FillDirection=Enum.FillDirection.Horizontal, Padding=UDim.new(0,8),
            HorizontalAlignment=Enum.HorizontalAlignment.Left,
            VerticalAlignment=Enum.VerticalAlignment.Center
        })
    })
    make("TextLabel",{Parent=row, BackgroundTransparency=1, Size=UDim2.fromOffset(20,20),
        Font=Enum.Font.GothamBold, TextSize=16, Text="🌍", TextColor3=FG})
    make("TextLabel",{Parent=row, BackgroundTransparency=1, Size=UDim2.new(1,-36,1,0),
        Font=Enum.Font.GothamBold, TextSize=16, Text="ตำแหน่ง",
        TextXAlignment=Enum.TextXAlignment.Left, TextColor3=FG})

    -- เอฟเฟกต์ hover เล็ก ๆ
    btnHome.MouseEnter:Connect(function()
        TS:Create(btnHome, TweenInfo.new(0.08), {BackgroundColor3 = Color3.fromRGB(32,32,32)}):Play()
    end)
    btnHome.MouseLeave:Connect(function()
        TS:Create(btnHome, TweenInfo.new(0.12), {BackgroundColor3 = SUB}):Play()
    end)

    -- คลิกเปิดหน้า Home (ถ้ามีฟังก์ชันภายนอก)
    btnHome.MouseButton1Click:Connect(function()
        if typeof(_G.UFO_OpenHomePage)=="function" then
            pcall(_G.UFO_OpenHomePage)
        else
            -- กะพริบ content แจ้งผู้ใช้
            TS:Create(content, TweenInfo.new(0.10), {BackgroundColor3 = Color3.fromRGB(24,24,24)}):Play()
            task.delay(0.12, function()
                TS:Create(content, TweenInfo.new(0.10), {BackgroundColor3 = Color3.fromRGB(16,16,16)}):Play()
            end)
        end
    end)
end
----------------------------------------------------------------
-- 🎯 GET POSITION BUTTON (on-screen)
----------------------------------------------------------------
local Players = game:GetService("Players")
local TS      = TS or game:GetService("TweenService")
local LP      = Players.LocalPlayer

-- เผื่อไม่มี helper
local function make(class, props, kids)
    local o = Instance.new(class)
    for k,v in pairs(props or {}) do o[k] = v end
    for _,c in ipairs(kids or {}) do c.Parent = o end
    return o
end

-- สีธีม fallback
local ACCENT = ACCENT or Color3.fromRGB(0,255,140)
local SUB    = SUB    or Color3.fromRGB(22,22,22)
local FG     = FG     or Color3.fromRGB(235,235,235)

-- ล้างปุ่มเดิม (ถ้ามี)
local old = content:FindFirstChild("UFOX_GetPosBtn")
if old then old:Destroy() end

-- ปุ่มมุมขวาบนภายใน content
local btn = make("TextButton",{
    Name="UFOX_GetPosBtn",
    Parent = content,
    AnchorPoint = Vector2.new(1,0),
    Position = UDim2.new(1,-14,0,10),    -- ชิดขวา-บนเล็กน้อย
    Size = UDim2.fromOffset(140,30),
    BackgroundColor3 = SUB,
    AutoButtonColor = false,
    Text = "📍 Get Position",
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextColor3 = FG,
    ZIndex = 20,
},{
    make("UICorner",{CornerRadius = UDim.new(0,10)}),
    make("UIStroke",{
        Color = ACCENT, Thickness = 2, Transparency = 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    })
})

-- Toast แจ้งเตือนสั้น ๆ
local toast = make("TextLabel",{
    Name="Toast",
    Parent=content,
    AnchorPoint=Vector2.new(1,0),
    Position=UDim2.new(1,-14,0,46),
    Size=UDim2.fromOffset(220,24),
    BackgroundColor3=Color3.fromRGB(20,20,20),
    Text="",
    TextColor3=FG, Font=Enum.Font.Gotham, TextSize=13,
    Visible=false
},{
    make("UICorner",{CornerRadius=UDim.new(0,8)}),
    make("UIStroke",{Color=ACCENT,Thickness=1,Transparency=0.3})
})

local function showToast(msg)
    toast.Text = msg
    toast.Visible = true
    toast.TextTransparency = 1
    toast.BackgroundTransparency = 0.2
    TS:Create(toast, TweenInfo.new(0.12), {TextTransparency=0}):Play()
    task.delay(1.4, function()
        TS:Create(toast, TweenInfo.new(0.2), {TextTransparency=1}):Play()
        task.wait(0.22)
        toast.Visible = false
    end)
end

local function fmtVec3(v)
    return string.format("%.3f, %.3f, %.3f", v.X, v.Y, v.Z)
end

btn.MouseButton1Click:Connect(function()
    local char = LP.Character or LP.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local pos = hrp.Position
    local cf  = hrp.CFrame

    -- ข้อความพร้อมใช้งาน
    local posStr = "Vector3.new("..fmtVec3(pos)..")"
    local cfStr  = tostring(cf) -- รูปแบบ CFrame.new(...)

    print("🌍 Position:", pos)
    print("🧭 CFrame:", cf)
    print("Copy-ready:")
    print(posStr)
    print(cfStr)

    -- ลองคัดลอกคลิปบอร์ด (ถ้ามีฟังก์ชันให้ใช้)
    local copied = false
    if typeof(setclipboard) == "function" then
        local bundle = posStr .. "\n" .. cfStr
        pcall(function()
            setclipboard(bundle)
            copied = true
        end)
    end

    showToast(copied and "✅ Copied Position & CFrame!" or "✅ Printed to Output")
end)

-- เอฟเฟกต์ hover
btn.MouseEnter:Connect(function()
    TS:Create(btn, TweenInfo.new(0.08), {BackgroundColor3=Color3.fromRGB(32,32,32)}):Play()
end)
btn.MouseLeave:Connect(function()
    TS:Create(btn, TweenInfo.new(0.12), {BackgroundColor3=SUB}):Play()
end)
----------------------------------------------------------------
-- 📍 SAVE & WARP POSITIONS (UI + copy as Lua config)
-- - ปุ่มเซฟชื่อจุด + แสดงรายการจุดที่บันทึก
-- - กด 'TP' เพื่อวาร์ป, '✕' เพื่อลบ, 'Copy' เพื่อคัดลอกเป็นโค้ด
-- - เก็บไว้ในรันไทม์: _G.UFOX_SavedSpots
----------------------------------------------------------------
local Players = game:GetService("Players")
local TS      = TS or game:GetService("TweenService")
local LP      = Players.LocalPlayer

-- สี fallback
local ACCENT = ACCENT or Color3.fromRGB(0,255,140)
local SUB    = SUB    or Color3.fromRGB(22,22,22)
local FG     = FG     or Color3.fromRGB(235,235,235)

-- helper
local function make(class, props, kids)
    local o=Instance.new(class); for k,v in pairs(props or {}) do o[k]=v end
    for _,c in ipairs(kids or {}) do c.Parent=o end; return o
end

-- ถ้ามีของเก่า ลบทิ้ง
local old = content:FindFirstChild("UFOX_PosPanel"); if old then old:Destroy() end

-- =========== UI PANEL ===========
local panel = make("Frame",{
    Name="UFOX_PosPanel", Parent=content, AnchorPoint=Vector2.new(1,0),
    Position=UDim2.new(1,-14,0,10), Size=UDim2.fromOffset(300,220),
    BackgroundColor3=Color3.fromRGB(18,18,18)
},{
    make("UICorner",{CornerRadius=UDim.new(0,10)}),
    make("UIStroke",{Color=ACCENT,Thickness=2,Transparency=0.1})
})
-- หัวข้อ + ช่องตั้งชื่อ + ปุ่ม
make("TextLabel",{
    Parent=panel, BackgroundTransparency=1, Position=UDim2.fromOffset(12,8),
    Size=UDim2.new(1,-24,0,20), Text="Saved Warps", TextXAlignment=Enum.TextXAlignment.Left,
    Font=Enum.Font.GothamBold, TextSize=15, TextColor3=FG
})
local nameBox = make("TextBox",{
    Parent=panel, Position=UDim2.fromOffset(12,34), Size=UDim2.new(1,-124,0,28),
    BackgroundColor3=SUB, PlaceholderText="ชื่อจุด (เช่น Spawn/Shop/Bank)",
    Text="", Font=Enum.Font.Gotham, TextSize=13, TextColor3=FG, PlaceholderColor3=Color3.fromRGB(160,160,160),
    ClearTextOnFocus=false
},{
    make("UICorner",{CornerRadius=UDim.new(0,8)}),
    make("UIStroke",{Color=ACCENT,Thickness=1,Transparency=0.4})
})
local btnSave = make("TextButton",{
    Parent=panel, Position=UDim2.new(1,-104,0,34), Size=UDim2.fromOffset(44,28),
    BackgroundColor3=SUB, Text="Save", Font=Enum.Font.GothamBold, TextSize=13, TextColor3=FG, AutoButtonColor=false
},{
    make("UICorner",{CornerRadius=UDim.new(0,8)}),
    make("UIStroke",{Color=ACCENT,Thickness=1,Transparency=0.3})
})
local btnCopy = make("TextButton",{
    Parent=panel, Position=UDim2.new(1,-52,0,34), Size=UDim2.fromOffset(44,28),
    BackgroundColor3=SUB, Text="Copy", Font=Enum.Font.GothamBold, TextSize=13, TextColor3=FG, AutoButtonColor=false
},{
    make("UICorner",{CornerRadius=UDim.new(0,8)}),
    make("UIStroke",{Color=ACCENT,Thickness=1,Transparency=0.3})
})

-- ลิสต์จุด (เลื่อนขึ้นลงได้)
local listHolder = make("Frame",{
    Parent=panel, Position=UDim2.fromOffset(12,70), Size=UDim2.new(1,-24,1,-82),
    BackgroundTransparency=1
},{})
local scroll = make("ScrollingFrame",{
    Parent=listHolder, Size=UDim2.fromScale(1,1), CanvasSize=UDim2.new(0,0,0,0),
    BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=4, ScrollBarImageColor3=ACCENT
},{
    make("UIListLayout",{Padding=UDim.new(0,8), SortOrder=Enum.SortOrder.LayoutOrder})
})

-- Toast
local toast = make("TextLabel",{
    Parent=panel, AnchorPoint=Vector2.new(0.5,0), Position=UDim2.new(0.5,0,1,6),
    Size=UDim2.fromOffset(260,22), BackgroundColor3=Color3.fromRGB(20,20,20),
    Text="", TextColor3=FG, Font=Enum.Font.Gotham, TextSize=12, Visible=false
},{
    make("UICorner",{CornerRadius=UDim.new(0,8)}),
    make("UIStroke",{Color=ACCENT,Thickness=1,Transparency=0.4})
})
local function showToast(msg)
    toast.Text=msg; toast.Visible=true; toast.TextTransparency=1
    TS:Create(toast, TweenInfo.new(0.1), {TextTransparency=0}):Play()
    task.delay(1.2,function()
        TS:Create(toast, TweenInfo.new(0.15), {TextTransparency=1}):Play()
        task.wait(0.16); toast.Visible=false
    end)
end

-- =========== DATA ===========
local saved = _G.UFOX_SavedSpots or {}
_G.UFOX_SavedSpots = saved

local function serializeCFrame(cf)
    local c={cf:GetComponents()}
    return string.format(
        "CFrame.new(%.3f, %.3f, %.3f, %.6f, %.6f, %.6f, %.6f, %.6f, %.6f, %.6f, %.6f, %.6f)",
        table.unpack(c)
    )
end

local function rebuildList()
    scroll:ClearAllChildren()
    make("UIListLayout",{Parent=scroll, Padding=UDim.new(0,8), SortOrder=Enum.SortOrder.LayoutOrder})
    for i,spot in ipairs(saved) do
        local row = make("Frame",{
            Parent=scroll, Size=UDim2.new(1,0,0,30), BackgroundColor3=SUB
        },{
            make("UICorner",{CornerRadius=UDim.new(0,8)}),
            make("UIStroke",{Color=ACCENT,Thickness=1,Transparency=0.5})
        })
        make("TextLabel",{
            Parent=row, BackgroundTransparency=1, Position=UDim2.fromOffset(10,0),
            Size=UDim2.new(1,-120,1,0), Text=string.format("%d) %s",i,spot.name),
            TextXAlignment=Enum.TextXAlignment.Left, Font=Enum.Font.Gotham, TextSize=13, TextColor3=FG
        })

        local btnTP = make("TextButton",{
            Parent=row, AnchorPoint=Vector2.new(1,0.5), Position=UDim2.new(1,-64,0.5,0),
            Size=UDim2.fromOffset(44,22), BackgroundColor3=Color3.fromRGB(30,30,30),
            Text="TP", Font=Enum.Font.GothamBold, TextSize=12, TextColor3=FG, AutoButtonColor=false
        },{
            make("UICorner",{CornerRadius=UDim.new(0,6)}),
            make("UIStroke",{Color=ACCENT,Thickness=1,Transparency=0.3})
        })
        local btnDel = make("TextButton",{
            Parent=row, AnchorPoint=Vector2.new(1,0.5), Position=UDim2.new(1,-12,0.5,0),
            Size=UDim2.fromOffset(22,22), BackgroundColor3=Color3.fromRGB(40,22,22),
            Text="✕", Font=Enum.Font.GothamBold, TextSize=12, TextColor3=Color3.fromRGB(255,120,120),
            AutoButtonColor=false
        },{
            make("UICorner",{CornerRadius=UDim.new(0,6)}),
            make("UIStroke",{Color=ACCENT,Thickness=1,Transparency=0.3})
        })

        btnTP.MouseButton1Click:Connect(function()
            local char = LP.Character or LP.CharacterAdded:Wait()
            local hrp  = char:WaitForChild("HumanoidRootPart")
            hrp.CFrame = spot.cf
            showToast("✅ Teleported to "..spot.name)
        end)
        btnDel.MouseButton1Click:Connect(function()
            table.remove(saved,i); rebuildList(); showToast("🗑️ Deleted spot")
        end)
    end
    -- ปรับ Canvas ให้เลื่อนพอดี
    task.defer(function()
        local layout = scroll:FindFirstChildOfClass("UIListLayout")
        local ab = layout and layout.AbsoluteContentSize or Vector2.new(0,0)
        scroll.CanvasSize = UDim2.new(0,0,0,ab.Y+8)
    end)
end

-- =========== BUTTONS ===========
btnSave.MouseButton1Click:Connect(function()
    local char = LP.Character or LP.CharacterAdded:Wait()
    local hrp  = char:WaitForChild("HumanoidRootPart")
    local nm   = (nameBox.Text ~= "" and nameBox.Text) or ("Spot "..tostring(#saved+1))
    table.insert(saved, {name=nm, cf=hrp.CFrame})
    rebuildList()
    showToast("💾 Saved: "..nm)
end)

btnCopy.MouseButton1Click:Connect(function()
    if #saved == 0 then showToast("ℹ️ ยังไม่มีจุดที่บันทึก"); return end
    local lines = {"return {"}
    for _,s in ipairs(saved) do
        table.insert(lines, string.format("  { name = %q, cf = %s },", s.name, serializeCFrame(s.cf)))
    end
    table.insert(lines,"}")
    local bundle = table.concat(lines,"\n")

    if typeof(setclipboard)=="function" then
        local ok,err = pcall(function() setclipboard(bundle) end)
        showToast(ok and "✅ Copied config to clipboard" or "⚠️ Copy ไม่ได้ ดู Output")
    else
        showToast("ℹ️ ไม่มี setclipboard — ดู Output")
    end
    print("---- Saved Warp Config ----\n"..bundle.."\n---------------------------")
end)

-- เล็ก ๆ น้อย ๆ hover เอฟเฟกต์
for _,b in ipairs({btnSave,btnCopy}) do
    b.MouseEnter:Connect(function() TS:Create(b,TweenInfo.new(0.08),{BackgroundColor3=Color3.fromRGB(34,34,34)}):Play() end)
    b.MouseLeave:Connect(function() TS:Create(b,TweenInfo.new(0.12),{BackgroundColor3=SUB}):Play() end)
end

-- เริ่มต้น
rebuildList()
----------------------------------------------------------------
-- 🛒 Shop Tab (แยกเป็นปุ่มที่ 2 + สลับหน้าได้จริง)
-- ต้องมี: left, content, TS, ACCENT, SUB, FG (มี fallback)
----------------------------------------------------------------
local TS = TS or game:GetService("TweenService")
local ACCENT = ACCENT or Color3.fromRGB(0,255,140)
local SUB    = SUB    or Color3.fromRGB(22,22,22)
local FG     = FG     or Color3.fromRGB(235,235,235)

local function make(class, props, kids)
    local o=Instance.new(class); for k,v in pairs(props or {}) do o[k]=v end
    for _,c in ipairs(kids or {}) do c.Parent=o end; return o
end

-- ===== 1) เตรียม content & เพจ =====
if not content or not content.Parent then
    warn("[UFOX] content not found"); return
end

-- เพจ Home
local pgHome = content:FindFirstChild("pgHome")
if not pgHome then
    pgHome = make("Frame",{
        Name="pgHome", Parent=content, BackgroundTransparency=1,
        Size=UDim2.new(1,-20,1,-20), Position=UDim2.new(0,10,0,10), Visible=true
    },{})
end

-- เพจ Shop (ลบเก่าแล้วสร้างใหม่)
local oldPgShop = content:FindFirstChild("pgShop"); if oldPgShop then oldPgShop:Destroy() end
local pgShop = make("Frame",{
    Name="pgShop", Parent=content, BackgroundTransparency=1,
    Size=UDim2.new(1,-20,1,-20), Position=UDim2.new(0,10,0,10), Visible=false
},{})
make("TextLabel",{
    Parent=pgShop, BackgroundTransparency=1, Size=UDim2.new(1,0,0,28),
    Font=Enum.Font.GothamBold, TextSize=20, Text="🛒 Shop",
    TextColor3=FG, TextXAlignment=Enum.TextXAlignment.Left
},{})

-- 🔁 ย้ายคอนโทรลเดิม ๆ ของหน้า Home ให้ไปอยู่ใน pgHome
-- (ทุก Frame/Button/Label ที่เป็นลูกของ content แต่ไม่ใช่สองเพจนี้ → ย้ายเข้าหน้า Home)
for _,ch in ipairs(content:GetChildren()) do
    if ch ~= pgHome and ch ~= pgShop and ch:IsA("GuiObject") then
        ch.Parent = pgHome
    end
end

-- ===== 2) Sidebar layout =====
if not left or not left.Parent then
    warn("[UFOX] left sidebar not found"); return
end
local layout = left:FindFirstChildOfClass("UIListLayout")
if not layout then
    layout = make("UIListLayout",{
        Parent=left, Padding=UDim.new(0,10),
        FillDirection=Enum.FillDirection.Vertical,
        HorizontalAlignment=Enum.HorizontalAlignment.Center,
        VerticalAlignment=Enum.VerticalAlignment.Begin
    },{})
end
if not left:FindFirstChildOfClass("UIPadding") then
    make("UIPadding",{Parent=left, PaddingTop=UDim.new(0,14), PaddingLeft=UDim.new(0,8), PaddingRight=UDim.new(0,8)},{})
end

-- ===== 3) ปุ่ม Home (#1) =====
local btnHome = left:FindFirstChild("UFOX_HomeBtn")
if not btnHome then
    btnHome = make("TextButton",{
        Name="UFOX_HomeBtn", Parent=left, AutoButtonColor=false, Text="",
        Size=UDim2.new(1,-16,0,38), BackgroundColor3=SUB, ClipsDescendants=true,
        LayoutOrder=1
    },{
        make("UICorner",{CornerRadius=UDim.new(0,10)}),
        make("UIStroke",{Color=ACCENT, Thickness=2, Transparency=0}) -- ขอบเขียวคม
    })
    local row = make("Frame",{
        Parent=btnHome, BackgroundTransparency=1,
        Size=UDim2.new(1,-16,1,0), Position=UDim2.new(0,8,0,0)
    },{
        make("UIListLayout",{
            FillDirection=Enum.FillDirection.Horizontal, Padding=UDim.new(0,8),
            HorizontalAlignment=Enum.HorizontalAlignment.Left,
            VerticalAlignment=Enum.VerticalAlignment.Center
        })
    })
    make("TextLabel",{Parent=row, BackgroundTransparency=1, Size=UDim2.fromOffset(20,20),
        Font=Enum.Font.GothamBold, TextSize=16, Text="🏠", TextColor3=FG})
    make("TextLabel",{Parent=row, BackgroundTransparency=1, Size=UDim2.new(1,-36,1,0),
        Font=Enum.Font.GothamBold, TextSize=15, Text="Home",
        TextXAlignment=Enum.TextXAlignment.Left, TextColor3=FG})
end
btnHome.LayoutOrder = 1
btnHome.Size = UDim2.new(1,-16,0,38) -- ให้เท่ากันแน่ ๆ

-- ===== 4) ปุ่ม Shop (#2) =====
local oldShop = left:FindFirstChild("UFOX_ShopBtn"); if oldShop then oldShop:Destroy() end
local btnShop = make("TextButton",{
    Name="UFOX_ShopBtn", Parent=left, AutoButtonColor=false, Text="",
    Size=UDim2.new(1,-16,0,38), BackgroundColor3=SUB, ClipsDescendants=true,
    LayoutOrder=2
},{
    make("UICorner",{CornerRadius=UDim.new(0,10)}),
    make("UIStroke",{Color=ACCENT, Thickness=2, Transparency=0}) -- ขอบเขียวคม
})
local rowS = make("Frame",{
    Parent=btnShop, BackgroundTransparency=1,
    Size=UDim2.new(1,-16,1,0), Position=UDim2.new(0,8,0,0)
},{
    make("UIListLayout",{
        FillDirection=Enum.FillDirection.Horizontal, Padding=UDim.new(0,8),
        HorizontalAlignment=Enum.HorizontalAlignment.Left,
        VerticalAlignment=Enum.VerticalAlignment.Center
    })
})
make("TextLabel",{Parent=rowS, BackgroundTransparency=1, Size=UDim2.fromOffset(20,20),
    Font=Enum.Font.GothamBold, TextSize=16, Text="🛒", TextColor3=FG})
make("TextLabel",{Parent=rowS, BackgroundTransparency=1, Size=UDim2.new(1,-36,1,0),
    Font=Enum.Font.GothamBold, TextSize=15, Text="Shop",
    TextXAlignment=Enum.TextXAlignment.Left, TextColor3=FG})

-- ===== 5) สไตล์ + สลับหน้า =====
local function setBtnActive(btn, active)
    local stroke = btn:FindFirstChildOfClass("UIStroke")
    if active then
        TS:Create(btn, TweenInfo.new(0.10), {BackgroundColor3 = Color3.fromRGB(32,32,32)}):Play()
        if stroke then stroke.Transparency = 0 end
    else
        TS:Create(btn, TweenInfo.new(0.10), {BackgroundColor3 = SUB}):Play()
        if stroke then stroke.Transparency = 0 end -- ให้เห็นขอบตลอด
    end
end

local function ShowPage(name)
    local isShop = (name == "Shop")
    pgHome.Visible = not isShop
    pgShop.Visible = isShop
    setBtnActive(btnHome, not isShop)
    setBtnActive(btnShop, isShop)
end

-- กันผูกซ้ำ
if not btnHome:GetAttribute("UFOX_TabHooked") then
    btnHome:SetAttribute("UFOX_TabHooked", true)
    btnHome.MouseButton1Click:Connect(function()
        if typeof(_G.UFO_OpenHomePage)=="function" then pcall(_G.UFO_OpenHomePage) end
        ShowPage("Home")
    end)
end
btnShop.MouseButton1Click:Connect(function()
    ShowPage("Shop")
    if typeof(_G.UFO_OpenShopPage)=="function" then pcall(_G.UFO_OpenShopPage) end
end)

-- เริ่มที่ Home
ShowPage("Home")
----------------------------------------------------------------
-- 🧱 UFOX SIDEBAR NORMALIZER
-- - ยืดปุ่มให้กว้างเต็มแถบซ้าย (มีระยะขอบซ้าย/ขวาเท่ากัน)
-- - บังคับขอบสีเขียวติดถาวร
-- - รองรับปุ่ม: Home, Shop, Fishing (เพิ่มชื่อปุ่มอื่นได้)
----------------------------------------------------------------
local LEFT = left
local GREEN = Color3.fromRGB(0,255,140)
local TARGET_NAMES = {
    UFOX_HomeBtn   = true,
    UFOX_ShopBtn   = true,
    UFOX_FishingBtn= true, -- ✅ ปุ่มที่ 3: ตกปลา
}

if not LEFT then return end

-- ติดตั้ง UIListLayout + UIPadding ให้แถบซ้าย (ถ้ายังไม่มี)
local layout = LEFT:FindFirstChildOfClass("UIListLayout")
if not layout then
    layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    layout.VerticalAlignment = Enum.VerticalAlignment.Top
    layout.Padding = UDim.new(0,10)
    layout.Parent = LEFT
end
local pad = LEFT:FindFirstChildOfClass("UIPadding")
if not pad then
    pad = Instance.new("UIPadding")
    pad.Parent = LEFT
end
pad.PaddingLeft  = UDim.new(0,8)
pad.PaddingRight = UDim.new(0,8)
pad.PaddingTop   = UDim.new(0,8)

-- ฟังก์ชัน: ยืดปุ่ม + ใส่ขอบเขียว
local function styleButton(btn)
    if not btn or not btn.Parent then return end

    -- ยืดปุ่มให้เต็มกรอบซ้าย (กว้าง = 100% - padding, สูง 44px)
    btn.AnchorPoint = Vector2.new(0,0)
    btn.Position = UDim2.new(0,0,0,0)              -- ให้ layout จัดตำแหน่ง
    btn.Size = UDim2.new(1, 0, 0, 44)              -- ✅ กว้างเต็มแถบ
    btn.AutoButtonColor = false
    btn.ClipsDescendants = true

    -- ลบ Stroke เก่า แล้วใส่ขอบเขียวใหม่
    for _,c in ipairs(btn:GetChildren()) do
        if c:IsA("UIStroke") then c:Destroy() end
    end
    local stroke = Instance.new("UIStroke")
    stroke.Name = "UFOX_Border"
    stroke.Color = GREEN
    stroke.Thickness = 2
    stroke.Transparency = 0
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.LineJoinMode   = Enum.LineJoinMode.Round
    stroke.Parent = btn

    -- กันโดนโค้ดอื่นเปลี่ยนค่า → ตรวจซ้ำเป็นระยะสั้น ๆ
    if not btn:GetAttribute("UFOX_Lock") then
        btn:SetAttribute("UFOX_Lock", true)
        task.spawn(function()
            while btn.Parent and btn:GetAttribute("UFOX_Lock") do
                -- ย้ำขนาด/ขอบ
                if btn.Size ~= UDim2.new(1,0,0,44) then
                    btn.Size = UDim2.new(1,0,0,44)
                end
                if not stroke.Parent then
                    stroke.Parent = btn
                end
                stroke.Color = GREEN
                stroke.Thickness = 2
                stroke.Transparency = 0
                stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                task.wait(0.25)
            end
        end)
        btn.ChildAdded:Connect(function(c)
            if c:IsA("UIStroke") and c ~= stroke then c:Destroy() end
        end)
    end
end

-- ใช้กับปุ่มที่มีอยู่แล้ว
for _,name in ipairs({"UFOX_HomeBtn","UFOX_ShopBtn","UFOX_FishingBtn"}) do
    local b = LEFT:FindFirstChild(name)
    if b and b:IsA("TextButton") then styleButton(b) end
end

-- ถ้าปุ่มถูกสร้างใหม่ทีหลัง → จัดให้อัตโนมัติ
if not LEFT:GetAttribute("UFOX_SidebarNormalizerInstalled") then
    LEFT:SetAttribute("UFOX_SidebarNormalizerInstalled", true)
    LEFT.ChildAdded:Connect(function(child)
        if child:IsA("TextButton") and TARGET_NAMES[child.Name] then
            task.wait(0.05) -- เผื่อยังประกอบไม่เสร็จ
            styleButton(child)
        end
    end)
end
