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
MacroID=04e144c6-835c-4708-a6c9-1dbb934b45b7
Description=金蝶-强袭水晶塔
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
Dim EMULATOR                            // 定义全局模拟器对象
EMULATOR_WIN_NAME = "MuMu模拟器12"      // 模拟器窗口名字

// 启动入口
Call main()


Sub main()
    // 初始化模拟器窗体信息（位置与大小）
    InitElemulator(EMULATOR_WIN_NAME)
    
    // 点击【确认】按钮开始小游戏
    Call clickStartConfirmBtn()


    Do While True
        Delay 5000  // 等待 5 秒进入游戏
        Do While True
            
            Call clickCrystal()
            Delay 1
            
        Loop

        // 点击【再战】重开游戏
    Loop

    
End Sub


' 函数名称：clickStartConfirmBtn
' 功能：点击【强袭水晶塔】小游戏的开始【确认】按钮
' 实现：
'   1. 根据按钮在模拟器窗口内的相对位置百分比，计算按钮的屏幕坐标范围。
'   2. 使用颜色匹配方法查找按钮的具体位置。
'   3. 在找到按钮位置后，模拟鼠标点击操作。
' 注意事项：
'   - 第一次获取坐标写入代码时，需要把模拟器窗口需要左上角贴合屏幕左上角。
'   - 按钮的颜色和相对坐标需要通过按键精灵的【抓抓】工具获取，不然会出现偏差。
'   - 以后使用时模拟器可以在屏幕任意位置，代码会计算相对坐标。
' 返回值：
'   无返回值
Sub clickStartConfirmBtn()

    // 【确认】按钮坐标在模拟器窗口内的相对位置的百分比
    // 譬如模拟器宽高为 2560 x 1440
    //   按钮左上角 x 相对坐标为 1382，即在相对宽度 54% 的位置，即 0.54
    //   按钮左上角 y 相对坐标为 893， 即在相对宽度 62% 的位置，即 0.62
    btnSX = 0.54    // 左上角 x 位置百分比
    btnSY = 0.62    // 左上角 y 位置百分比
    btnEX = 0.68    // 右下角 x 位置百分比
    btnEY = 0.66    // 右下角 y 位置百分比
    btnColor = "3366C3" // 按钮主颜色
    similarity = 0.8
    coords = FindAreaColor(btnSX, btnEX, btnEX, btnEY, btnColor, similarity)
    x = coords(0)
    y = coords(1)
    If x > 0 And y > 0 Then
        TracePrint "找到【确认】按钮坐标： (" & x & ", " & y & ")"
        Call RandomClick(x, y)
    Else
        TracePrint "未找到【确认】按钮坐标： (" & x & ", " & y & ")"
    End If
End Sub


Sub clickCrystal()

    // 【判定水晶点击区域】在模拟器窗口内的相对位置的百分比
    cSX = 0.6588    // 左上角 x 位置百分比
    cSY = 0.7824    // 左上角 y 位置百分比
    cEX = 0.9358    // 右下角 x 位置百分比
    cEY = 0.8175    // 右下角 y 位置百分比

    // 1494  1077
    // 2175  1146

    Dim CRYSTAL_COLORS(3)
    // CRYSTAL_COLORS(0) = "B68539"  // 蓝水晶
    CRYSTAL_COLORS(0) = "4194C1"  // 黄水晶
    CRYSTAL_COLORS(1) = "B63989"  // 紫水晶
    CRYSTAL_COLORS(2) = "2C52CE"  // 红水晶
    similarity = 0.75

    For i = 0 To UBound(CRYSTAL_COLORS)
        coords = FindAreaColor(cSX, cSY, cEX, cEY, CRYSTAL_COLORS(i), similarity)
        x = coords(0)
        y = coords(1)

        If x > 0 And y > 0 Then
            TracePrint "找到水晶 [" & CRYSTAL_COLORS(i) & "]：(" & x & ", " & y & ")"
            Call RandomClick(x, y)  // 点击水晶
            Exit Sub   // 找到一个水晶后退出循环
        End If
    Next
End Sub


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
    EMULATOR("Width") = win_w       // 模拟器窗口宽度（含边框）
    EMULATOR("Height") = win_h      // 模拟器窗口高度（含边框）
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
'   x - 鼠标目标位置的 X 坐标
'   y - 鼠标目标位置的 Y 坐标
' 实现：
'   1. 在目标坐标的基础上，随机生成 -10 到 10 的偏移量。
'   2. 计算随机点击位置。
'   3. 移动鼠标到随机位置并执行左键点击。
Function RandomClick(x, y)
    // 定义偏移范围
    Dim offsetX, offsetY
    offsetX = Int(Rnd() * 21) - 10  // 随机生成 -10 到 10 的偏移量
    offsetY = Int(Rnd() * 21) - 10  // 随机生成 -10 到 10 的偏移量

    // 计算随机点击位置
    Dim clickX, clickY
    clickX = x + offsetX
    clickY = y + offsetY

    // 移动鼠标到随机位置并点击
    MoveTo clickX, clickY
    LeftClick 1
End Function

