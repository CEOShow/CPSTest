import SwiftUI

struct CPSTesterView: View {
    @State private var clickCount = 0
    @State private var timerRunning = false
    @State private var timeRemaining = 5.0 // 預設測試時間 (秒)
    @State private var cps = 0.0
    @State private var customTime = "5" // 自訂時間的輸入框
    @State private var showResults = false // 控制是否顯示結果畫面
    @State private var timer: Timer? // Reference to the timer
    @State private var timeUpdated = false // 用來判斷時間是否已經更新
    @State private var isTimeValid = true // 用來檢查時間輸入是否合法
    @State private var lastTime = 5.0 // 記錄上一次的時間
    
    var body: some View {
        if showResults {
            ResultsView(cps: cps, clickCount: clickCount) {
                resetTest()
                showResults = false
            }
        } else {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 30) {
                    Text("海馬 CPS ")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("CPS 點擊滑鼠的速度，這是一個專門拿來測試的一個 App🎉")
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                    VStack(spacing: 10) {
                        Text("剩餘時間：\(String(format: "%.1f", max(timeRemaining, 0))) 秒")
                            .font(.system(size: 20, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("點擊次數：\(clickCount)")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.yellow)
                        
                        // 只有測試結束後才顯示 CPS
                        if showResults {
                            Text("CPS：\(String(format: "%.2f", cps))")
                                .font(.system(size: 30, weight: .bold, design: .rounded))
                                .foregroundColor(.green)
                        }
                    }
                    
                    // 只有在測試未開始時才顯示時間設定區塊
                    if !timerRunning {
                        VStack {
                            HStack {
                                TextField("輸入自訂時間 (秒)", text: $customTime)
                                    .keyboardType(.numberPad)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(width: 150)
                                    .onChange(of: customTime) { newValue in
                                        // 檢查輸入的數字是否有效，並設置 `isTimeValid`
                                        if let inputTime = Double(newValue), inputTime > 0 {
                                            isTimeValid = true
                                        } else {
                                            isTimeValid = false
                                        }
                                    }
                                
                                Button(action: {
                                    if let inputTime = Double(customTime), inputTime > 0 {
                                        timeRemaining = inputTime
                                        lastTime = inputTime // 記錄上一次設置的時間
                                        timeUpdated = true // 記錄時間已更新
                                    } else {
                                        timeRemaining = 5.0 // 如果輸入無效，則設定為 5 秒
                                        lastTime = 5.0
                                        timeUpdated = true
                                    }
                                }) {
                                    Text("設定時間")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .padding()
                                        .background(isTimeValid ? Color.green : Color.gray)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                        .shadow(radius: 5)
                                }
                                .disabled(!isTimeValid) // 當時間無效時禁用按鈕
                            }
                        }
                    }
                    
                    Button(action: {
                        if timerRunning {
                            clickCount += 1
                        } else {
                            startTest()
                            clickCount += 1 // Count the first click when starting the test 
                        }
                    }) {
                        Text(timerRunning ? "再快一點啊！" : "用你的最快速度點擊這裡！")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .padding()
                            .frame(width: 1000, height: 600)
                            .background(timerRunning ? Color.red : Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(25)
                            .shadow(radius: 15)
                    }
                    .disabled(timerRunning && timeRemaining <= 0)
                    
                    Spacer()
                    
                    // 重置測試按鈕
                    Button(action: {
                        resetTest()
                    }) {
                        Text("重置測試")
                            .font(.system(size: 20, weight: .medium, design: .rounded))
                            .padding()
                            .frame(width: 150, height: 50)
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                    .padding(.top, 10)
                }
                .padding()
            }
            .onChange(of: timeRemaining) { newValue in
                if newValue <= 0 && timerRunning {
                    timerRunning = false
                    // 如果輸入時間為 0 或無效，則使用 5 秒來計算 CPS
                    cps = Double(clickCount) / (Double(customTime) ?? 5.0)
                    showResults = true
                }
            }
        }
    }
    
    func startTest() {
        clickCount = 0
        cps = 0.0
        
        // 只有在「設定時間」被按下後，才會更新 timeRemaining
        if timeUpdated {
            timeUpdated = false // 重置標誌
        } else {
            // 如果未設定新時間，則使用上一次設置的時間 (lastTime)
            timeRemaining = lastTime
        }
        
        timerRunning = true
        
        // 啟動計時器
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if timeRemaining > 0 {
                timeRemaining -= 0.1
            } else {
                timeRemaining = 0 // 確保不會低於零
                timer.invalidate()
            }
        }
    }
    
    func resetTest() {
        // 停止計時器
        timer?.invalidate()
        timer = nil
        
        clickCount = 0
        cps = 0.0
        timeRemaining = lastTime // 重置為上一次設置的時間
        timerRunning = false
        showResults = false // 重置結果顯示
        timeUpdated = false // 重置時間更新標誌
        isTimeValid = true // 重置時間有效標誌
    }
}

struct ResultsView: View {
    let cps: Double
    let clickCount: Int
    let onRestart: () -> Void
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.green]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("測試結果")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("總點擊次數：\(clickCount)")
                    .font(.system(size: 24, weight: .medium, design: .rounded))
                    .foregroundColor(.yellow)
                
                Text("CPS：\(String(format: "%.2f", cps))")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(.green)
                
                HStack {
                    // 重新測試按鈕
                    Button(action: {
                        onRestart() // 重新開始測試
                    }) {
                        Text("重新測試")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .padding()
                            .frame(width: 150, height: 50)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                    
                }
                .padding(.top, 10)
            }
        }
    }
}


