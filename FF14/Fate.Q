[General]
SyntaxVersion=2
BeginHotkey=121
BeginHotkeyMod=0
PauseHotkey=0
PauseHotkeyMod=0
StopHotkey=123
StopHotkeyMod=0
RunOnce=1
EnableWindow=
MacroID=453c892e-ee11-4f39-a742-7439e38ff375
Description=Fate
Enable=1
AutoRun=0
[Repeat]
Type=0
Number=1
[SetupUI]
Type=1
QUI=Form1
[Relative]
SetupOCXFile=
[Comment]

[Script]
// QQ14 自动 Fate 脚本
// 建议：
//   1. 使用诗人
//   2. 召唤搭档（推荐奶妈）
//   3. 使用军票 / 部队特效
//   4. 关闭地图上不必要的标记减少干扰，如 宝箱、风景、风脉、自定义标记 等
// 开始运行脚本： F10
// 终止脚本运行： F12
// 虽然脚本对任意规格做了同比例自适应，但是可能会出现区域偏差的情况
// 推荐 MuMu模拟器窗口大小为 2560 x 1440 (开发是在此规格下测试的)

Dim EMULATOR                       // 定义全局模拟器对象
EMULATOR_WIN_NAME = "MuMu模拟器12"  // 模拟器窗口名字
MAX_RUN_TIME = 60000    // 自动寻路最大的超时时间（超时重新找 Fate）
MAX_FIGHT_TIME = 120    // 自动战斗最大的超时时间（超时重新找 Fate）

// 启动入口
Call main()


Function main()
    // 初始化模拟器窗体信息（位置与大小）
    InitElemulator(EMULATOR_WIN_NAME)
    
    Do While True

        // 打开地图
		Call openMap()

        // 检索 Fate 并自动寻路
        Call searchFate()
        
        // 检测是否到达目的地参战
        isGoal = joinToFate()

        // 开启自动战斗
        If isGoal Then
            Call autoFight()
        End If
    Loop
    
End Function


// 利用模拟器快捷键打开地图
Function openMap()
    KeyPress "M", 1
    Delay 2000

    // 缩小地图一次，把全图显示到屏幕中
    smallX = EMULATOR("Width") * 0.0383
    smallY = EMULATOR("Height") * 0.6923
    Call AccurateClick(smallX, smallY)
    Delay 2000
End Function


Function searchFate()
    Do While True
        TracePrint "正在检索【Fate】..."
        Delay 1000

        // 从地图的左上到右下检索第一个 Fate 位置
        mapSX = 0.1349    // 左上角 x 位置比例
        mapSY = 0.1666    // 左上角 y 位置比例
        mapEX = 0.7609    // 右下角 x 位置比例
        mapEY = 0.9479    // 右下角 y 位置比例
        fateColor = "C26BAB" // Fate 主颜色
        similarity = 0.8
        coords = FindAreaColor(mapSX, mapSY, mapEX, mapEY, fateColor, similarity)
        x = coords(0)
        y = coords(1)
        If x > 0 And y > 0 Then
            TracePrint "发现一个【Fate】坐标： (" & x & ", " & y & ")"
            Call AccurateClick(x, y)
            Delay 1000

            isRuning = autoRunToFate(x, y)
            If isRuning Then 
                Exit Do  // 进入自动寻路状态
            End If
        End If
    Loop
End Function


