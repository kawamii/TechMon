//
//  BattleViewController.swift
//  TechMon
//
//  Created by 川上知宏 on 2021/05/15.
//

import UIKit

class BattleViewController: UIViewController {
    
    @IBOutlet var playerNameLabel: UILabel!
    @IBOutlet var playerImageView: UIImageView!
    @IBOutlet var playerHPLabel: UILabel!
    @IBOutlet var playerMPLabel: UILabel!
    
    @IBOutlet var enemyNameLabel: UILabel!
    @IBOutlet var enemyImageView: UIImageView!
    @IBOutlet var enemyHPLabel: UILabel!
    @IBOutlet var enemyMPLabel: UILabel!
    
    @IBOutlet var playerTPLabel: UILabel!
    
    let techMonManager = TechMonManager.shared
    
    var player: Character!
    var enemy: Character!
    
    var playerHP = 100
    var playerMP = 0
    var enemyHP = 200
    var enemyMP = 0
    
    var gameTimer: Timer!
    var isPlayerAttackAvailable: Bool = true
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        player = techMonManager.player
        enemy = techMonManager.enemy

        // Do any additional setup after loading the view.
        player = .init(name: "勇者", imageName: "yusya.png", attackPoint: 30, maxHP: 100, maxTP: 100, maxMP: 20)
        //playerNameLabel.text = "勇者"
        playerImageView.image = UIImage(named: "yusya.png")
        //playerHPLabel.text = "\(playerHP) / 100"
        //playerMPLabel.text = "\(playerMP) / 20"
        
        enemy = .init(name: "龍", imageName: "monster.png", attackPoint: 20, maxHP: 200, maxTP: 100, maxMP: 35)
        //enemyNameLabel.text = "龍"
        enemyImageView.image = UIImage(named: "monster.png")
        //enemyHPLabel.text = "\(enemyHP) / 200"
        //enemyMPLabel.text = "\(enemyMP) / 35"
        
        updateUI()
        
        gameTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateGame), userInfo: nil, repeats: true)
        
        gameTimer.fire()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        techMonManager.playBGM(fileName: "BGM_battle001")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        techMonManager.stopBGM()
    }
    
    @objc func updateGame() {
        
        player.currentMP += 1
        if player.currentMP >= 20 {
            isPlayerAttackAvailable = true
            player.currentMP = 20
        }else {
            isPlayerAttackAvailable = false
        }
        
        enemy.currentMP += 1
        if enemy.currentMP >= 35 {
            
            enemyAttack()
            enemy.currentMP = 0
        }
        
        updateUI()
        //playerMPLabel.text = "\(playerMP) / 20"
        //enemyMPLabel.text = "\(enemyMP) / 35"
    }
    
    func enemyAttack() {
        
        techMonManager.damageAnimation(imageView: playerImageView)
        techMonManager.playSE(fileName: "SE_attack")
        
        let number = Int.random(in: 0 ..< 10)
        
        if number >= 8 {
            player.currentHP -= 2 * enemy.attackPoint
        } else {
            player.currentHP -= enemy.attackPoint
        }
        
        updateUI()
        //playerHPLabel.text = "\(playerHP) / 100"
        
        judgeBattle()
        //if playerHP <= 0 {
        //    finishBattle(vanishImageView: playerImageView, isPlayerWin: false)
        //}
    }
    
    func finishBattle(vanishImageView: UIImageView, isPlayerWin: Bool) {
        
        techMonManager.vanishAnimation(imageView: vanishImageView)
        techMonManager.stopBGM()
        gameTimer.invalidate()
        isPlayerAttackAvailable = false
        
        var finishMessage: String = ""
        if isPlayerWin {
            techMonManager.playSE(fileName: "SE_fanfare")
            finishMessage = "勇者の勝利！"
        } else {
            techMonManager.playSE(fileName: "SE_gameover")
            finishMessage = "勇者の敗北…"
        }
        
        let alert = UIAlertController(title: "バトル終了", message: finishMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in self.dismiss(animated: true, completion: nil)}))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func attackAction() {
        if isPlayerAttackAvailable {
            techMonManager.damageAnimation(imageView: enemyImageView)
            techMonManager.playSE(fileName: "SE_attack")
            
            let number = Int.random(in: 0 ..< 10)
            
            if number >= 8 {
                enemy.currentHP -= 2 * player.attackPoint
            } else {
                enemy.currentHP -= player.attackPoint
            }
            
            if enemy.currentHP <= 0 {
                enemy.currentHP = 0
            }
            player.currentMP = 0
            
            player.currentTP += 10
            if player.currentTP >= player.maxTP {
                player.currentTP = player.maxTP
            }
            
            updateUI()
            //enemyHPLabel.text = "\(enemyHP) / 200"
            //playerMPLabel.text = "\(playerMP) / 20"
            
            judgeBattle()
            //if enemyHP <= 0 {
            //    finishBattle(vanishImageView: enemyImageView, isPlayerWin: true)
            //}
        }
    }
    
    func updateUI() {
        
        playerHPLabel.text = "\(player.currentHP) / \(player.maxHP)"
        playerMPLabel.text = "\(player.currentMP) / \(player.maxMP)"
        playerTPLabel.text = "\(player.currentTP) / \(player.maxTP)"
        
        enemyHPLabel.text = "\(enemy.currentHP) / \(enemy.maxHP)"
        enemyMPLabel.text = "\(enemy.currentMP) / \(enemy.maxMP)"
    }
    
    func judgeBattle() {
        if player.currentHP <= 0 {
            finishBattle(vanishImageView: playerImageView, isPlayerWin: false)
        } else if enemy.currentHP <= 0 {
            finishBattle(vanishImageView: enemyImageView, isPlayerWin: true)
        }
    }
    
    @IBAction func tameruAction() {
        if isPlayerAttackAvailable {
            techMonManager.playSE(fileName: "SE_charge")
            player.currentTP += 40
            if player.currentTP >= player.maxTP {
                player.currentTP = player.maxTP
            }
            player.currentMP = 0
        }
    }
    
    @IBAction func fireAction() {
        if isPlayerAttackAvailable && player.currentTP >= 40 {
            techMonManager.damageAnimation(imageView: enemyImageView)
            techMonManager.playSE(fileName: "SE_fire")
            
            let number = Int.random(in: 0 ..< 10)
            
            if number >= 8 {
                enemy.currentHP -= 200
            } else {
                enemy.currentHP -= 100
            }
            
            player.currentTP -= 40
            if player.currentTP <= 0 {
                player.currentTP = 0
            }
            player.currentMP = 0
            judgeBattle()
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
