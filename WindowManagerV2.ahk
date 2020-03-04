; ============================================================
; --------Multi Monitor "Real-estate" management tool---------
; ============================================================

; CONTROLLER CLASS
class WindowManagerController {
	__New(){
	
	}

	UC_resize_up(){
	}
}

; MODEL CLASS
class WindowManagerObject {

	__New(){
			
		; Defaults
		; This block of defaults will be populated automatically
		this.m := 1					; default monitor #
		this.mLeft := 0		
		this.mTop := 0
		this.mRight := 1920		
		this.mBottom := 1080

		this.widthRatios := [0.333, 0.5, 0.667, 1.0]
		this.heightRatios := [0.333, 0.5, 0.667, 1.0]
		this.heightSettings := [0.5, 1.0]
		this.taskbarHeight := 33

		this.x_offset := 6		; my monitors have 6 free pixels on each side, adjust as necessary
		this.win_offset := 200
		
		SysGet, Mon1, Monitor, 1
		SysGet, Mon2, Monitor, 2
		SysGet, Mon3, Monitor, 3

		this.monitors := {"mOld": 0, "mNew": 1}
		this.monitorList := [{"left": Mon1Left, "right": Mon1Right, "bottom": Mon1Bottom, "top": Mon1Top},{"left": Mon2Left, "right": Mon2Right, "bottom": Mon2Bottom, "top": Mon2Top},{"left": Mon3Left, "right": Mon3Right, "bottom": Mon3Bottom, "top": Mon3Top}]
	}
  
	getActiveMonitor(){
  
		monitor := 0

		WinGetPos, winXpos, winYpos, winWidth, winHeight, A
		
		; First Monitor
		if (winXpos  + this.win_offset < this.monitorList[1]["right"]  - this.x_offset){
			monitor := 1
		}
		; Second Monitor
		else if (winXpos + this.win_offset < this.monitorList[2]["right"]  - this.x_offset ){
			monitor := 2
		}
		; Third Monitor
		else if (winXpos + this.win_offset <= this.monitorList[3]["right"]  - this.x_offset){
			monitor := 3
		}
		;MsgBox, X Position: %winXpos%, Monitor #%monitor%.
		return monitor
  
  }
  
	setActiveMonitorParams(){

		m := this.getActiveMonitor()
		this.m := m
		this.mLeft := this.monitorList[m]["left"]
		this.mTop := this.monitorList[m]["top"]
		this.mRight := this.monitorList[m]["right"]
		this.mBottom := this.monitorList[m]["bottom"]
		return
	}

	switchMonitors(mNew){

		this.setActiveMonitorParams()
		
		m2Right := this.monitorList[mNew]["right"]
		m2Left := this.monitorList[mNew]["left"]
		m2Top := this.monitorList[mNew]["top"]
		m2Bottom := this.monitorList[mNew]["bottom"]
		m2Width := m2Right-m2Left
		mHeight := this.mBottom - this.mTop - this.taskbarHeight
		m2Height := m2Bottom - m2Top - this.taskbarHeight

		if(mNew != this.m){
			WinGetPos, winXpos, winYpos, winWidth, winHeight, A
			widthFraction := winWidth / (this.mRight - this.mLeft)
			heightFraction := winHeight / mHeight
			
			width2 := widthFraction * m2Width
			height2 := heightFraction * m2Height
			
			xNew := winXpos - this.mLeft + m2Left 
			
			
			this.moveWindow(A, xNew, winYpos, width2, height2)
		}	
		return
	}

	moveWindow(a, x, y, w, h){
		WinRestore, a
		winmove,a,, %x%,%y%,%w%,%h%
		WinRestore, a
	}
	
	resize_h_smaller(){
	
		WinGetPos, winXpos, winYpos, winWidth, winHeight, A
		this.setActiveMonitorParams()
	
		for r in this.widthRatios{
		
			currentRatio:= this.widthRatios[r]
			mWidth := this.mRight - this.mLeft + 2 * this.x_offset
			winRatio := winWidth / mWidth
			
			if(currentRatio >= winRatio){
				rNew := this.widthRatios[r-1]
				newWidth := rNew * mWidth
				;newLeft := this.mLeft - this.x_offset
				this.moveWindow(A, winXpos, winTop, newWidth, winHeight)
				break		
			}
			; If the window is wider then the monitor, it will reduce the the size of the window
			else if (winWidth > mWidth){
				newLeft := this.mLeft - this.x_offset
				this.moveWindow(A, newLeft, winTop, mWidth, winHeight)
			}
	}
	
	}
	