Function autoRunToFate(fateX, fateY)
    isRuning = False
    mode = 2          // 检索模式，从右下到左上
    similarity = 0.9

    // 相近地方有多个定位，可能出现危命【列表】
    offsetX = EMULATOR("Width") * 0.0377
    offsetY = EMULATOR("Height") * 0.2000
    listSX = fateX + offsetX        // 列表左上角 x 位置比例
    listSY = fateY - offsetY        // 列表左上角 y 位置比例
    listEX = fateX + offsetX * 10   // 列表右下角 x 位置比例
    listEY = fateY + offsetY        // 列表右下角 y 位置比例
    fateColor = "C36AA0"
    FindColorEx listSX, listSY, listEX, listEY, fateColor, mode, similarity, x, y
    If x > 0 And y > 0 Then
        TracePrint "在【危命列表】选择危命 ..."
        Call AccurateClick(x, y)
        Delay 1000
    End If

    // 【自动寻路】按钮
    offsetX = EMULATOR("Width") * 0.1741  // 2560 最远是 400px，400 对应位置比例是 0.1741
    offsetY = EMULATOR("Height") * 0.1508 // 1440 大概是 200px，200 对应位置比例是 0.1508
    btnSX = fateX               // 自动寻路左上角 x 位置比例
    btnSY = fateY - offsetY     // 自动寻路左上角 y 位置比例
    btnEX = fateX + offsetX     // 自动寻路右下角 x 位置比例
    btnEY = fateY               // 自动寻路右下角 y 位置比例
    runColor = "323F45"
    FindColorEx btnSX, btnSY, btnEX, btnEY, runColor, mode, similarity, x, y
    If x > 0 And y > 0 Then
        TracePrint "开始【自动寻路】 ..."
        Call AccurateClick(x, y)
        Delay 1000
        isRuning = True
    Else
        TracePrint "未找到【自动寻路】按钮！"
    End If

    // 地图右下角的水晶位置（说明点击自动寻路按钮失败，需要重新搜索）
    crySX = 0.0226    // 左上角 x 位置比例
    crySY = 0.8808    // 左上角 y 位置比例
    cryEX = 0.0531    // 右下角 x 位置比例
    cryEY = 0.9336    // 右下角 y 位置比例
    cryColor = "F5B633" // Fate 主颜色
    similarity = 0.8
    coords = FindAreaColor(mapSX, mapSY, mapEX, mapEY, fateColor, similarity)
    x = coords(0)
    y = coords(1)
    If x > 0 And y > 0 Then
        TracePrint "未点击到【自动寻路】按钮"
        isRuning = False
    End If

    autoRunToFate = isRuning
End Function



Function joinToFate()
    isGoal = False
    similarity = 0.8

    // 【参加】Fate 按钮
    btnSX = 0.7283      // 左上角 x 位置比例
    btnSY = 0.2149      // 左上角 y 位置比例
    btnEX = 0.8123      // 右下角 x 位置比例
    btnEY = 0.2549      // 右下角 y 位置比例
    btnColor = "4DA1C4"

    // 参加 fate 按钮旁边的 【<】 标签
    tagSX = 0.8080      // 左上角 x 位置比例
    tagSY = 0.1968      // 左上角 y 位置比例
    tagEX = 0.8280      // 右下角 x 位置比例
    tagEY = 0.2330      // 右下角 y 位置比例
    tagColor = "9EBCC3"
    
    runTime = 0
    Do While True
        TracePrint "正在【自动寻路】到 Fate..."
        Delay 5000  // 检测间隔拉长，避免点到过路的 Fate
        runTime = runTime + 5000
        If runTime > MAX_RUN_TIME Then
            TracePrint "超时还没走到目的地 ..."
            Exit Do     // 超过 1 分钟还没走到目的地，重新开始找 Fate
        End If

        tagCoords = FindAreaColor(tagSX, tagSY, tagEX, tagEY, tagColor, similarity)
        tagX = tagCoords(0)
        tagY = tagCoords(1)

        IF tagX > 0 And tagY > 0 Then

            btnCoords = FindAreaColor(btnSX, btnSY, btnEX, btnEY, btnColor, similarity)
            btnX = btnCoords(0)
            btnY = btnCoords(1)
            
            If btnX > 0 And btnY > 0 Then
                TracePrint "进入【Fate】范围，参加战斗！"
                Delay 3000  // 即时到达目的地也先等一下，自动寻路经常在目标 Fate 转弯导致脱离范围
                joinBtnX = EMULATOR("Width") * 0.7509
                joinBtnY = EMULATOR("Height") * 0.2300
                Call AccurateClick(joinBtnX, joinBtnY)
                Delay 1000
                isGoal = True
                Exit Do  // 进入战斗状态
            End If
        End If
    Loop
    joinToFate = isGoal
End Function


Function autoFight()
    cnt = 0
    Do While True
        TracePrint "正在自动战斗（诗人模式）..."
        Delay 1000

        // 诗人技能（打完一套循环 18 秒）
        if ArcherSkills() Then
            TracePrint "检测到战斗结束 ..."
            Exit Do
        End If

        // 超时战斗退出
        cnt = cnt + 1
        If cnt * 18 > MAX_FIGHT_TIME Then
            TracePrint "超时还没结束战斗 ..."
            Exit Do
        End If
    Loop
