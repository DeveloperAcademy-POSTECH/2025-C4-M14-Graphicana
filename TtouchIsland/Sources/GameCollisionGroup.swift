import RealityKit

// 어떤 객체가 어떤 객체와 충돌할 수 있는지를 구분하기 위한 설정
struct GameCollisionGroup {
    // CollisionGroup: 충돌 그룹, RealityKit에서 엔티티 간 충돌 여부를 결정
    // 1 << N 형태의 비트마스크
    static let player = CollisionGroup(rawValue: 1 << 0)  // == 1
    static let environment = CollisionGroup(rawValue: 1 << 1)  // == 2
    //    static let lava = CollisionGroup(rawValue: 1 << 2)
    //    static let collectable = CollisionGroup(rawValue: 1 << 3)
    static let enemy = CollisionGroup(rawValue: 1 << 4)  // == 16
    //    static let enemyWeapon = CollisionGroup(rawValue: 1 << 5)
    static let camera = CollisionGroup(rawValue: 1 << 6)  // == 64
    static let cameraAdjusters = CollisionGroup(rawValue: 1 << 7)  // == 128
    //    static let areaTrigger = CollisionGroup(rawValue: 1 << 8)
    //    static let door = CollisionGroup(rawValue: 1 << 9)
}

struct GameCollisionFilters {
    fileprivate static let movingCharacters: CollisionGroup = [
        GameCollisionGroup.player, GameCollisionGroup.enemy,
    ]

    // CollisionFilter: 충돌을 결정할 때 어떤 그룹과 충돌할지를 지정
    static let terrainFilter = CollisionFilter(
        group: GameCollisionGroup.environment,  // group: 자신이 속한 그룹, 즉 enviroment에 속해있고
        mask: movingCharacters  // mask: 충돌할 수 있는 그룹, player와 enemy와 충돌
    )
}