	resize_h_bigger(){

		this.setActiveMonitorParams()
		
		WinGetPos, winXpos, winYpos, winWidth, winHeight, A
		winRight := winXpos + winWidth
		mWidth := this.mRight - this.mLeft + 2 * this.x_offset
		winBoundary := this.mRight + 2 * this.x_offset 
		winRatio := winWidth / mWidth

		leftDist := Abs(this.mLeft - winXpos)
		rightDist := Abs(this.mRight - winRight)

		;MsgBox, %mWidth% %winXpos% %winWidth%
		;MsgBox, Distance to ... Left: %leftDist%  Right: %rightDist%
		
		for r in this.widthRatios{
		
			currentRatio:= this.widthRatios[r]
			
			if(currentRatio > winRatio + 0.001){
				newWidth := currentRatio * mWidth
				;if winXpos + newWidth > winBoundary
				;	adjust so winXpos + newWidth = winBoundary
				this.moveWindow(A, winxPos, winTop, newWidth, winHeight)
				break		
			}
		}
		return
	}
	
	resize_v_smaller(){
	
		this.setActiveMonitorParams()
		WinGetPos, winXpos, winYpos, winWidth, winHeight, A
		
		adjustedMonitorHeight := this.mBottom - this.mTop - this.taskbarHeight
		winHeightRatio := winHeight / adjustedMonitorHeight
		
		for r in this.heightRatios{
			currentRatio := this.heightRatios[r]
			
			if(currentRatio >= winHeightRatio){
				newHeight := this.heightRatios[r-1] * adjustedMonitorHeight
				this.moveWindow(A, winxPos, winTop, winWidth, newHeight)
				break
			}
		}
		
		return
	}
	
	resize_v_bigger(){
	
		this.setActiveMonitorParams()
		WinGetPos, winXpos, winYpos, winWidth, winHeight, A
		
		adjustedMonitorHeight := this.mBottom - this.mTop - this.taskbarHeight
		winHeightRatio := winHeight / adjustedMonitorHeight
		
		for r in this.heightRatios{
			if(this.heightRatios[r] > winHeightRatio + 0.001){
				newHeight := this.heightRatios[r] * adjustedMonitorHeight
				this.moveWindow(A, winxPos, winTop, winWidth, newHeight)
				break
			}
		
		}
		
		return
	}

	display_active_monitor_info(){
		; A helpful debugging function
		currentMonitor := this.getActiveMonitor()
		WinGetPos, winXpos, winYpos, winWidth, winHeight, A
		WinGetTitle, WindowTitle, A
		msgbox, Monitor #: %currentMonitor% Window X position: %winXpos%  Width: %winWidth%
		return
	
	}
	
	reposition_window(pos_flag){
		; Snap the window to top, right, bottom, or left of monitor
		WinGetPos, winXpos, winYpos, winWidth, winHeight, A
		this.setActiveMonitorParams()
	
		if(pos_flag = "left"){
			winXpos := this.mLeft - this.x_offset
		}
		else if(pos_flag = "right"){
			winXpos := this.mRight - winWidth + this.x_offset
		}
		else if(pos_flag = "top"){
			winYpos := this.mTop
		}
		else if(pos_flag = "bottom"){
			winYpos := this.mBottom - winHeight - this.taskbarHeight
		}

		this.moveWindow(A, winXpos, winYpos, winWidth, winHeight)
		return
	
	}
	
}


; ------------------------------------------------------------
; ======================= INITIALIZE =========================
; ------------------------------------------------------------

WindowManager := new WindowManagerObject()

; ------------------------------------------------------------
; ======================= HOTKEYS ============================
; ------------------------------------------------------------

#a:: 
	WindowManager.display_active_monitor_info()
	return

; ------ Move to monitor 1, 2, or 3 ---------
#1::
	mNext := 1
	WindowManager.switchMonitors(mNext)
	return

#2::
	mNext := 2
	WindowManager.switchMonitors(mNext)
	return

#3::
	mNext := 3
	WindowManager.switchMonitors(mNext)
	return

; --------------- DIRECTIONS ----------------
#left::
	WindowManager.reposition_window("left")
	return
	
#right::
	WindowManager.reposition_window("right")
	return
	
#up::
	WindowManager.reposition_window("top")
	return

#down::
	WindowManager.reposition_window("bottom")
	return
	

; --------- Window Size Adjustment ----------
#!left::
	WindowManager.resize_h_smaller()
	return
	
#!right::
	WindowManager.resize_h_bigger()
	return

#!down::
	WindowManager.resize_v_bigger()
	return

#!up::
	WindowManager.resize_v_smaller()
	return