End Function


// 移动 + 平 A (1 秒)
Function NormalAttack(direct)
    If direct = "W" Then
        keyDown "W", 1          // 移动
        KeyPress "Up", 3        // 手动平 A
        Delay 1000
        KeyUp "W", 1
    End If

    If direct = "D" Then
        keyDown "D", 1
        KeyPress "Down", 3
        Delay 1000
        KeyUp "D", 1
    End If

    If direct = "S" Then
        keyDown "S", 1
        KeyPress "Up", 3
        Delay 1000
        KeyUp "S", 1
    End If

    If direct = "A" Then
        keyDown "A", 1
        KeyPress "Down", 3
        Delay 1000
        KeyUp "A", 1
    End If
End Function



// 打完一套循环需要 18 秒
Function ArcherSkills()
    MiddleClick 1           // 自动平 A

    // 猛者强击（+ATK）
    KeyPress "R", 1
    Delay 1000

    Call NormalAttack("W")
    if exitFate() Then
        MiddleClick 1       // 关闭自动平 A
        ArcherSkills = True
        Exit Function
    End If

    // 贤者的叙述谣 + 死亡箭雨
    KeyDown "4", 1
    Delay 200
    MoveTo 0, 0
    Delay 200
    KeyUp "4", 1
    Delay 1000
    KeyPress "Z", 1
    Delay 1000

    Call NormalAttack("D")
    if exitFate() Then
        MiddleClick 1       // 关闭自动平 A
        ArcherSkills = True
        Exit Function
    End If

    // 烈劲咬箭 + 死亡箭雨
    KeyPress "1", 1
    Delay 1000
    KeyPress "Z", 1
    Delay 1000

    Call NormalAttack("S")
    if exitFate() Then
        MiddleClick 1       // 关闭自动平 A
        ArcherSkills = True
        Exit Function
    End If

    // 影噬箭 + 死亡箭雨
    KeyPress "2", 1
    Delay 1000
    KeyPress "Z", 1
    Delay 1000

    Call NormalAttack("A")
    if exitFate() Then
        MiddleClick 1       // 关闭自动平 A
        ArcherSkills = True
        Exit Function
    End If

    // 致伤射击 + 死亡箭雨
    KeyPress "3", 1
    Delay 1000
    KeyPress "Z", 1
    Delay 1000

    Call NormalAttack("W")
    if exitFate() Then
        MiddleClick 1       // 关闭自动平 A
        ArcherSkills = True
        Exit Function
    End If

    // 绝锋箭 + 死亡箭雨
    KeyPress "5", 1
    Delay 1000
    KeyPress "Z", 1
    Delay 1000

    Call NormalAttack("S")
    if exitFate() Then
        MiddleClick 1       // 关闭自动平 A
        ArcherSkills = True
        Exit Function
    End If
    
    ArcherSkills = False
End Function


Function exitFate()
    isFin = finishFate()
    isDead = deadBack()
    exitFate = isFin Or isDead
End Function


Function finishFate()
    isFin = False
    similarity = 0.8

    // 完成 Fate【标题】文字
    tagSX = 0.4488      // 左上角 x 位置比例
    tagSY = 0.1606      // 左上角 y 位置比例
    tagEX = 0.5441      // 右下角 x 位置比例
    tagEY = 0.2556      // 右下角 y 位置比例
    succColor = "FF76E2" // 成功
    failColor = "FFAD7E" // 失败
    coords = FindAreaColor(tagSX, tagSY, tagEX, tagEY, succColor, similarity)
    x = coords(0)
    y = coords(1)
    If x > 0 And y > 0 Then
        // 成功完成 Fate
        Call clickFinFate()
        isFin = True
    Else
        
        // 失败完成 Fate
        coords = FindAreaColor(tagSX, tagSY, tagEX, tagEY, failColor, similarity)
        x = coords(0)
        y = coords(1)
        If x > 0 And y > 0 Then
            Call clickFinFate()
            isFin = True
        End If
    End If

    finishFate = isFin
End Function


