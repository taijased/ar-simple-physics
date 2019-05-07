# AR Simple physics



1) Add physics for Box

```
let physicsShape = SCNPhysicsShape(geometry: self.geometry!, options: nil)
self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: physicsShape)
self.physicsBody?.categoryBitMask = BitMaskCategory.box
self.physicsBody?.collisionBitMask = BitMaskCategory.box | BitMaskCategory.plane
self.physicsBody?.contactTestBitMask = BitMaskCategory.plane
```

2) Add physics for Plane

```
let physicsShape = SCNPhysicsShape(geometry: self.geometry!, options: nil)
self.physicsBody = SCNPhysicsBody(type: .static, shape: physicsShape)
self.physicsBody?.categoryBitMask = BitMaskCategory.plane
self.physicsBody?.collisionBitMask = BitMaskCategory.box
self.physicsBody?.contactTestBitMask = BitMaskCategory.box
```


3) Subscribe delegate before created sceneView
```
sceneView.scene.physicsWorld.contactDelegate = self
```

4) Extension SCNPhysicsContactDelegate
```
extension ViewController: SCNPhysicsContactDelegate {
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let nodeA = contact.nodeA
        let nodeB = contact.nodeB
        if nodeB.physicsBody?.contactTestBitMask == BitMaskCategory.box {
            nodeA.geometry?.materials.first?.diffuse.contents = UIColor.red
            return
        }
        nodeB.geometry?.materials.first?.diffuse.contents = UIColor.red
    }
}

```
## Helper bit maskategory 

```
struct BitMaskCategory {
    static let none = 0 << 0
    static let box = 1 << 0
    static let plane = 1 << 1
}

```
