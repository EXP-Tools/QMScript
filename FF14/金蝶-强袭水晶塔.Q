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
EMULATOR_WIN_NAME = "MuMu模拟器12"	// 模拟器窗口名字
EMULATOR_WIN_W = 0      // 模拟器窗口分辨率 宽
EMULATOR_WIN_H = 0      // 模拟器窗口分辨率 高


Call main()


Sub main()
	TracePrint "模拟器窗口名字：" & EMULATOR_WIN_NAME
	
	hwnd = Plugin.Window.Find(0, EMULATOR_WIN_NAME)
	win_size = Plugin.Window.GetWindowRect(hwnd)
	TracePrint "模拟器窗口边框尺寸：" & win_size
	
	win_coords = Split(win_size, "|")
	win_lx = win_coords(0)
	win_ly = win_coords(1)
	win_rx = win_coords(2)
	win_ry = win_coords(3)
	TracePrint "模拟器窗口左上角坐标：（" & win_lx & ", " & win_ly & ")"
	TracePrint "模拟器窗口右下角坐标：（" & win_rx & ", " & win_ry & ")"
	
	win_w = win_rx - win_lx
	win_h = win_ry - win_ly
	TracePrint "模拟器窗口宽度：" & win_w
	TracePrint "模拟器窗口高度：" & win_h
	
End Sub

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


' 函数名称：FindColorInWindow
' 功能：在指定窗口中的区域监听是否出现了特定颜色
' 参数：
'   hwnd - 窗口句柄
'   x1, y1 - 区域左上角坐标
'   x2, y2 - 区域右下角坐标
'   color - 要监听的颜色值（格式为 "RRGGBB"）
' 返回值：
'   如果找到颜色，返回 True，并将颜色所在位置存储在 intX 和 intY 中
'   如果未找到颜色，返回 False

Function FindColorInWindow(hwnd, x1, y1, x2, y2, color)
    Dim intX, intY
    ' 在指定窗口的区域中查找颜色
    BindWindow hwnd, "normal", "normal", "normal", 0
    FindColor x1, y1, x2, y2, color, intX, intY
    UnBindWindow

    ' 判断是否找到颜色
    If intX > 0 And intY > 0 Then
        FindColorInWindow = True
    Else
        FindColorInWindow = False
    End If
End Function



