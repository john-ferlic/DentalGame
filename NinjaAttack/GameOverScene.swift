import Foundation
import SpriteKit

class GameOverScene: SKScene {
  
  init(size: CGSize, teethBrushed: Int, accuracy: Double) {
    super.init(size: size)
    let accuracyString = String(format: "%.0f", accuracy*100)
    let score = ((Int(accuracyString) ?? 0) * teethBrushed)/10
    let mainLabel = SKLabelNode()
		var highScore = UserDefaults.standard.integer(forKey: "highScore")
    if score > highScore {
      highScore = score
      UserDefaults.standard.set(highScore, forKey: "highScore")
      mainLabel.text = "Congrats! You have a new High Score: \(highScore)"
      mainLabel.fontSize = 30
    } else {
      mainLabel.text = "Your Score: \(score)"
      mainLabel.fontSize = 50
    }
    mainLabel.fontName = "Chalkduster"

    mainLabel.fontColor = SKColor.white
    mainLabel.position = CGPoint(x: size.width/2, y: size.height/2)
    backgroundColor = SKColor.blue
    let highScoreLabel = SKLabelNode()
    highScoreLabel.fontName = "Chalkduster"
    highScoreLabel.fontSize = 15
    highScoreLabel.text = "High Score: \(highScore)"
    highScoreLabel.fontColor = SKColor.white
    highScoreLabel.position = CGPoint(x: size.width * 0.85, y: size.height * 0.9)
    let accuracyLabel = SKLabelNode()
    accuracyLabel.fontName = "Chalkduster"
    accuracyLabel.fontSize = 15
    accuracyLabel.text = "Accuracy: \(accuracyString)%"
    accuracyLabel.fontColor = SKColor.white
    accuracyLabel.position = CGPoint(x: size.width * 0.85, y: size.height * 0.85)
    let playAgainLabel = SKLabelNode(fontNamed: "Chalkduster")
    playAgainLabel.text = "Tap the screen to play again"
    playAgainLabel.fontSize = 15
    playAgainLabel.fontColor = SKColor.white
    playAgainLabel.position = CGPoint(x: size.width/2, y: size.height/5)
    addChild(playAgainLabel)
    addChild(mainLabel)
    addChild(highScoreLabel)
    addChild(accuracyLabel)
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    view?.presentScene(GameScene(size: self.size), transition: SKTransition.flipVertical(withDuration: 0.5))
  }
}
