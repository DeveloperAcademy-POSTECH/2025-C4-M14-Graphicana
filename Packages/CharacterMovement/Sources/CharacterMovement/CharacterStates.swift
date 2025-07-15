/*
  Copyright © 2025 Apple Inc.

  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import Combine
import GameKit
import RealityKit

/// A component that holds the current state of a character.
public struct CharacterStateComponent: Component {
    /// 캐릭터 기본 상태를 정의
    /// 각 상태들은 애니메이션의 파일명들과 연결된다.
    public enum CharacterState: String, CaseIterable {
        case idle
        case walking = "walk"
        case jump

        @MainActor public static var prefix: String = ""
        var filename: String { rawValue }
    }

    @MainActor
    static var bundle: Bundle?

    /// 현재 캐릭터의 상태
    public var currentState: CharacterState?

    /// 상태별 애니메이션 리소스 맵핑
    var animations: [CharacterState: AnimationResource] = [:]

    /// 캐릭터의 가능한 상태들
    var animationStates: [CharacterState]

    /// 애니메이션 재생 컨트롤러
    var animController: AnimationPlaybackController?

    /// 캐릭터가 불타고 있는지 여부 (특수 상태 플래그)
    public var isOnFire: Bool = false

    /// - 상태에 따른 애니메이션 속도 계산
    /// - 걷기: 입력된 속도 그대로, 점프: 2, 나머지: 1
    fileprivate static func calculateControllerSpeed(
        for state: CharacterStateComponent.CharacterState, speed movementSpeed: Float
    ) -> Float {
        switch state {
        case .walking: movementSpeed
        case .jump: 2
        default: 1
        }
    }

    /// - 현재 상태에서 새로운 상태로 전환이 가능한지 여부를 파악한다
    /// - 상태별 특수 처리 로직을 포함한다.
    ///   - 걷기 -> 대기 : 애니메이션 중지 및 불투명도 복원
    ///   - 점프 : 바닥에 닿았거나 애니메이션이 재생 중이지 않을 때만 전환
    @MainActor fileprivate static func changeCurrentState(
        entity: Entity, // 상태를 변경할 대상 엔티티
        _ currentState: CharacterState?, // 현재 상태
        isOnGround: Bool, // 바닥에 닿아 있는지 여부
        newState: CharacterState, // 새로운 상태
        isAnimationPlaying: Bool, // 애니메이션이 재생 중인지 여부
        transitionDuration: inout Double // 상태 전환에 필요한 시간 (초 단위, 기본값: 0.3초)
    ) -> Bool {
        switch currentState {
        /// - 걷기 소리 & 애니메이션 중지
        /// - 불투명도 1.0으로 복원 (적에게 공격받아서 변경되었을 수 있음)
        case .walking where newState == .idle:
            entity.stopAllAudio()
            entity.stopAllAnimations()

            // Set the opacity back to `1.0` in case an enemy hits Max.
            if let opacityFull = try? AnimationResource.makeActionAnimation(
                for: FromToByAction(to: Float(1.0)), duration: 0.1, bindTarget: .opacity
            ) {
                entity.playAnimation(opacityFull, transitionDuration: 0.1)
            }

        /// - 점프 -> 다른 상태
        /// - 전환 조건 : 캐릭터가 바닥에 닿아 있거나 애니메이션이 재생 중이지 않을 때
        case .jump:
            guard isOnGround || !isAnimationPlaying
            else { return false }
            transitionDuration = 0.1

        case .none, .idle, .walking: break

        default:
            let oldState = currentState?.rawValue ?? "nil"
            fatalError("not yet handling \(oldState) to \(newState)")
        }
        return true
    }

    /// 이 함수는 캐릭터의 상태를 업데이트하고 그에 맞는 애니메이션을 재생하는 핵심 메서드입니다.
    @MainActor // 메인 스레드에서만 실행됨
    @discardableResult // 반환값을 사용하지 않아도 경고가 발생하지 않음
    public static func updateState(
        for entity: Entity, // 상태를 업데이트할 엔티티
        to newState: CharacterState, // 새로운 상태
        movementSpeed: Float, // 캐릭터의 이동 속도
        childProxy proxyName: String? = nil // 캐릭터 모델을 애니메이션하기 위한 하위 엔티티 이름
    ) throws -> AnimationPlaybackController? {
        guard var stateComponent = entity.components[CharacterStateComponent.self],
              let controllerState = entity.components[CharacterControllerStateComponent.self]
        else { return nil }
        let playableEntity = if let proxyName, let proxyEntity = entity.findEntity(named: proxyName) {
            proxyEntity
        } else { entity }

        guard let newAnim = stateComponent.animations[newState] else {
            return nil
        }
        if stateComponent.currentState != newState {
            let allowedStates = [CharacterState.idle, .walking, .jump]
            if !allowedStates.contains(newState) {
                fatalError("Cannot handle \(newState) from nil.")
            }
            var transitionDuration: TimeInterval = 0.3
            guard changeCurrentState(
                entity: entity,
                stateComponent.currentState,
                isOnGround: controllerState.isOnGround,
                newState: newState,
                isAnimationPlaying: stateComponent.animController?.isPlaying ?? false,
                transitionDuration: &transitionDuration
            ) else { return stateComponent.animController }

            stateComponent.animController = playableEntity.playAnimation(
                newAnim, transitionDuration: transitionDuration
            )
            stateComponent.currentState = newState
        }
        // Update the speed of the animations.
        stateComponent.animController?.speed = calculateControllerSpeed(
            for: newState, speed: movementSpeed * (stateComponent.isOnFire ? 2 : 1)
        )
        entity.components.set(stateComponent)
        return stateComponent.animController
    }

    var bundle = Bundle.main
    var prefix: String = ""

    /// Creates a character component with a set of possible character states.
    /// - Parameter animationStates: The animation states to use.
    public init(
        animationStates: [CharacterState] = [.idle, .walking, .jump],
        prefix: String,
        bundle: Bundle = .main
    ) {
        self.animationStates = animationStates
        self.bundle = bundle
        self.prefix = prefix
    }

    /// Performs any necessary setup for the character animations.
    public mutating func loadAnimations() async throws {
        for animationState in animationStates {
            let nextAnim = try await Entity(
                named: prefix + animationState.filename,
                in: bundle
            ).availableAnimations.first
            animations[animationState] = nextAnim
        }
    }

    /// Creates a character component with a set of possible character states.
    /// - Parameter animations: The animation states to use.
    public init(animations: [CharacterState: AnimationResource]) {
        animationStates = Array(animations.keys)
        self.animations = animations
    }
}
