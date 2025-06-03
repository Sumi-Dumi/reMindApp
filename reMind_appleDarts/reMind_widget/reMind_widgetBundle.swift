//
//  reMind_widgetBundle.swift
//  reMind_widget
//
//  Created by ryosuke on 3/6/2025.
//

import WidgetKit
import SwiftUI

@main
struct reMind_widgetBundle: WidgetBundle {
    var body: some Widget {
        reMind_widget()
        reMind_widgetControl()
        reMind_widgetLiveActivity()
    }
}
