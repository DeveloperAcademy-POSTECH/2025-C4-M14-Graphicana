# WorldCameraComponent

A component that frames immersive or portal worlds.

## Usage

Choose an entity as your target in a scene, and add this component to it as such:

```swift
// The target entity, which might be, for example, a character in a game.
let character = Entity(named: "fenton")

// ...

// Set the component on the character entity.
character.components.set(WorldCameraComponent())
```

To choose the angle at which the camera looks at the target entity, update the `azimuth`, `elevation`, `radius`, or `targetOffset` values.

```swift
var cameraComponent = WorldCameraComponent(
    azimuth: .pi,
    elevation: 0,
    radius: 2,
)
cameraComponent.targetOffset = [0, -0.75, 0]
```

You can set these values at any time, and the world camera system keeps the scene orientation up to date.
