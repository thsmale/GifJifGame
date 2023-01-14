//
//  TommyTimer.swift
//  GifJif
//
//  Created by Tommy Smale on 11/8/22.
//

import SwiftUI


struct TommyTimer {
    private var timer: Timer? = nil
    @Binding var time: Int
    
    mutating func start_timer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            /*
            time -= 1
            if (time <= 0) {
                //end_timer()
            }
             */
        })
    }
    
    mutating func end_timer() {
        timer?.invalidate()
        timer = nil
    }
}
