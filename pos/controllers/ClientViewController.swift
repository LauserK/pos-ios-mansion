//
//  ClientViewController.swift
//  pos
//
//  Created by Macbook on 28/5/18.
//  Copyright © 2018 Grupo Paseo. All rights reserved.
//

import UIKit

class ClientViewController: UIViewController {
    // Modelos
    var usuario: User!
    var cliente: Client!
    var clientes = [Client]()
    
    @IBOutlet weak var usuarioLabel: UILabel!
    @IBOutlet weak var clienteLabel: UILabel!
    @IBOutlet weak var clienteTableView: UITableView!
    
    var timer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usuarioLabel.text = "Usuario: \(self.usuario.nombre!)"
        clienteLabel.text = ""
        
        clienteTableView.delegate = self
        clienteTableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        
        // Update the table with clients
        getClients()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool){
        super.viewWillDisappear(animated)
        timer?.invalidate()
        timer = nil
    }
    
    @IBAction func nextClient(_ sender: Any) {
        let clientDevice = Client().getClient()
        
        if (clientDevice.auto != nil){
            self.cliente = clientDevice
            self.performSegue(withIdentifier: "irHome", sender: self)
        } else {
            Client().getAllClientByQueue(){ clientes in
                if(clientes.count > 0){
                    self.timer?.invalidate()
                    self.cliente = clientes[0]
                    self.cliente.updateClientStatus(status:"1"){ success in
                        if (success == true) {
                            self.cliente.saveClient()
                            self.performSegue(withIdentifier: "irHome", sender: self)
                        }
                    }
                    
                }
            }
        }
    }
    
    func getClients(){
        ToolsPaseo().loadingView(vc: self, msg: "Consultando...")
        Client().getAllClientByQueue(){ clientes in
            self.dismiss(animated: false){
                DispatchQueue.main.async {
                    self.clientes = clientes
                    self.clienteTableView.reloadData()
                    
                    self.timer =  Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(self.getClients), userInfo: nil, repeats: false)
                }
            }
        }
    }
    
    /*
    // MARK: - Navigation
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "irHome" {
            if let destination = segue.destination as? ArticlesViewController {
                destination.usuario = self.usuario
                destination.cliente = self.cliente
            }
        }
    }

}

/*
 // MARK: - ClientTable
 */
extension ClientViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.clientes.count
    }
    
    // Asignamos valores a las celdas
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let newCell = tableView.dequeueReusableCell(withIdentifier: "clientCell") as! ClientItemCell
        newCell.name.text = self.clientes[indexPath.row].nombre!
        newCell.id.text = self.clientes[indexPath.row].codigo!
        return newCell
    }
    
    // Seleccion
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

class ClientItemCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var id: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.name.text = ""
        self.id.text = ""
    }
}
