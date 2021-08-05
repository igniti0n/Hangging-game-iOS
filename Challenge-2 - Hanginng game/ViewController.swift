//
//  ViewController.swift
//  Challenge-2 - Hanginng game
//
//  Created by Ivan Stajcer on 05.08.2021..
//

import UIKit

class ViewController: UIViewController {
    
    var answerLabel : UILabel!
    var life : UIProgressView!
    var lifeLabelTop : UILabel!
   
    var buttons = [UIButton]()
    var alphabet = [String]()
    
    var allWords = [String]()
    var answerdLetters = Set<Character>()
    var wordToFind : String!
    var lifeProgress : Float = 100.0 {
        didSet {
            life.progress = lifeProgress/100.0
            
        }
    }
    
    
    override func loadView() {
        super.loadView()
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.white
        view = backgroundView
        
        loadAlphabet()
        
        answerLabel = UILabel()
        answerLabel.translatesAutoresizingMaskIntoConstraints = false
        answerLabel.text = "_ _ _ _ _"
        answerLabel.font = UIFont.systemFont(ofSize: 100)
        view.addSubview(answerLabel)
        
        lifeLabelTop = UILabel()
        lifeLabelTop.translatesAutoresizingMaskIntoConstraints = false
        lifeLabelTop.text = "Life"
        lifeLabelTop.adjustsFontSizeToFitWidth = true
        lifeLabelTop.numberOfLines = 1
        lifeLabelTop.minimumScaleFactor = 2
        lifeLabelTop.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        lifeLabelTop.font = UIFont.systemFont(ofSize: 80)
        view.addSubview(lifeLabelTop)
        
        life = UIProgressView(progressViewStyle: .default)
        life.translatesAutoresizingMaskIntoConstraints = false
        life.progress = 1
        life.layer.borderWidth = 2
        life.layer.borderColor = UIColor.lightGray.cgColor
        
        view.addSubview(life)
        
        let buttonsView = UIView()
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonsView)
                
        
        //CONSTRAINTS
        NSLayoutConstraint.activate([
            answerLabel.topAnchor.constraint(greaterThanOrEqualTo: view.layoutMarginsGuide.topAnchor , constant: 10),
            answerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
           
            lifeLabelTop.topAnchor.constraint(equalTo: answerLabel.bottomAnchor, constant: 10),
            lifeLabelTop.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            life.topAnchor.constraint(equalTo: lifeLabelTop.bottomAnchor,constant: 10),
            life.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / 2),
            life.heightAnchor.constraint(equalToConstant: 40),
            life.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            buttonsView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 40),
            buttonsView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -40),
            buttonsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonsView.heightAnchor.constraint(equalToConstant: 720),
            buttonsView.topAnchor.constraint(equalTo: life.bottomAnchor, constant: 10),
            buttonsView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: 10)
            
            
        ])
        
       
  
        
        let buttonWidth =  (UIScreen.main.bounds.width / 6) + 4//
        let buttonHeight = 720 / 6
        var currentItteration : Int = 0
        for row in 0...5{
            for column in 0...4 {
                currentItteration += 1
                
                if currentItteration == 27 {
                    break
                }
                
                let newButton = UIButton(type: .system)
                newButton.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
                newButton.frame = CGRect(x: CGFloat(column) * buttonWidth, y: CGFloat(row) * CGFloat(buttonHeight), width: buttonWidth-2, height: CGFloat(buttonHeight-2))
                
                newButton.layer.borderWidth = 1
                newButton.layer.borderColor = UIColor.gray.cgColor
                newButton.layer.cornerRadius = 5
                
                newButton.titleLabel?.font = UIFont.systemFont(ofSize: 44)
                buttons.append(newButton)
                buttonsView.addSubview(newButton)
            }
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        performSelector(inBackground: #selector(loadAllWords), with: nil)
        
    }
  
    
    @objc private func loadAllWords() {
        
        guard let wordsUrl = Bundle.main.url(forResource: "words", withExtension: ".txt") else {return}
        
        if let wordsString = try? String(contentsOf: wordsUrl){
            allWords = wordsString.components(separatedBy: "\n")
            wordToFind = allWords.randomElement()!
            print("word to find: \(wordToFind), number of letters: \(wordToFind.count)")
            performSelector(onMainThread: #selector(updateAnswerLabel), with: nil, waitUntilDone: false)
        }
        
    }
    
    
    @objc func updateAnswerLabel(){
        answerLabel.text?.removeAll(keepingCapacity: true)
        print(answerdLetters)
       
        for letter in wordToFind {
            
            let wordToAddToAnswer = answerdLetters.contains(Character(letter.uppercased())) ? "\(letter)  " : "_  "
            answerLabel.text?.append(wordToAddToAnswer)
        }
        
        if let contains = answerLabel.text?.contains("_") {
            if !contains {
                gameOver(true)
            }
        }
        
    }
    
    private func gameOver(_ didWin : Bool){
        
        
        if didWin {
            let ac = UIAlertController(title: "Congratulations!", message: "You got the word.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Great", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
        }else{
            let ac = UIAlertController(title: "Game over!", message: "You missed the word: \(wordToFind!)", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
        }
        
        answerdLetters.removeAll(keepingCapacity: true)
        wordToFind = allWords.randomElement()!
        lifeProgress = 100.0
        for button in buttons {
            button.isHidden = false
        }
        updateAnswerLabel()
      
    }
    
    
    @objc func loadAlphabet() {
        
        DispatchQueue.global().async {
            [weak self] in
            guard let wordsUrl = Bundle.main.url(forResource: "alphabet", withExtension: ".txt") else {
                return
            }
            
            if let wordsString = try? String(contentsOf: wordsUrl){
                DispatchQueue.main.async {
                    [weak self] in
                    self?.alphabet = wordsString.components(separatedBy: ",")
                    
                    guard let buttons = self?.buttons else {return}
                    
                    for (index, button) in buttons.enumerated() {
                        button.setTitle(String(self?.alphabet[index] ?? "X"), for: .normal)
                    }
                }
                
               
            }
        }
    }
    
    @objc private func buttonPressed(_ sender: UIButton){
        print("PRESSED")
        guard let letter = sender.titleLabel?.text?.first else {return}
        print("letter is: \(letter)")
        if wordToFind.lowercased().contains(letter.lowercased()){
            print("word containts this letter")
            answerdLetters.insert(letter)
            updateAnswerLabel()
           
        }else{
            lifeProgress -= 20.0
            if lifeProgress < 10.0 {
                gameOver(false)
                return
            }
        }
        
        sender.isHidden = true
    }
    
    
    
}

