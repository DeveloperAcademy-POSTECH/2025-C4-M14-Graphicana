import CharacterMovement
import ControllerInput
import RealityKit

extension GameView {
    // 캐릭터 기본 설정을 해주는 함수
    func characterSetup(_ character: Entity) async {
        /// 캐릭터의 시각적 경계(bound)를 계산해준다.
        let bounds = character.visualBounds(relativeTo: character.parent)

        character.position.y = bounds.extents.y / 2 + 5
        //        hero.transform.rotation = simd_quatf(angle: -.pi / 2, axis: [1, 0, 0])

        /// 필요한 컴포넌트들을 설정해준다.
        await character.components.set(
            configureCharacterComponents(bounds: bounds)
        )

        // TODO: - 캐릭터 애니메이션 적용시 적용
        //        /// 맥스 엔티티 + 애니메이션 라이브러리를 찾아온다.
        //        guard let ttouchRoot = hero.findEntity(named: "Ttouch"),
        //              let animationLibrary = ttouchRoot.components[AnimationLibraryComponent.self]
        //        else { return }

        //        // 상태별 애니메이션을 설정한다.
        //        var anims = [CharacterStateComponent.CharacterState: AnimationResource]()

        //        // 점프 애니메이션 특수 조정 부분
        //        var jumpAnimation = animationLibrary.animations["jump"]
        //        var endOfJump = jumpAnimation?.definition
        //        let endOfJumpDuration = endOfJump?.duration ?? 1.0
        //        /// 점프 애니메이션 마지막 0.1초를 자른다.
        //        endOfJump?.trimStart = endOfJumpDuration - 0.1

        // Create a filler animation after the initial jump animation
        // to hold the jumping position.
        /// 잘라놓은 0.1초를 반복 재생하여 점프 상태 유지 효과 발생시킨다.
        //        if let jump = jumpAnimation, let endOfJump,
        //           let endOfJumpAnimation = try? AnimationResource.generate(with: endOfJump),
        //           let sequenceJump = try? AnimationResource.sequence(with: [jump, endOfJumpAnimation.repeat()])
        //        {
        //            jumpAnimation = sequenceJump
        //        }

        //        /// 오디오와 애니메이션 효과를 결합시킨다.
        //        anims[.jump] = jumpAnimation?.combineWithAudio(named: "jump")
        ////        anims[.spin] = animationLibrary.animations["spin"]?.combineWithAudio(named: "attack")
        //        anims[.idle] = animationLibrary.animations["idle"]?.repeat()
        //        anims[.walking] = animationLibrary.animations["walk"]?.repeat()

        //        // 각 캐릭터 상태들(idle, walking, jump, spin)에 대해서 해당 애니메이션 상태들을 연결한다.
        //        let characterStates = CharacterStateComponent(animations: anims)
        // 생성된 컴포넌트를 히어로 엔티티에 부착한다.
        //        hero.components.set(characterStates)

        //        // Register the attack actions.
        //        HeroAttackAction.registerAction()
        //        HeroAttackActionHandler.register { _ in
        //            HeroAttackActionHandler()
        //        }
    }

    // 캐릭터에 필요한 모든 핵심 컴포넌트를 생성하고 구성하는 함수
    /// input: bounds (캐릭터의 시각적 경계)
    func configureCharacterComponents(bounds: BoundingBox) async
        -> [any Component]
    {
        // 충돌 형상 생성
        let collisionRadius = bounds.extents.x / 2
        /// 캐릭터 너비를 기반으로 충돌 반경 계산
        let characterCollisionShape: ShapeResource = .generateCapsule(
            /// 캡슐 형태의 충돌 형상을 생성
            height: bounds.extents.y,
            radius: collisionRadius,
        )
        .offsetBy(translation: [0, bounds.extents.y, 0]) // 형상 중심점을 캐릭터 중심으로 조정

        // 물리 속성 설정하기: 동적 물리 바디 생성 (물리 시뮬레이션)
        var characterPhysicsBodyComponent = PhysicsBodyComponent(
            shapes: [characterCollisionShape],
            mass: 1.0,
            mode: .dynamic,
        )

        characterPhysicsBodyComponent.material =
            PhysicsMaterialResource.generate(
                friction: 0.2,
                /// 마찰 계수 0.2 (약간 미끄러짐이 있음)
                restitution: 0.0 /// 반발 계수 0.0 (충돌 시 튕겨나가지 않음)
            )

        /// 각운동 감쇠값을 높게 설정하여 회전 저항을 크게 함
        characterPhysicsBodyComponent.angularDamping = 0

        // 이동 제어 설정
        /// 캐릭터 이동 관련 컴포넌트 생성
        var moveComponent = CharacterMovementComponent(
            characterProxy: "Cube_027"
        )
        /// 이동 업데이트 함수
        moveComponent.update = characterMoveUpdated(entity:velocity:deltaTime:)
        //        moveComponent.handleKeypress = characterKeypress(keypress:)

        return [
            CharacterComponent(), // 히어로 마커 컴포넌트
            moveComponent, // 캐릭터 이동 로직
            characterPhysicsBodyComponent, // 물리 바디 컴포넌트
            ControllerInputReceiver(update: controllerInputUpdater), // 컨트롤러 입력 업데이트
            // 충돌 감지용 컴포넌트
            CollisionComponent(
                shapes: [characterCollisionShape],
                mode: .default,
                filter: characterCollisionFilter
            ),
            // 물리 캐릭터 제어
            CharacterControllerComponent(
                radius: collisionRadius,
                height: bounds.extents.y,
                collisionFilter: characterCollisionFilter
            ),
        ]
    }

    /// 충돌 이벤트 발생 시 캐릭터를 시작 위치로 돌리는 역할을 하는 함수
    /// 캐릭터가 추락했거나 금지된 영역에 접근했을 때 원래 위치로 복귀시키는 안전장치 역할
    func resetMaxPosition(event: CollisionEvents.Began) {
        var maxParent = event.entityB
        if maxParent.name != "Ttouch" {
            maxParent = event.entityA
            if maxParent.name != "Ttouch" { return }
        }
        maxParent.teleportCharacter(
            to: [0, 1.0, -0.25],
            relativeTo: maxParent.parent
        )
    }

    /// 멈춤 상태 처리 함수
    func stopMaxInputs(character: Entity) {
        if var characterStateComponent = character.components[
            CharacterStateComponent.self
        ],
            var characterMovementComponent = character.components[
                CharacterMovementComponent.self
            ]
        {
            //            character.stopAllAnimations()  // 진행 중인 애니메이션 중지
            //            character.stopAllAudio()  // 진행 중인 오디오 중지
            characterStateComponent.currentState = .idle // 캐릭터 상태를 idle로 설정
            character.components.set(characterStateComponent) // 상태 컴포넌트 업데이트

            characterMovementComponent.paused = true // 이동 컴포넌트 일시 정지
            character.components.set(characterMovementComponent) // 이동 컴포넌트 업데이트
        }
    }
}
