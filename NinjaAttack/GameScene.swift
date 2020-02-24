import SpriteKit

func +(left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func -(left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func *(point: CGPoint, scalar: CGFloat) -> CGPoint {
  return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func /(point: CGPoint, scalar: CGFloat) -> CGPoint {
  return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

func sqrt(a: CGFloat) -> CGFloat {
  return CGFloat(sqrtf(Float(a)))
}

extension CGPoint {
  func length() -> CGFloat {
    return sqrt(x*x + y*y)
  }
  
  func normalized() -> CGPoint {
    return self / length()
  }
}

class GameScene: SKScene {
  
  struct PhysicsCategory {
    static let none      : UInt32 = 0
    static let all       : UInt32 = UInt32.max
    static let tooth   : UInt32 = 0b1       // 1
    static let toothbrush: UInt32 = 0b10      // 2
  }

  let texture = SKTexture(imageNamed: "mj1")
  let texture2 = SKTexture(imageNamed: "mj2")
  var playerTextures: [SKTexture] = []
  var player = SKSpriteNode(texture: SKTexture(imageNamed: "mj1"))
  let teethBrushedLabel = SKLabelNode(fontNamed: "Chalkduster")
  var teethBrushed = 0
  var toothBrushesThrown = 0
  
  override func didMove(to view: SKView) {
    playerTextures = [texture2, texture]
    teethBrushedLabel.text = "Teeth Brushed: \(teethBrushed)"
    teethBrushedLabel.fontSize = 15
    teethBrushedLabel.fontColor = SKColor.black
    teethBrushedLabel.position = CGPoint(x: size.width * 0.85, y: size.height * 0.85)
    addChild(teethBrushedLabel)
    backgroundColor = SKColor.lightGray
    player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
    let highScore = UserDefaults.standard.integer(forKey: "highScore")
    
    let highScoreLabel = SKLabelNode()
    highScoreLabel.fontName = "Chalkduster"
    highScoreLabel.fontSize = 15
    highScoreLabel.text = "High Score: \(highScore)"
    highScoreLabel.fontColor = SKColor.black
    highScoreLabel.position = CGPoint(x: size.width * 0.85, y: size.height * 0.9)
    addChild(player)
    
    addChild(highScoreLabel)
    physicsWorld.gravity = .zero
    physicsWorld.contactDelegate = self
    run(SKAction.repeatForever(
      SKAction.sequence([
        SKAction.run(addTooth),
        SKAction.wait(forDuration: 1.0)
        ])
    ))
  }
  
  func random() -> CGFloat {
    return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
  }
  
  func random(min: CGFloat, max: CGFloat) -> CGFloat {
    return random() * (max - min) + min
  }
  
  func addTooth() {
    let tooth = SKSpriteNode(imageNamed: "tooth")
    tooth.physicsBody = SKPhysicsBody(rectangleOf: tooth.size)
    tooth.physicsBody?.isDynamic = true
    tooth.physicsBody?.categoryBitMask = PhysicsCategory.tooth
    tooth.physicsBody?.contactTestBitMask = PhysicsCategory.toothbrush
    tooth.physicsBody?.collisionBitMask = PhysicsCategory.none
    let actualY = random(min: tooth.size.height/2, max: size.height - tooth.size.height/2)
    tooth.position = CGPoint(x: size.width + tooth.size.width/2, y: actualY)
    addChild(tooth)
    
    let actualDuration = random(min: CGFloat(1.5), max: CGFloat(4.0))

    let actionMove = SKAction.move(to: CGPoint(x: -tooth.size.width/2, y: actualY), duration: TimeInterval(actualDuration))
    let actionMoveDone = SKAction.removeFromParent()
    let loseAction = SKAction.run() { [weak self] in
      guard let `self` = self else { return }
      let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
      let accuracy: Double
      if self.toothBrushesThrown != 0 {
        accuracy = Double(self.teethBrushed) / Double(self.toothBrushesThrown)
      } else {
        accuracy = 0
      }
      let gameOverScene = GameOverScene(size: self.size, teethBrushed: self.teethBrushed, accuracy: accuracy)
      self.view?.presentScene(gameOverScene, transition: reveal)
    }
    tooth.run(SKAction.sequence([actionMove, loseAction, actionMoveDone]))
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else {
      return
    }
    toothBrushesThrown += 1
    throwToothbrush()
    
    run(SKAction.playSoundFileNamed("pew-pew-lei.caf", waitForCompletion: false))
    
    let touchLocation = touch.location(in: self)

    let toothbrush = SKSpriteNode(imageNamed: "toothbrush")
    toothbrush.position = player.position
    
    toothbrush.physicsBody = SKPhysicsBody(circleOfRadius: toothbrush.size.width/2)
    toothbrush.physicsBody?.isDynamic = true
    toothbrush.physicsBody?.categoryBitMask = PhysicsCategory.toothbrush
    toothbrush.physicsBody?.contactTestBitMask = PhysicsCategory.tooth
    toothbrush.physicsBody?.collisionBitMask = PhysicsCategory.none
    toothbrush.physicsBody?.usesPreciseCollisionDetection = true

    let offset = touchLocation - toothbrush.position

    if offset.x < 0 { return }
    addChild(toothbrush)
    let direction = offset.normalized()
    let throwLength = direction * 1000
    let realDest = throwLength + toothbrush.position

    let actionMove = SKAction.move(to: realDest, duration: 2.0)
    let actionMoveDone = SKAction.removeFromParent()
    toothbrush.run(SKAction.sequence([actionMove, actionMoveDone]))
  }
  
  func throwToothbrush() {
    player.run(SKAction.animate(with: playerTextures, timePerFrame: 0.2))
  }
  
  func toothBrushDidCollideWithTooth(projectile: SKSpriteNode, tooth: SKSpriteNode) {
    projectile.removeFromParent()
    tooth.removeFromParent()
    teethBrushed += 1
    teethBrushedLabel.text = "Teeth Brushed: \(teethBrushed)"
  }
}

extension GameScene: SKPhysicsContactDelegate {
  func didBegin(_ contact: SKPhysicsContact) {
    var firstBody: SKPhysicsBody
    var secondBody: SKPhysicsBody
    if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
      firstBody = contact.bodyA
      secondBody = contact.bodyB
    } else {
      firstBody = contact.bodyB
      secondBody = contact.bodyA
    }
    if ((firstBody.categoryBitMask & PhysicsCategory.tooth != 0) &&
      (secondBody.categoryBitMask & PhysicsCategory.toothbrush != 0)) {
      if let tooth = firstBody.node as? SKSpriteNode,
        let toothbrush = secondBody.node as? SKSpriteNode {
        toothBrushDidCollideWithTooth(projectile: toothbrush, tooth: tooth)
      }
    }
  }
}
