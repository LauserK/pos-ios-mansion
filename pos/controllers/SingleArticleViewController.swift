//
//  SingleArticleViewController.swift
//  pos
//
//  Created by Macbook on 29/5/18.
//  Copyright © 2018 Grupo Paseo. All rights reserved.
//

import UIKit

class SingleArticleViewController: UIViewController {
    // Modelos
    var usuario: User!
    var cliente: Client!
    var article: Article!
    var articles_minuta = [Article]()
    
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var clientLabel: UILabel!
    @IBOutlet weak var articleNameLabel: UILabel!
    @IBOutlet weak var articleCodeLabel: UILabel!
    @IBOutlet weak var articleQuantityLabel: UILabel!
    
    
    @IBAction func articleQuantityPlus(_ sender: Any) {
        self.articleQuantityLabel.text = "\(Int(self.articleQuantityLabel.text!)! + 1)"
    }
    
    @IBAction func articleQuantityMinus(_ sender: Any) {
        if (Int(self.articleQuantityLabel.text!)! != 1){
            self.articleQuantityLabel.text = "\(Int(self.articleQuantityLabel.text!)! - 1)"
        }
    }
    
    @IBAction func okAction(_ sender: Any) {
        self.article.cantidad = "\(Int(self.articleQuantityLabel.text!) ?? 1)"
        self.article.total = "\(Double(self.article.cantidad!)! * Double(self.article.precio!)!)"
        
        ToolsPaseo().loadingView(vc: self, msg: "Enviando...")
        // Add the article to account
        self.article.putArticleToAccount(client: self.cliente){article in
            if (article.auto_cuenta != nil){
                // Add the article to array
                self.articles_minuta.append(article)
                self.dismiss(animated: false){
                    self.performSegue(withIdentifier: "irArticles", sender: self)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Allow tap on header view to change the subview
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleHeaderTap(sender:)))
        articleQuantityLabel.addGestureRecognizer(tapGesture)
        
        // SET DATA ON HEADER
        self.userLabel.text = "Usuario: \(self.usuario.nombre!)"
        self.clientLabel.text = "Cliente: \(self.cliente.nombre!) | \(self.cliente.codigo!)"
        
        // SET ARTICLE DATA
        self.articleNameLabel.text = self.article.nombre!
        self.articleCodeLabel.text = self.article.codigo!
        self.articleQuantityLabel.text = "1"
        
        if (self.article.cantidad != nil){
            self.articleQuantityLabel.text = "\(self.article.cantidad!)"
        }
    }
    
    @objc func handleHeaderTap(sender: UITapGestureRecognizer) {
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "irArticles" {
            if let destination = segue.destination as? ArticlesViewController {
                destination.usuario = self.usuario
                destination.cliente = self.cliente
                destination.articles_minuta = self.articles_minuta
                destination.firstTime = false
            }
        }
    }
    

}
