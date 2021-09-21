//
//  FacturacionDetalleCVC.swift
//  Initiative
//
//  Created by Andres Liu on 12/1/20.
//

import UIKit

class FacturacionDetalleCVC: UICollectionViewCell {
    
    @IBOutlet weak var mes: UILabel!
    @IBOutlet weak var valorConsumido: UILabel!
    @IBOutlet weak var valorFacturado: UILabel!
    @IBOutlet weak var valorPorFacturar: UILabel!
    @IBOutlet weak var valorPagado: UILabel!
    @IBOutlet weak var valorPorPaga: UILabel!
    
    @IBOutlet weak var valorVencido: UILabel!
    public func listarDetalle(mesNombre: String, consumido: Float, facturado: Float, porFacturar: Float, pagado: Float, porPagar: Float, vencido: Float) {
        mes.text = mesNombre
        valorConsumido.text = "$ \(String(format: "%.2f", consumido / 1000000))MM"
        valorFacturado.text = "$ \(String(format: "%.2f", facturado / 1000000))MM"
        valorPorFacturar.text = "$ \(String(format: "%.2f", porFacturar / 1000000))MM"
        valorPagado.text = "$ \(String(format: "%.2f", pagado / 1000000))MM"
        valorPorPaga.text = "$ \(String(format: "%.2f", porPagar / 1000000))MM"
        valorVencido.text = "$ \(String(format: "%.2f", vencido / 1000000))MM"
        
    }
}
