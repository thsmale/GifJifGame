//
//  TimePicker.swift
//  GifJif
//
//  Created by Tommy Smale on 11/8/22.
//

import SwiftUI

struct TimePicker: View {
    @Binding var time: Int

    var body: some View {
        Picker("Time (seconds)", selection: $time) {
            ForEach(0 ..< 61) {
                Text("\($0)")
            }
        }
    }
}
