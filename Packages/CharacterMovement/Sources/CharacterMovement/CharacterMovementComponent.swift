/*
  Copyright © 2025 Apple Inc.

  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import RealityKit
import SwiftUI

/// 캐릭터의 이동정보를 관리하는 컴포넌트
public struct CharacterMovementComponent: Component {
    /// 컨트롤러 입력에 따른 캐릭터 이동 방향
    public var controllerDirection: SIMD3<Float> = [0, 0, 0]

    /// 추적 및 제어
    /// 마지막 이동 벡터를 저장하여 캐릭터의 움직임을 제어합니다.
    public var lastLinear: SIMD3<Float> = [0, 0, 0]

    /// 방향 오프셋 (90도 x축 회전)
    public var orientOffset: simd_quatf = .init(angle: 90, axis: [1, 0, 0])

    /// The character wants to jump.
    /// 점프 준비 상태
    public var jumpReady = false

    /// 캐릭터 이동 일시정지 상태
    public var paused = false

    /// 점프 버튼 누름 상태 (누르면 jumpReady를 true로 설정)
    public var jumpPressed = false {
        didSet {
            if jumpPressed { jumpReady = true }
        }
    }

    // TODO: - 추후 애니메이션 구현 시 추가 개발

    public var characterProxy: String?

    public init(characterProxy: String? = nil) {
        self.characterProxy = characterProxy
        Task { @MainActor in
            CharacterMovementSystem.registerSystem()
        }
    }

    /// 캐릭터 업데이트 시 호출되는 커스텀 콜백 함수
    public var update: (Entity, _ velocity: SIMD3<Float>, _ deltaTime: TimeInterval) -> Void = { _, _, _ in }
}