// 完成 Fate 点击【退出危命】按钮
Function clickFinFate()
    btnSX = 0.6090      // 左上角 x 位置比例
    btnSY = 0.8627      // 左上角 y 位置比例
    btnEX = 0.7074      // 右下角 x 位置比例
    btnEY = 0.9057      // 右下角 y 位置比例
    btnColor = "659EB0"
    coords = FindAreaColor(btnSX, btnSY, btnEX, btnEY, btnColor, similarity)
    x = coords(0)
    y = coords(1)
    If x > 0 And y > 0 Then
        TracePrint "完成 Fate，【退出危命】任务 ..."
        Delay 2000
        Call RandomClick(x, y)
        Delay 3000
    End If
End Function


Function deadBack()
    isDead = False
    similarity = 0.9

    // 无法战斗【标题】（战斗画面颜色比较杂，多一次判断会更准确）
    btnSX = 0.2990      // 左上角 x 位置比例
    btnSY = 0.3061      // 左上角 y 位置比例
    btnEX = 0.6464      // 右下角 x 位置比例
    btnEY = 0.3582      // 右下角 y 位置比例
    btnColor = "212121"
    coords = FindAreaColor(btnSX, btnSY, btnEX, btnEY, btnColor, similarity)
    x = coords(0)
    y = coords(1)
    If x > 0 And y > 0 Then

        // 无法战斗【保留】按钮（战斗画面颜色比较杂，多一次判断会更准确）
        btnSX = 0.3413      // 左上角 x 位置比例
        btnSY = 0.6334      // 左上角 y 位置比例
        btnEX = 0.4418      // 右下角 x 位置比例
        btnEY = 0.6809      // 右下角 y 位置比例
        btnColor = "596C78"
        coords = FindAreaColor(btnSX, btnSY, btnEX, btnEY, btnColor, similarity)
        x = coords(0)
        y = coords(1)
        If x > 0 And y > 0 Then

            // 无法战斗【确认】按钮
            btnSX = 0.5816      // 左上角 x 位置比例
            btnSY = 0.6523      // 左上角 y 位置比例
            btnEX = 0.6774      // 右下角 x 位置比例
            btnEY = 0.8975      // 右下角 y 位置比例
            btnColor = "66A1B2"
            coords = FindAreaColor(btnSX, btnSY, btnEX, btnEY, btnColor, similarity)
            x = coords(0)
            y = coords(1)
            If x > 0 And y > 0 Then
                TracePrint "战斗死亡【确认】，返回水晶 ..."
                Delay 2000
                Call RandomClick(x, y)
                Delay 3000
                isDead = True
            End If
        End If
    End If

    deadBack = isDead
End Function



' 函数名称：InitElemulator
' 功能：初始化模拟器窗口的相关参数，并存储到全局变量 EMULATOR 中
' 参数：
'   win_name - 模拟器窗口的标题名称
' 实现：
'   1. 根据窗口标题查找窗口句柄。
'   2. 获取窗口的边框尺寸和坐标。
'   3. 计算窗口的宽度和高度。
'   4. 将窗口的相关信息存储到全局变量 EMULATOR 中，方便后续使用。
' 返回值：
'   无返回值（通过全局变量 EMULATOR 存储结果）
Function InitElemulator(win_name)
    TracePrint "模拟器窗口名字：" & win_name
    
    hwnd = Plugin.Window.Find(0, win_name)
    Call Plugin.Window.Active(hwnd)     // 激活模拟器窗口

    win_size = Plugin.Window.GetWindowRect(hwnd)
    TracePrint "模拟器窗口边框尺寸：" & win_size
    
    win_coords = Split(win_size, "|")
    win_lx = win_coords(0)
    win_ly = win_coords(1)
    win_rx = win_coords(2)
    win_ry = win_coords(3)
    TracePrint "模拟器窗口左上角坐标： (" & win_lx & ", " & win_ly & ")"
    TracePrint "模拟器窗口右下角坐标： (" & win_rx & ", " & win_ry & ")"
    
    win_w = win_rx - win_lx
    win_h = win_ry - win_ly
    TracePrint "模拟器窗口宽度：" & win_w
    TracePrint "模拟器窗口高度：" & win_h
    
    Set EMULATOR = CreateObject("Scripting.Dictionary")
    EMULATOR("Name") = win_name     // 模拟器窗口进程名称
    EMULATOR("Hwnd") = hwnd         // 模拟器窗口句柄
    EMULATOR("Left") = win_lx       // 模拟器窗口左上角在屏幕的 x 坐标
    EMULATOR("Top") = win_ly        // 模拟器窗口左上角在屏幕的 y 坐标
    EMULATOR("Right") = win_rx      // 模拟器窗口右下角在屏幕的 x 坐标
    EMULATOR("Bottom") = win_ry     // 模拟器窗口右下角在屏幕的 y 坐标
    EMULATOR("Width") = win_w       // 模拟器窗口宽度（不含边框，如 2560 实际为 2297 ）
    EMULATOR("Height") = win_h      // 模拟器窗口高度（不含边框，如 1440 实际为 1326 ）
