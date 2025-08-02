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
MacroID=8192e189-f6b0-4af1-b739-55f971bdbd38
Description=钓鱼-红蓝票
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
// QQ14 自动钓鱼脚本（支持红蓝票，不支持以小钓大）
// 需要进入钓鱼状态（看到鱼饵箱）后、未抛竿时使用
// 由于是无限循环，需要购买足够的鱼饵
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
    
    Do While True
        // 抛竿
        Call clickThrowingPoleBtn()

        // 等待上钩 并 起杆（暂不处理以小钓大，蓝票/红票不需要）
        Call clickLiftPoleBtn()

        // 确认收藏品
        
    Loop
    
End Function



Function clickThrowingPoleBtn()

    Do While True
        Delay 1000  // 循环等待回到抛竿状态

        // 【以小钓大（禁用）】按钮坐标在模拟器窗口内的相对位置的百分比
        // 譬如模拟器宽高为 2560 x 1440， 去除边框为 2297 x 1326
        //   按钮左上角 x 相对坐标为 1958，即在相对宽度 85.24% 的位置，即 0.8524
        //   按钮左上角 y 相对坐标为 756， 即在相对宽度 57.01% 的位置，即 0.5701
        btnSX = 0.8524    // 左上角 x 位置百分比
        btnSY = 0.5701    // 左上角 y 位置百分比
        btnEX = 0.8881    // 右下角 x 位置百分比
        btnEY = 0.6312    // 右下角 y 位置百分比
        btnColor = "2A3851" // 按钮主颜色
        similarity = 0.8
        coords = FindAreaColor(btnSX, btnSY, btnEX, btnEY, btnColor, similarity)
        x = coords(0)
        y = coords(1)
        If x > 0 And y > 0 Then
            TracePrint "当前处于【抛竿】状态"

            // 【抛竿】按钮坐标在模拟器窗口内的相对位置的百分比
            btnSX = 0.8454    // 左上角 x 位置百分比
            btnSY = 0.7435    // 左上角 y 位置百分比
            btnEX = 0.8972    // 右下角 x 位置百分比
            btnEY = 0.8250    // 右下角 y 位置百分比
            btnColor = "B7D0E1" // 按钮主颜色
            similarity = 0.8
            coords = FindAreaColor(btnSX, btnSY, btnEX, btnEY, btnColor, similarity)
            x = coords(0)
            y = coords(1)
            If x > 0 And y > 0 Then
                TracePrint "找到【抛竿】按钮坐标： (" & x & ", " & y & ")"
                Call RandomClick(x, y)
                Exit Do  // 进入提竿前的等待状态
            End If
        End If

    Loop
End Function



Function clickLiftPoleBtn()

    Do While True
        Delay 1000  // 循环等待上钩

        // 【咬钩】提示坐标在模拟器窗口内的相对位置的百分比
        btnSX = 0.6686    // 左上角 x 位置百分比
        btnSY = 0.4839    // 左上角 y 位置百分比
        btnEX = 0.6991    // 右下角 x 位置百分比
        btnEY = 0.5103    // 右下角 y 位置百分比
        btnColor = "5599BE" // 按钮主颜色
        similarity = 0.8
        coords = FindAreaColor(btnSX, btnSY, btnEX, btnEY, btnColor, similarity)
        x = coords(0)
        y = coords(1)
        If x > 0 And y > 0 Then
            TracePrint "当前处于【咬钩】状态"

            // 【提竿】按钮坐标在模拟器窗口内的相对位置的百分比
            btnSX = 0.8454    // 左上角 x 位置百分比
            btnSY = 0.7435    // 左上角 y 位置百分比
            btnEX = 0.8972    // 右下角 x 位置百分比
            btnEY = 0.8250    // 右下角 y 位置百分比
            btnColor = "B7D0E1" // 按钮主颜色
            similarity = 0.8
            coords = FindAreaColor(btnSX, btnSY, btnEX, btnEY, btnColor, similarity)
            x = coords(0)
            y = coords(1)
            If x > 0 And y > 0 Then
                TracePrint "找到【提竿】按钮坐标： (" & x & ", " & y & ")"
                Call RandomClick(x, y)
                Exit Do  // 退回抛竿状态
            End If
        End If
    Loop
    
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

