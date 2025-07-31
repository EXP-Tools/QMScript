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
Dim EMULATOR			// 定义全局模拟器对象
EMULATOR_WIN_NAME = "MuMu模拟器12"	// 模拟器窗口名字
EMULATOR_WIN_W = 0      // 模拟器窗口分辨率 宽
EMULATOR_WIN_H = 0      // 模拟器窗口分辨率 高


Call main()


Sub main()
	InitElemulator(EMULATOR_WIN_NAME)
	
	// 开始小游戏时的【确认】按钮
    coords = FindAreaColor(0.54, 0.62, 0.68, 0.66, "3366C3")
    x = coords(0)
    y = coords(1)
    TracePrint "找到位置 X：" & x
	TracePrint "找到位置 Y：" & y
	Call RandomClick(x, y)
End Sub


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
	EMULATOR("Name") = win_name
	EMULATOR("Hwnd") = hwnd
	EMULATOR("Left") = win_lx
	EMULATOR("Top") = win_ly
	EMULATOR("Right") = win_rx
	EMULATOR("Bottom") = win_ry
	EMULATOR("Width") = win_w
	EMULATOR("Height") = win_h
End Function


' 函数名称：FindAreaColor
' 功能：在指定区域中 (psx, psy, pex, pey) 寻找颜色
' 参数：
'   psx - 区域起始坐标相对于模拟器宽度的百分比
'   psy - 区域起始坐标相对于模拟器高度的百分比
'   pex - 区域终止坐标相对于模拟器宽度的百分比
'   pey - 区域终止坐标相对于模拟器高度的百分比
' 实现：
'   1. 在目标坐标的基础上，随机生成 -10 到 10 的偏移量。
'   2. 计算随机点击位置。
'   3. 移动鼠标到随机位置并执行左键点击。
Function FindAreaColor(psx, psy, pex, pey, hexColor)
    rsx = EMULATOR("Width") * psx       // 相对于模拟器内部的区域起始 X 坐标
    rsy = EMULATOR("Height") * psy      // 相对于模拟器内部的区域起始 Y 坐标
    rex = EMULATOR("Width") * pex       // 相对于模拟器内部的区域终止 X 坐标
    rey = EMULATOR("Height") * pey// 相对于模拟器内部的区域终止 Y 坐标
    TracePrint "搜索区域的相对范围： (" & rsx & ", " & rsy & ") - (" & rex & ", " & rey & ")"

    asx = EMULATOR("Left") + rsx       // 相对于屏幕的区域起始 X 坐标
    asy = EMULATOR("Top") + rsy        // 相对于屏幕的区域起始 Y 坐标
    aex = EMULATOR("Left") + rex       // 相对于屏幕的区域终止 X 坐标
    aey = EMULATOR("Top") + rey		   // 相对于屏幕的区域终止 Y 坐标
    TracePrint "搜索区域的绝对范围： (" & asx & ", " & asy & ") - (" & aex & ", " & aey & ")"

    mode = 0            // 检索模式，从左上到右下
    similarity = 0.8    // 匹配颜色的相似度
    FindColorEx asx, asy, aex, aey, hexColor, mode, similarity, intX, intY

    Dim coords(2)
    coords(0) = intX
    coords(1) = intY
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
    ' 定义偏移范围
    Dim offsetX, offsetY
    offsetX = Int(Rnd() * 21) - 10  ' 随机生成 -10 到 10 的偏移量
    offsetY = Int(Rnd() * 21) - 10  ' 随机生成 -10 到 10 的偏移量

    ' 计算随机点击位置
    Dim clickX, clickY
    clickX = x + offsetX
    clickY = y + offsetY

    ' 移动鼠标到随机位置并点击
    MoveTo clickX, clickY
    LeftClick 1
End Function




