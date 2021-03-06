//
//  StatusItemView.swift
//  Up&Down
//
//  Created by 郭佳哲 on 5/16/16.
//  Copyright © 2016 郭佳哲. All rights reserved.
//

import AppKit
import Foundation

open class StatusItemView: NSControl {
    static let KB:Float = 1024
    static let MB:Float = KB*1024
    static let GB:Float = MB*1024
    static let TB:Float = GB*1024
    
    var fontSize:CGFloat = 9
    var fontColor = NSColor.black
    var darkMode = false
    var mouseDown = false
    var statusItem:NSStatusItem
    
    var upRate = "- - KB/s"
    var downRate = "- - KB/s"
    var image = NSImage(named: "menu_icon")

    var showSpeed:Bool = false
    
    init(statusItem aStatusItem: NSStatusItem, menu aMenu: NSMenu) {
        statusItem = aStatusItem
        super.init(frame: NSMakeRect(0, 0, statusItem.length, 30))
        menu = aMenu
        menu?.delegate = self
        
        darkMode = SystemThemeChangeHelper.isCurrentDark()
        
        SystemThemeChangeHelper.addRespond(target: self, selector: #selector(changeDarkMode))
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func draw(_ dirtyRect: NSRect) {
        statusItem.drawStatusBarBackground(in: dirtyRect, withHighlight: mouseDown)
        
        fontColor = (darkMode||mouseDown) ? NSColor.white : NSColor.black
        let fontAttributes = [convertFromNSAttributedStringKey(NSAttributedString.Key.font): NSFont.systemFont(ofSize: fontSize), convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): fontColor] as [String : Any]
        if showSpeed{
            let upRateString = NSAttributedString(string: upRate+" ↑", attributes: convertToOptionalNSAttributedStringKeyDictionary(fontAttributes))
            let upRateRect = upRateString.boundingRect(with: NSSize(width: 100, height: 100), options: .usesLineFragmentOrigin)
            upRateString.draw(at: NSMakePoint(bounds.width - upRateRect.width - 5, 10))

            let downRateString = NSAttributedString(string: downRate+" ↓", attributes: convertToOptionalNSAttributedStringKeyDictionary(fontAttributes))
            let downRateRect = downRateString.boundingRect(with: NSSize(width: 100, height: 100), options: .usesLineFragmentOrigin)
            downRateString.draw(at: NSMakePoint(bounds.width - downRateRect.width - 5, 0))
        }
        image?.draw(at: NSPoint(x: 0, y: 0), from: NSRect(x: -2, y: -2, width: bounds.height, height: bounds.height), operation: NSCompositingOperation.sourceOver, fraction: 1.0)
    }
    
    open func setRateData(up:Float, down: Float) {
        upRate = formatRateData(up)
        downRate = formatRateData(down)
        DispatchQueue.main.async {
            self.setNeedsDisplay()
        }
    }
    
    func formatRateData(_ data:Float) -> String {
        var result:Float
        var unit: String
        
        if data < StatusItemView.KB/100 {
            result = 0
            return "0 KB/s"
        }
            
        else if data < StatusItemView.MB{
            result = data/StatusItemView.KB
            unit = " KB/s"
        }
            
        else if data < StatusItemView.GB {
            result = data/StatusItemView.MB
            unit = " MB/s"
        }
            
        else if data < StatusItemView.TB {
            result = data/StatusItemView.GB
            unit = " GB/s"
        }
            
        else {
            result = 1023
            unit = " GB/s"
        }
        
        if result < 100 {
            return String(format: "%0.2f", result) + unit
        }
        else if result < 999 {
            return String(format: "%0.1f", result) + unit
        }
        else {
            return String(format: "%0.0f", result) + unit
        }
    }
    
    @objc func changeDarkMode() {
        darkMode = SystemThemeChangeHelper.isCurrentDark()
        DispatchQueue.main.async {
            self.setNeedsDisplay()
        }
    }
    
    func setIcon(_ image: NSImage) {
        // 支持 darks 模式，应该不需要这么复杂，但我也不会代码，尝试这样解决
        if darkMode {
            switch image.name() {
            case "menu_icon_disabled":
                self.image = NSImage(named: "menu_icon_disabled_dark_mode")
            case "menu_icon_pac":
                self.image = NSImage(named: "menu_icon_pac_dark_mode")
            case "menu_icon_global":
                self.image = NSImage(named: "menu_icon_global_dark_mode")
            case "menu_icon_white":
                self.image = NSImage(named: "menu_icon_white_dark_mode")
            case "menu_icon_manual":
                self.image = NSImage(named: "menu_icon_manual_dark_mode")
            case "menu_icon_acl":
                self.image = NSImage(named: "menu_icon_acl_dark_mode")
            default:
                self.image = NSImage(named: "menu_icon_dark_mode")
            }
        } else {
            self.image = image
        }
        DispatchQueue.main.async {
            self.setNeedsDisplay()
        }
    }

}

//action
extension StatusItemView: NSMenuDelegate{
    open override func mouseDown(with theEvent: NSEvent) {
        statusItem.popUpMenu(menu!)
    }
    
    public func menuWillOpen(_ menu: NSMenu) {
        mouseDown = true
        DispatchQueue.main.async {
            self.setNeedsDisplay()
        }
    }
    
    public func menuDidClose(_ menu: NSMenu) {
        mouseDown = false
        DispatchQueue.main.async {
            self.setNeedsDisplay()
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
