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
// QQ14 金蝶强袭水晶塔自动脚本
// 需要进入开始小游戏确认画面、但未点击确认按钮时使用
// 虽然此脚本是无限循环，但金蝶小游戏每天限制次数，到点请自己退出脚本
// 开始运行脚本： F10
// 终止脚本运行： F12
// 虽然脚本对任意规格做了同比例自适应，但是可能会出现区域偏差的情况
// 推荐 MuMu模拟器窗口大小为 2560 x 1440 (开发是在此规格下测试的)

Dim EMULATOR                            // 定义全局模拟器对象
EMULATOR_WIN_NAME = "MuMu模拟器12"		// 模拟器窗口名字



// 启动入口
Call main()


Function main()
    // 初始化模拟器窗体信息（位置与大小）
    InitElemulator(EMULATOR_WIN_NAME)
    
    // 点击【确认】按钮开始小游戏
    Call clickStartConfirmBtn()

    Do While True
        Delay 5000  // 等待 5 秒进入游戏

        // 开始新的一轮游戏
        cnt = 1
        Do While True
            
            // 在水晶判断区域，无时无刻检测是否有一种颜色的水晶到达然后点击
            // 因为水晶速度较快可能会失误，但有失误反而更像真人在玩游戏
            Call clickCrystal()
            Delay 1

            // cnt 用于读秒，大概在 230 左右一轮游戏就结束，
            // 此时再判断指定区域的【再战】按钮是否出现，可以减少检索次数提高游戏效率
			cnt = cnt + 1
			If cnt >= 230 Then
        		If clickRetry() Then
        			TracePrint "完成一轮游戏"
                	Exit Do  // 开始新的游戏循环
    			End If
    		End If
        Loop
    Loop
    
End Function


' 函数名称：clickStartConfirmBtn
' 功能：点击【强袭水晶塔】小游戏的开始【确认】按钮
' 实现：
'   1. 根据按钮在模拟器窗口内的相对位置比例，计算按钮的屏幕坐标范围。
'   2. 使用颜色匹配方法查找按钮的具体位置。
'   3. 在找到按钮位置后，模拟鼠标点击操作。
' 注意事项：
'   - 第一次获取坐标写入代码时，需要把模拟器窗口需要左上角贴合屏幕左上角。
'   - 按钮的颜色和相对坐标需要通过按键精灵的【抓抓】工具获取，不然会出现偏差。
'   - 以后使用时模拟器可以在屏幕任意位置，代码会计算相对坐标。
' 返回值：
'   无返回值
Function clickStartConfirmBtn()

    // 【确认】按钮坐标在模拟器窗口内的相对位置的百分比
    // 譬如模拟器宽高为 2560 x 1440， 去除边框为 2297 x 1326
    //   按钮左上角 x 相对坐标为 1277，即在相对宽度 60.16% 的位置，即 0.6016
    //   按钮左上角 y 相对坐标为 833， 即在相对宽度 67.34% 的位置，即 0.6734

    btnSX = 0.5559    // 左上角 x 位置比例
    btnSY = 0.6282    // 左上角 y 位置比例
    btnEX = 0.6464    // 右下角 x 位置比例
    btnEY = 0.6613    // 右下角 y 位置比例
    btnColor = "3366C3" // 按钮主颜色
    similarity = 0.8
    coords = FindAreaColor(btnSX, btnSY, btnEX, btnEY, btnColor, similarity)
    x = coords(0)
    y = coords(1)
    If x > 0 And y > 0 Then
        TracePrint "找到【确认】按钮坐标： (" & x & ", " & y & ")"
        Call RandomClick(x, y)
    Else
        TracePrint "未找到【确认】按钮坐标： (" & x & ", " & y & ")"
    End If
End Function


' 函数名称：clickCrystal
' 功能：检测水晶区域是否出现目标颜色的水晶，并点击对应位置
' 实现：
'   1. 定义水晶区域在模拟器窗口内的相对位置比例。
'   2. 循环检测多种水晶颜色是否出现。
'   3. 如果检测到目标颜色的水晶，模拟鼠标点击操作。
' 注意事项：
'   - 水晶颜色需要通过按键精灵的【抓抓】工具获取。
'   - 区域坐标为相对百分比，需结合模拟器窗口的实际尺寸计算。
' 返回值：
'   无返回值
Function clickCrystal()

    // 【判定水晶点击区域】在模拟器窗口内的相对位置的百分比
    cSX = 0.6588    // 左上角 x 位置比例
    cSY = 0.7824    // 左上角 y 位置比例
    cEX = 0.9358    // 右下角 x 位置比例
    cEY = 0.8175    // 右下角 y 位置比例

    Dim CRYSTAL_COLORS(4)
    CRYSTAL_COLORS(0) = "4194C1"  // 黄水晶
    CRYSTAL_COLORS(1) = "B63989"  // 紫水晶
    CRYSTAL_COLORS(2) = "2C52CE"  // 红水晶
    CRYSTAL_COLORS(3) = "B68539"  // 蓝水晶
    similarity = 0.75   // 测试得到最佳的颜色相似度

    For i = 0 To UBound(CRYSTAL_COLORS)
        coords = FindAreaColor(cSX, cSY, cEX, cEY, CRYSTAL_COLORS(i), similarity)
        x = coords(0)
        y = coords(1)

        If x > 0 And y > 0 Then
            TracePrint "找到水晶 [" & CRYSTAL_COLORS(i) & "]：(" & x & ", " & y & ")"
            Call RandomClick(x, y) 
            Exit Function   // 找到一个水晶后退出循环
        End If
    Next
End Function


' 函数名称：clickRetry
' 功能：检测【再战】按钮重新开始游戏
' 实现：
'   1. 定义【再战】按钮区域在模拟器窗口内的相对位置比例。
'   2. 检测目标区域内是否出现指定颜色的按钮。
'   3. 如果检测到按钮，返回 True；否则返回 False。
' 注意事项：
'   - 按钮颜色和区域坐标需要通过按键精灵的【抓抓】工具获取。
'   - 区域坐标为相对百分比，需结合模拟器窗口的实际尺寸计算。
' 返回值：
'   布尔值：
'     - True：检测到【再战】按钮。
'     - False：未检测到【再战】按钮。
Function clickRetry()
    isRetry = False

    // 【再战】按钮坐标在模拟器窗口内的相对位置的百分比
    btnSX = 0.8398      // 左上角 x 位置比例
    btnSY = 0.9003      // 左上角 y 位置比例
    btnEX = 0.9227      // 右下角 x 位置比例
    btnEY = 0.9403      // 右下角 y 位置比例
    btnColor = "649DAE" // 按钮主颜色
    similarity = 0.8
    coords = FindAreaColor(btnSX, btnSY, btnEX, btnEY, btnColor, similarity)
    x = coords(0)
    y = coords(1)
    If x > 0 And y > 0 Then
        TracePrint "找到【再战】按钮坐标： (" & x & ", " & y & ")"
        Call RandomClick(x, y)
        isRetry = True
    End If

    clickRetry = isRetry
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

    mode = 1            // 检索模式，从中心开始向外检索
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

