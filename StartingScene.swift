/// Copyright (c) 2020 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

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
      print("Added a tooth")
    }
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
