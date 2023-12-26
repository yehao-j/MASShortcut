//
//  ViewController.swift
//  Example
//
//  Created by niko on 2023/12/26.
//

import Cocoa
import MASShortcut

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cut = MASShortcut(keyCode: kVK_ANSI_A, modifierFlags: .option)
        MASShortcutBinder.shared().register(withKey: "aaa", shortcut: cut) {
            print("666--------- abc")
        }

        let v = MASShortcutView()
        v.frame = CGRect(x: 50, y: 50, width: 100, height: 25)
        v.associatedUserDefaultsKey = "aaa"
        view.addSubview(v)
        
        MASShortcutValidator.shared().allowAnyShortcutWithOptionModifier = true
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

