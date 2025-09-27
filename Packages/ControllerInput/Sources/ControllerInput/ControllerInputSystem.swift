/*
  Copyright © 2025 Apple Inc.

  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import GameController
import RealityKit
import SwiftUI

/// A system that continuously records the controller's current state.
@available(macOS 15.0, *)
public struct ControllerInputSystem: System, Sendable {
    @MainActor static var jumpPressed = false
    @MainActor static var circlePressed = false
    //    nonisolated(unsafe) static var controller: GCController?

    public init(scene _: RealityKit.Scene) {
        //        NotificationCenter.default.addObserver(
        //            forName: NSNotification.Name.GCControllerDidConnect,
        //            object: nil, queue: nil,
        //            using: didConnectController)
        //        NotificationCenter.default.addObserver(
        //            forName: NSNotification.Name.GCControllerDidDisconnect,
        //            object: nil, queue: nil,
        //            using: didDisconnectController)
        GCController.startWirelessControllerDiscovery()
    }

    //    func didConnectController(_ notification: Notification) {
    //        Self.controller = notification.object as? GCController
    //        if let controller = Self.controller {
    //            print("◦ connected")
    //
    //            if let controller = controller.extendedGamepad {
    //                controller.buttonX.valueChangedHandler = { _, _, isPressed in
    //                    Task { @MainActor in
    //                        ControllerInputSystem.circleButtonChanged(isPressed)
    //                    }
    //                }
    //            } else if let controller = controller.microGamepad {
    //                controller.buttonX.valueChangedHandler = { _, _, isPressed in
    //                    Task { @MainActor in
    //                        ControllerInputSystem.circleButtonChanged(isPressed)
    //                    }
    //                }
    //            }
    //
    //            // Register the haptic utility.
    //            HapticUtility.initHapticsFor(controller: controller)
    //        }
    //    }
    //
    //    func didDisconnectController(_ notification: Notification) {
    //        print("◦ disconnected")
    //        // Unregister the haptic utility.
    //        if let controller = notification.object as? GCController {
    //            HapticUtility.deinitHapticsFor(controller: controller)
    //        }
    //
    //        Self.controller = nil
    //    }

    //    @MainActor static func jumpButtonChanged(_ isPressed: Bool) {
    //        if isPressed {
    //            ControllerInputSystem.jumpPressed = true
    //        }
    //    }
    //
    //    @MainActor static func circleButtonChanged(_ isPressed: Bool) {
    //        if isPressed {
    //            ControllerInputSystem.circlePressed = true
    //        }
    //    }

    public mutating func update(context: SceneUpdateContext) {
        guard let controller = GCController.current else { return }

        let cameraEntities = context.entities(
            matching: EntityQuery(where: .has(ControllerInputReceiver.self)),
            updatingSystemWhen: .rendering
        )
        var entitiesEmpty = true

        for entity in cameraEntities {
            guard
                var inputReceiverComponent = entity.components[
                    ControllerInputReceiver.self
                ]
            else { continue }
            entitiesEmpty = false

            // GCController의 extendedGamepad에서 조이스틱 축 값을 매 프레임마다 읽어와서 leftJoystick에 저장
            if let gamepad = controller.extendedGamepad {
                inputReceiverComponent.leftJoystick = [
                    gamepad.leftThumbstick.xAxis.value,
                    gamepad.leftThumbstick.yAxis.value,
                ]
            }
            //                if gamepad.buttonA.isPressed != inputReceiverComponent.jumpPressed {
            //                    inputReceiverComponent.jumpPressed = gamepad.buttonA.isPressed
            //                }
            //                if Self.circlePressed {
            //                    inputReceiverComponent.attackReady = true
            //                }
            //            }
            inputReceiverComponent.update(for: entity)
            entity.components.set(inputReceiverComponent)
        }

        if !entitiesEmpty {
            Self.jumpPressed = false
            Self.circlePressed = false
        }
    }
}
