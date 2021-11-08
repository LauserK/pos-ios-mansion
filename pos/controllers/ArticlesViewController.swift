//
//  ArticlesViewController.swift
//  pos
//
//  Created by Macbook on 25/5/18.
//  Copyright © 2018 Grupo Paseo. All rights reserved.
//

import UIKit
import ExternalAccessory
import AdyenBarcoder

class ArticlesViewController: UIViewController, BarcoderDelegate {
    // Modelos
    var usuario: User!
    var cliente: Client!
    var article: Article!
    
    @IBOutlet weak var groupsTableView: UITableView!
    @IBOutlet weak var articlesTableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var articlesView: UIView!
    @IBOutlet weak var gridView: UIView!
    @IBOutlet weak var articlesCollectionView: UICollectionView!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var clientLabel: UILabel!
    @IBOutlet weak var quantityArticlesLabel: UILabel!
    @IBOutlet weak var subTLabel: UILabel!
    @IBOutlet weak var taxLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var totalView: UIView!
    
    
    var articles = [Article]()
    var groups = [Group]()
    var articles_minuta = [Article]()
    var firstTime = true
    
    let barcoder = Barcoder.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Delegates and Datasource of UITableView and UICollectionView
        self.articlesTableView.delegate = self
        self.articlesTableView.dataSource = self
        self.groupsTableView.delegate = self
        self.groupsTableView.dataSource = self
        self.articlesCollectionView.delegate = self
        self.articlesCollectionView.dataSource = self
        
        // Allow Selection to the collection
        self.articlesCollectionView.allowsSelection = true
        
        // Barcode delegate
        barcoder.delegate = self
        
