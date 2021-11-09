//
//  ViewController.swift
//  Recepcion Mercancia
//
//  Created by Macbook on 11/1/18.
//  Copyright © 2018 Grupo Paseo. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import CoreData

class ViewController: UIViewController {
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var userField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var sendBtn: UIButton!
    
    // Objecto usuario
    var usuario: User!
    
    @IBAction func sendButton(_ sender: Any) {
        // Verificamos que los campos no estan vacios
        if (userField.text == "") {
            messageLabel.text = "¡El campo usuario está vacio!"
        } else if (passwordField.text == ""){
            messageLabel.text = "¡El campo contraseña está vacio!"
        } else {
            // Si todo OK realizamos la consulta para verificar si existe el usuario
            ToolsPaseo().loadingView(vc: self, msg: "Verificando datos...")
            User().getUserNew(codigo: self.userField.text!, clave: self.passwordField.text!){ user in
                
                self.dismiss(animated: true){
                    /*let userr = User()
                    userr.auto = "0000000021"
                    userr.codigo = "26392347"
                    userr.nombre = "KILDARE"
                    self.usuario = userr
                    self.performSegue(withIdentifier: "irCliente", sender: self)*/
                    if (user.auto != nil) {
                        self.usuario = user
                        self.performSegue(withIdentifier: "irCliente", sender: self)
                    } else {
                        self.messageLabel.text = "Usuario/Contraseńa incorrecto"
                    }
                }
            }
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "irCliente" {
            if let destination = segue.destination as? ClientViewController {
                destination.usuario   = self.usuario
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Cuando se hace TAP en cualquier lugar oculta el keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    // Cuando se hace tap quita el keyboard
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

