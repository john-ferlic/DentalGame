import Foundation
import SpriteKit

class GameOverScene: SKScene {
  
  private var button: SKLabelNode?
  private var highscore: Int = 0
  
  init(size: CGSize, wasHighScore:Bool, numKilled: Int) {
    super.init(size: size)
    if wasHighScore {
      highscore = numKilled
    }
    backgroundColor = SKColor.yellow
//    let message = won ? "You Won!" : "Game Over"
    let highScoreLabel = SKLabelNode()
    highScoreLabel.fontName = "Chalkduster"
    highScoreLabel.fontSize = 20
    highScoreLabel.text = "High Score: \(highscore)"
    highScoreLabel.fontColor = SKColor.black
    highScoreLabel.position = CGPoint(x: size.width * 0.85, y: size.height * 0.9)
    let message = "You Brushed \(numKilled) Teeth!"
    let label = SKLabelNode(fontNamed: "Chalkduster")
    label.text = message
    label.fontSize = 40
    label.fontColor = SKColor.black
    label.position = CGPoint(x: size.width/2, y: size.height/2)
    
    button = SKLabelNode(fontNamed: "Chalkduster")
    guard let butt = button else { return }
    butt.text = "Click here to play again"
    butt.fontSize = 20
    butt.fontColor = SKColor.black
    butt.position = CGPoint(x: size.width/2, y: size.height/5)
    addChild(butt)
    addChild(label)
    addChild(highScoreLabel)
//    run(SKAction.sequence([
//      SKAction.wait(forDuration: 3.0),
//      SKAction.run() { [weak self] in
//        guard let `self` = self else { return }
//        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
//        let scene = GameScene(size: size)
//        self.view?.presentScene(scene, transition:reveal)
//      }
//      ]))
    
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    for t in touches{
      self.touchDown(atPoint: t.location(in: self))
    }
  }
  
  func touchDown(atPoint pos: CGPoint) {
    let nodes = self.nodes(at: pos)
    if let butt = button {
      if nodes.contains(butt){
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        let game = GameScene(size: self.size)
        view?.presentScene(game, transition: reveal)
      }
    }
  }
}