End Function


' 函数名称：FindAreaColor
' 功能：在指定区域中 (psx, psy, pex, pey) 寻找颜色
' 参数：
'   psx - 区域起始坐标：相对于模拟器内部宽度的百分比
'   psy - 区域起始坐标：相对于模拟器内部高度的百分比
'   pex - 区域终止坐标：相对于模拟器内部宽度的百分比
'   pey - 区域终止坐标：相对于模拟器内部高度的百分比
'   hexColor - 目标颜色
'   similarity - 目标颜色相似度（0 完全不同，1 完全一样）
' 实现：
'   1. 在目标坐标的基础上，随机生成 -10 到 10 的偏移量。
'   2. 计算随机点击位置。
'   3. 移动鼠标到随机位置并执行左键点击。
Function FindAreaColor(psx, psy, pex, pey, hexColor, similarity)
    rsx = EMULATOR("Width") * psx       // 相对于模拟器内部的区域起始 X 坐标
    rsy = EMULATOR("Height") * psy      // 相对于模拟器内部的区域起始 Y 坐标
    rex = EMULATOR("Width") * pex       // 相对于模拟器内部的区域终止 X 坐标
    rey = EMULATOR("Height") * pey      // 相对于模拟器内部的区域终止 Y 坐标
    // TracePrint "搜索区域的相对范围： (" & rsx & ", " & rsy & ") - (" & rex & ", " & rey & ")"

    asx = EMULATOR("Left") + rsx        // 相对于屏幕的区域起始 X 坐标
    asy = EMULATOR("Top") + rsy         // 相对于屏幕的区域起始 Y 坐标
    aex = EMULATOR("Left") + rex        // 相对于屏幕的区域终止 X 坐标
    aey = EMULATOR("Top") + rey         // 相对于屏幕的区域终止 Y 坐标
    // TracePrint "搜索区域的绝对范围： (" & asx & ", " & asy & ") - (" & aex & ", " & aey & ")"

    mode = 0            // 检索模式，从左上到右下
    FindColorEx asx, asy, aex, aey, hexColor, mode, similarity, rstX, rstY

    Dim coords(2)
    coords(0) = rstX
    coords(1) = rstY
    FindAreaColor = coords
End Function


' 函数名称：RandomClick
' 功能：在指定坐标 (x, y) 附近随机偏移范围内点击鼠标左键
' 参数：
'   x - 鼠标目标位置的 x 坐标
'   y - 鼠标目标位置的 y 坐标
' 实现：
'   1. 在目标坐标的基础上，随机生成 -5 到 5 的偏移量。
'   2. 计算随机点击位置。
'   3. 移动鼠标到随机位置并执行左键点击。
Function RandomClick(x, y)
    // 定义偏移范围
    Dim offsetX, offsetY
    offsetX = Int(Rnd() * 11) - 5  // 随机生成 -5 到 5 的偏移量
    offsetY = Int(Rnd() * 11) - 5  // 随机生成 -5 到 5 的偏移量

    // 计算随机点击位置
    Dim clickX, clickY
    clickX = x + offsetX
    clickY = y + offsetY

    // 移动鼠标到随机位置并点击
    MoveTo clickX, clickY
    LeftClick 1
End Function



' 函数名称：AccurateClick
' 功能：在指定坐标 (x, y) 精准点击鼠标左键
' 参数：
'   x - 鼠标目标位置的 x 坐标
'   y - 鼠标目标位置的 y 坐标
' 实现：
'   移动鼠标到指定位置并执行左键点击。
Function AccurateClick(x, y)
    MoveTo x, y
    LeftClick 1
End Function
