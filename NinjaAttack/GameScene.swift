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

//#if !(arch(x86_64) || arch(arm64))
func sqrt(a: CGFloat) -> CGFloat {
  return CGFloat(sqrtf(Float(a)))
}
//#endif

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
  let label = SKLabelNode(fontNamed: "Chalkduster")
  var teethShot = 0
  var shots = 0
	var highscore = 0
  
  override func didMove(to view: SKView) {
    playerTextures = [texture2, texture]
    label.text = "Teeth Caught: \(teethShot)"
    label.fontSize = 10
    label.fontColor = SKColor.black
    label.position = CGPoint(x: size.width * 0.9, y: size.height * 0.95)
    addChild(label)
    backgroundColor = SKColor.lightGray
    player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
    addChild(player)
    physicsWorld.gravity = .zero
    physicsWorld.contactDelegate = self
    run(SKAction.repeatForever(
      SKAction.sequence([
        SKAction.run(addMonster),
        SKAction.wait(forDuration: 1.0)
        ])
    ))
    let backgroundMusic = SKAudioNode(fileNamed: "background-music-aac.caf")
    backgroundMusic.autoplayLooped = true
    addChild(backgroundMusic)
  }
  
  func random() -> CGFloat {
    return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
  }
  
  func random(min: CGFloat, max: CGFloat) -> CGFloat {
    return random() * (max - min) + min
  }
  
  func addMonster() {
    // Create sprite
    let monster = SKSpriteNode(imageNamed: "tooth")
    
    monster.physicsBody = SKPhysicsBody(rectangleOf: monster.size) // 1
    monster.physicsBody?.isDynamic = true // 2
    monster.physicsBody?.categoryBitMask = PhysicsCategory.tooth // 3
    monster.physicsBody?.contactTestBitMask = PhysicsCategory.toothbrush // 4
    monster.physicsBody?.collisionBitMask = PhysicsCategory.none // 5
    
    let actualY = random(min: monster.size.height/2, max: size.height - monster.size.height/2)
    monster.position = CGPoint(x: size.width + monster.size.width/2, y: actualY)
    
    // Add the monster to the scene
    addChild(monster)
    
    let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
    
    // Create the actions
    let actionMove = SKAction.move(to: CGPoint(x: -monster.size.width/2, y: actualY), duration: TimeInterval(actualDuration))
    let actionMoveDone = SKAction.removeFromParent()
    let loseAction = SKAction.run() { [weak self] in
      guard let `self` = self else { return }
      let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
			if let hScore = UserDefaults.standard.value(forKey: "highScore") as? Int {
				if self.teethShot > hScore {
					UserDefaults.standard.set(self.teethShot, forKey: "highScore")
					print("NEW HIGH SCORE")
				}
			} else {
				UserDefaults.standard.set(self.teethShot, forKey: "highScore")
				
			}
			
      let gameOverScene = GameOverScene(size: self.size, wasHighScore: false, numKilled: self.teethShot)
      self.view?.presentScene(gameOverScene, transition: reveal)
    }
    monster.run(SKAction.sequence([actionMove, loseAction, actionMoveDone]))
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else {
      return
    }
    shots += 1
    throwToothbrush()
    
    run(SKAction.playSoundFileNamed("pew-pew-lei.caf", waitForCompletion: false))
    
    let touchLocation = touch.location(in: self)

    let projectile = SKSpriteNode(imageNamed: "toothbrush")
    projectile.position = player.position
    
    projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
    projectile.physicsBody?.isDynamic = true
    projectile.physicsBody?.categoryBitMask = PhysicsCategory.toothbrush
    projectile.physicsBody?.contactTestBitMask = PhysicsCategory.tooth
    projectile.physicsBody?.collisionBitMask = PhysicsCategory.none
    projectile.physicsBody?.usesPreciseCollisionDetection = true

    let offset = touchLocation - projectile.position

    if offset.x < 0 { return }
    addChild(projectile)

    let direction = offset.normalized()
    let shootAmount = direction * 1000
    let realDest = shootAmount + projectile.position

    let actionMove = SKAction.move(to: realDest, duration: 2.0)
    let actionMoveDone = SKAction.removeFromParent()
    projectile.run(SKAction.sequence([actionMove, actionMoveDone]))
  }
  
  func moveMj() {
    if shots % 2 == 0 {
      player.texture = texture
    } else {
      player.texture = texture2
    }
  }
  
  func throwToothbrush() {
    player.run(SKAction.animate(with: playerTextures, timePerFrame: 0.2))
  }
  
  func projectileDidCollideWithMonster(projectile: SKSpriteNode, monster: SKSpriteNode) {
    projectile.removeFromParent()
    monster.removeFromParent()
    teethShot += 1
    label.text = "Teeth Caught: \(teethShot)"
  }
}

extension GameScene: SKPhysicsContactDelegate {
  func didBegin(_ contact: SKPhysicsContact) {
    // 1
    var firstBody: SKPhysicsBody
    var secondBody: SKPhysicsBody
    if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
      firstBody = contact.bodyA
      secondBody = contact.bodyB
    } else {
      firstBody = contact.bodyB
      secondBody = contact.bodyA
    }
    
    // 2
    if ((firstBody.categoryBitMask & PhysicsCategory.tooth != 0) &&
      (secondBody.categoryBitMask & PhysicsCategory.toothbrush != 0)) {
      if let monster = firstBody.node as? SKSpriteNode,
        let projectile = secondBody.node as? SKSpriteNode {
        
        projectileDidCollideWithMonster(projectile: projectile, monster: monster)
      }
    }
  }
}