        // Allow tap on header view to change the subview
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleHeaderTap(sender:)))
        headerView.addGestureRecognizer(tapGesture)
        
        // Long tap for delete all the articles
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleTotalDoubleTap(sender:)))
        self.totalView.addGestureRecognizer(longTapGesture)
        
        // SET DATA ON HEADER
        self.userLabel.text = "Usuario: \(self.usuario.nombre!)"
        self.clientLabel.text = "Cliente: \(self.cliente.nombre!) | \(self.cliente.codigo!)"
        
        // Set to Bs 0.00 all amounts 
        self.subTLabel.text = "Sub-total: Bs 0.00"
        self.taxLabel.text = "I.V.A: Bs 0.00"
        self.totalLabel.text = "Total: Bs 0.00"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        ToolsPaseo().loadingView(vc: self, msg: "Consultando...")
        
        // Search groups
        Group().getAllGroupsOfSection(){ groups in
            self.groups = groups
            // Update groups table with new data
            self.groupsTableView.reloadData()
            
            // Verify if the account have preloaded articles and reload the data
            if(self.firstTime == true){
                // Verify if is the first time to get all the articles of the account
                Article().getArticlesByClient(client: self.cliente){ articles in
                    self.dismiss(animated:false){
                        self.articles_minuta = articles
                        self.articlesTableView.reloadData()
                        self.calculateTotal()
                    }
                }
            } else {
                self.dismiss(animated:false){
                    self.articlesTableView.reloadData()
                    self.calculateTotal()
                }
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func exitButtonAction(_ sender: Any) {
        // BUTTON "SALIR" TAPED
        
        let alert = UIAlertController(title: "¡SALIR!", message: "Selecciona una de las opciones", preferredStyle: UIAlertControllerStyle.actionSheet)
        alert.addAction(UIAlertAction(title: "TERMINAR", style: .default, handler: { action in
            self.cliente.updateClientStatus(status:"2"){ success in
                if (success == true) {
                    self.cliente.deleteClients()
                    self.performSegue(withIdentifier: "irClient", sender: self)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "BORRAR CUENTA", style: .destructive, handler: { action in
            let alert = UIAlertController(title: "¡PENDIENTE!", message: "¿Realmente deseas eliminar los artículos de la cuenta?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "SI", style: .destructive, handler: { action in
                ToolsPaseo().loadingView(vc: self, msg: "Borrando artículos...")
                Article().removeAllArticles(client: self.cliente){ success in
                    if (success == true) {
                        self.cliente.updateClientStatus(status: "4"){ success in
                            self.dismiss(animated:false){
                                if success == true {
                                    self.cliente.deleteClients()
                                    self.performSegue(withIdentifier: "irClient", sender: self)
                                }
                            }
                        }
                    }
                }
            }))
            alert.addAction(UIAlertAction(title: "NO", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "SALIR", style: .default, handler: { action in
            self.performSegue(withIdentifier: "irClient", sender: self)
        }))
        alert.addAction(UIAlertAction(title: "CANCELAR", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)

    }
    
    
    // Barcode
    func didScan(barcode: Barcode) {
        // WHEN THE SCANNER 'SCAN' A BARCODE
        let text = "\(barcode.text)"
        // STOP THE SCAN
        self.barcoder.stopSoftScan()
        
        // Verify if the code is a weighted article
        if (text.substring(0..<2) == "31" && text.characters.count == 13){
            let plu = text.substring(2..<7)
            let weight = text.substring(7..<12)
            
            ToolsPaseo().loadingView(vc: self, msg: "Buscando artículo...")
            Article().getArticlesByPLU(plu: plu){ article in
                
                self.dismiss(animated:false){
                    if (article.auto != nil){
                        self.article = article
                        
                        if (weight == "00001") {
                            self.article.cantidad = "1"
                        } else {
                            self.article.cantidad = "\(Float(weight)! / 1000)"
                        }
                        
                        // Add to the minute
                        
                        self.article.total = "\(Double(self.article.cantidad!)! * Double(self.article.precio!)!)"
                        
                        ToolsPaseo().loadingView(vc: self, msg: "Enviando...")
                        // Add the article to account
                        self.article.putArticleToAccount(client: self.cliente){article in
                            if (article.auto_cuenta != nil){
                                // Add the article to array
                                self.articles_minuta.append(article)
                                self.dismiss(animated: false){
                                    self.calculateTotal()
                                    self.articlesTableView.reloadData()
                                }
                            }
                        }
                        
                    }
                }
                
            }
        } else {
            // if not a weighted article we search by code
            ToolsPaseo().loadingView(vc: self, msg: "Buscando artículo...")
            Article().getArticlesByCode(code: text){ article in
                
                self.dismiss(animated:false){
                    if (article.auto != nil){
                        self.article = article
                        // segue to article single view
                        self.performSegue(withIdentifier: "irArticle", sender: self)
                    }
                }
                
            }
        }
        
        
    }
    
    @objc func handleDoubleArticleTap(sender: UITapGestureRecognizer) {
        let longPress = sender as UITapGestureRecognizer
        let locationInView = longPress.location(in: self.articlesTableView)
        let indexPath = self.articlesTableView.indexPathForRow(at: locationInView)
        
        // Change the quantity of article
        self.article = self.articles_minuta[indexPath!.row]
        self.articles_minuta.remove(at: indexPath!.row)
        
        // Remove from the account before
        ToolsPaseo().loadingView(vc: self, msg: "Consultando...")
        self.article.removeArticleToAccount(){ success in
            if (success == true){
                self.dismiss(animated:false){
                    self.performSegue(withIdentifier: "irArticle", sender: self)
                }
            }
        }        
    }
    
    @objc func handleTotalDoubleTap(sender: UILongPressGestureRecognizer) {
        // Delete all the articles
        
        // create the alert
        let alert = UIAlertController(title: "¡ALERTA!", message: "¿DESEAS ELIMINAR TODOS LOS ARTÍCULOS DE LA MINUTA?", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "SI", style: UIAlertActionStyle.destructive, handler: { action in
            
            ToolsPaseo().loadingView(vc: self, msg: "Borrando artículos...")
            Article().removeAllArticles(client: self.cliente){ success in
                self.dismiss(animated:false){
                    if success == true {
                        self.articles_minuta.removeAll()
                        self.articlesTableView.reloadData()
                        self.calculateTotal()
                    }
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "NO", style: UIAlertActionStyle.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func handleArticleLongTap(sender: UILongPressGestureRecognizer) {
        let longPress = sender as UILongPressGestureRecognizer
        let locationInView = longPress.location(in: self.articlesTableView)
        let indexPath = self.articlesTableView.indexPathForRow(at: locationInView)
        
        // create the alert
        let alert = UIAlertController(title: "¡ALERTA!", message: "¿DESEAS ELIMINAR EL ARTÍCULO DE LA MINUTA?", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "SI", style: UIAlertActionStyle.destructive, handler: { action in
            self.articles_minuta[indexPath!.row].removeArticleToAccount(){ data in
                if (data == true) {
                    self.articles_minuta.remove(at: indexPath!.row)
                    self.articlesTableView.reloadData()
                    self.calculateTotal()
                }
            }
            
        }))
        alert.addAction(UIAlertAction(title: "NO", style: UIAlertActionStyle.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    // 3. this method is called when a tap is recognized on header view
    @objc func handleHeaderTap(sender: UITapGestureRecognizer) {
        
        if (self.articlesView.isHidden == false){
            self.articlesView.isHidden =  true
            self.gridView.isHidden = false
        } else {
            self.articlesView.isHidden =  false
            self.gridView.isHidden = true
        }
        
    }
    
    /*
     MARK: - Calculate the sub, tax and total
     */
    
    func calculateTotal(){
        var sub   = 0.00
        var tax   = 0.00
        var total = 0.00
        
        for (article) in self.articles_minuta {
            sub = sub + Double( Double(article.precio_neto!)! * Double(article.cantidad!)! )
            tax = tax + (Double(String(format: "%.2f", Double( (Double(article.tasa!)! * Double(article.precio_neto!)! / 100) )))! * Double(article.cantidad!)!)
            total = total + Double( Double(article.precio!)! * Double(article.cantidad!)! )
        }
        
        self.subTLabel.text = "Sub-total: Bs \(ToolsPaseo().moneyPretty(amount: sub))"
        self.taxLabel.text = "I.V.A: Bs \(ToolsPaseo().moneyPretty(amount: tax))"
        self.totalLabel.text = "Total: Bs \(ToolsPaseo().moneyPretty(amount: total))"
        
        // Change quantity of lines
        self.quantityArticlesLabel.text = "- \(self.articles_minuta.count) -"
    }
    
    /*
     // MARK: - Navigation
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "irArticle" {
            if let destination = segue.destination as? SingleArticleViewController {
                destination.usuario = self.usuario
                destination.cliente = self.cliente
                destination.articles_minuta = self.articles_minuta
                destination.article = self.article
            }
        }
        
        if segue.identifier == "irClient" {
            if let destination = segue.destination as? ClientViewController {
                destination.usuario = self.usuario
            }
        }
    }

}

/*
 // MARK: - TABLE VIEW
 */

extension ArticlesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == articlesTableView){
            return self.articles_minuta.count
        } else if (tableView == groupsTableView){
            return self.groups.count
        } else {
            return 0
        }
    }
    
    // Asignamos valores a las celdas
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(tableView == groupsTableView){
            let newCell = tableView.dequeueReusableCell(withIdentifier: "groupCell") as! GroupItemCell
            newCell.groupName.text = self.groups[indexPath.row].nombre!
            return newCell
        } else {
            let newCell = tableView.dequeueReusableCell(withIdentifier: "articleCell") as! ArticleItemCell
            newCell.articleName.text = self.articles_minuta[indexPath.row].nombre!
            newCell.quantity.text = "\(self.articles_minuta[indexPath.row].cantidad!) X \(ToolsPaseo().moneyPretty(amount: Double(self.articles_minuta[indexPath.row].precio!)!))"
            newCell.total.text = ToolsPaseo().moneyPretty(amount: Double(self.articles_minuta[indexPath.row].total!)!)
            
            // Long tap to delete the row
            let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleArticleLongTap(sender:)))
            newCell.addGestureRecognizer(longTapGesture)
            
            // Double tap to edit the article cant
            let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleArticleTap(sender:)))
            doubleTapGesture.numberOfTapsRequired = 2
            newCell.addGestureRecognizer(doubleTapGesture)
            
            return newCell
        }
    }
    
    // Seleccion
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableView == self.groupsTableView){
            // Search articles by the group selected
            let auto_group = self.groups[indexPath.row].auto!
            
            // Show loading view
            ToolsPaseo().loadingView(vc: self, msg: "Consultando...")
            
            Article().getArticlesByGroup(auto_group: auto_group){ articles in
                self.dismiss(animated: true){
                    self.articles = articles
                    self.articlesCollectionView.reloadData()
                    
                    // Cambiamos la vista al UICollectionView
                    self.articlesView.isHidden =  true
                    self.gridView.isHidden = false
                }
            }
        }
    }
}

/*
 // MARK: - COLLECTION VIEW
 */

extension ArticlesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.articles.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "articleRowCell", for: indexPath) as! ArticleCollectionCell
        cell.name.text  = self.articles[indexPath.row].nombre!
        cell.price.text = "\(ToolsPaseo().moneyPretty(amount: Double(self.articles[indexPath.row].precio!)!))"
        return cell
        
    }
    
    // Seleciona el articulo
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let article = self.articles[indexPath.row]
        self.article = article
        // segue to article single view
        self.performSegue(withIdentifier: "irArticle", sender: self)
    }
}

/*
 // MARK: - CELL CLASS
 */

class ArticleCollectionCell: UICollectionViewCell {
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.price.text = ""
        self.name.text = ""
    }
    
}


class ArticleItemCell: UITableViewCell {
    @IBOutlet weak var articleName: UILabel!
    @IBOutlet weak var quantity: UILabel!
    @IBOutlet weak var total: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.articleName.text = ""
        self.quantity.text = ""
        self.total.text = ""
    }
    
}

class GroupItemCell: UITableViewCell {
    @IBOutlet weak var groupName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.groupName.text = ""
    }
}
