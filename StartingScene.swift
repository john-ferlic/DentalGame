import SpriteKit
import Foundation

class StartingScene: SKScene {
  
  private var label: SKLabelNode?
  
  override init(size: CGSize) {
    super.init(size: size)
    backgroundColor = SKColor.black
    addSprites(node: "tooth", y: size.height * 0.9)
    addSprites(node: "mj1", y: size.height * 0.20)
    label = SKLabelNode(fontNamed: "Chalkduster")
    let subText = SKLabelNode(fontNamed: "Chalkduster")
    subText.text = "Shoot 30 teeth to win the game!"
    subText.fontSize = 20
    subText.fontColor = SKColor.white
    subText.position = CGPoint(x: size.width/2, y: size.height * 0.40)
    guard let button = label else { return }
    button.text = "Start"
    button.fontSize = 60
    button.fontColor = SKColor.white
    button.position = CGPoint(x: size.width/2, y: size.height * 0.6)
    addChild(button)
    addChild(subText)
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    for t in touches {
      self.touchDown(atPoint: t.location(in: self))
    }
  }
  
  func touchDown(atPoint pos: CGPoint){
    let nodes = self.nodes(at: pos)
    if let butt = label {
      if nodes.contains(butt){
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        let game = GameScene(size: self.size)
        view?.presentScene(game, transition: reveal)
      }
    }
  }
  
  func addSprites(node: String, y: CGFloat) {
    let length = size.width
    let sprite = SKSpriteNode(imageNamed: node)
    let numOfNodes = Int(length / sprite.size.width) + 3
    var xPos = CGFloat(0.0)
    
    
    for _ in 0 ..< numOfNodes {
      let sprite = SKSpriteNode(imageNamed: node)
      let position = CGPoint(x: xPos, y: y)
      sprite.position = position
      addChild(sprite)
      xPos += sprite.size.width
    }
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
