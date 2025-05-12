//
//  Created by Michele Restuccia on 12/5/25.
//

import SwiftUI

/// A SwiftUI view that displays hierarchical JSON data as an expandable tree structure.
/// It supports nested objects and arrays, and renders them using `OutlineGroup`.
/// Keys are displayed in alphabetical order, and the layout uses monospaced text for clarity.
/// Ideal for debugging or visualizing structured configuration files.
#if DEBUG
#Preview {
    JSONTreeView.Async(rawJSON: MockData.rawJSON)
}
#endif

// MARK: JSONTreeView

public struct JSONTreeView: View {
    
    let topLevel: [Node]
    struct Node: Identifiable {
        let id = UUID()
        let key: String
        let value: String?
        let children: [Node]?
    }
    
    public var body: some View {
        List {
            OutlineGroup(topLevel, children: \.children) { node in
                Group {
                    if let v = node.value {
                        LabeledContent(node.key, value: v)
                    } else {
                        Text(node.key)
                    }
                }
                .monospaced()
                .padding(.vertical, 2)
            }
        }
    }
}

// MARK: Async

public extension JSONTreeView {
    
    struct Async: View {
        
        private let rawJSON: Data
        
        public init(rawJSON: Data) {
            self.rawJSON = rawJSON
        }
        
        public var body: some View {
            AsyncView(id: .constant("JSONTreeView.rawJSON")) {
                let values = try parseJSONData(rawJSON)
                return values.sorted(by: { $1.key > $0.key })
            } hostedViewGenerator: {
                JSONTreeView(topLevel: $0)
            } loadingViewGenerator: {
                ProgressView()
            }
        }
    }
    
    private static func parseJSONData(_ rawJSON: Data) throws -> [Node] {
        let json = try JSONSerialization.jsonObject(with: rawJSON)
        guard let dict = json as? [String: Any] else { return [] }
        return dict
            .sorted(by: { $0.key < $1.key })
            .map { key, value in
                if let sub = value as? [String: Any] {
                    return Node(key: key, value: nil, children: parseJSON(sub))
                } else if let arr = value as? [Any] {
                    let children = arr.enumerated().map { idx, elt -> Node in
                        if let sub = elt as? [String: Any] {
                            return Node(key: "\(idx)", value: nil, children: parseJSON(sub))
                        } else {
                            return Node(key: "\(idx)", value: "\(elt)", children: nil)
                        }
                    }
                    return Node(key: key, value: nil, children: children)
                } else {
                    return Node(key: key, value: "\(value)", children: nil)
                }
            }
    }
    
    private static func parseJSON(_ json: Any) -> [Node] {
        guard let dict = json as? [String: Any] else { return [] }
        return dict
            .sorted(by: { $0.key < $1.key })
            .map { key, value in
                if let subDict = value as? [String: Any] {
                    return Node(key: key, value: nil, children: parseJSON(subDict))
                } else if let array = value as? [Any] {
                    let children = array.enumerated().map { idx, element in
                        if let sub = element as? [String: Any] {
                            return Node(key: "\(idx)", value: nil, children: parseJSON(sub))
                        } else {
                            return Node(key: "\(idx)", value: "\(element)", children: nil)
                        }
                    }
                    return Node(key: key, value: nil, children: children)
                } else {
                    return Node(key: key, value: "\(value)", children: nil)
                }
            }
    }
}

// MARK: Mock

#if DEBUG

private enum MockData {
    
    static var rawJSON: Data {
        """
        {
          "site": "es",
          "global": {
            "base_url": "https://www.tlb.es/",
            "version_android": "3.15.2",
            "version_ios": "3.15.2",
            "logo": "https://www.tlb.es/logo/.png",
            "currency": "EUR",
            "doofinder_token": "0000-00000000000000000000000000000000",
            "doofinder_hash": "00000000000000000000000000000000",
            "gmaps_apikey": "0000000000000000000000000000",
            "aws_cloudfront_url": "https://0000.cloudfront.net",
            "store_id": "2",
            "adyen_return_url": "tlb://com.tlb",
            "adyen_client_key": "live_000000000000000000000000000000000000",
            "adyen_version": "0.00.1",
            "analytics_container_id": "GTM-00000000",
            "racoon_site_id": "0000-0000-0000-0000-0000",
            "naturitas_brand_id": null
          },
          "urls": {
            "faqs": "/preguntas-frecuentes",
            "who_we_are": "/quienes-somos",
            "welcome": "/app-welcome",
            "privacy": "/politica-privacidad",
            "conditions": "/terminos-condiciones",
            "home": "/",
            "returns": "/politica-devoluciones",
            "offers": "/ofertas",
            "legal": "/aviso-legal",
            "faqs_reward_points": "/loyalty-faqs",
            "loyalty_points": "/programa-de-puntos"
          },
          "contact": {
            "domain": "tlb.es",
            "url": "/formulario-contacto",
            "email": "info@mock.es",
            "wa_number": null,
            "phone_number": "919 019 101",
            "atc_hours": "El horario del servicio de Atención al Cliente es de 9 a 18h los días no festivos de lunes a viernes."
          },
          "complementary_info": {
            "return_days": 14,
            "payment_images": [
              "visa",
              "mastercard",
              "maestro",
              "paypal",
              "klarna",
              "cod",
              "bizum"
            ],
            "delivery_fresh_from": "martes",
            "delivery_fresh_to": "viernes",
            "fresh_tag": "refrigerated",
            "fresh_tag_id": 26180,
            "message_home_delivery": null,
            "message_store_pickup": null,
            "free_shipping_amount_pickup": 49,
            "free_shipping_amount_delivery": 49
          },
          "bank_account": {
            "name": "bank",
            "iban": "0000 0000 0000 0000 0000 0000",
            "beneficiary": "TLB"
          },
          "styles": [
            {
              "name": "pink",
              "background": "#F8715B",
              "color": "#FFFFFF"
            },
            {
              "name": "black",
              "background": "#343434",
              "color": "#FFFFFF"
            },
            {
              "name": "green",
              "background": "#dcf2ec",
              "color": "#116153"
            },
            {
              "name": "yellow",
              "background": "#EEA770",
              "color": "#000000"
            },
            {
              "name": "season",
              "background": "#329b7d",
              "color": "#116153"
            }
          ],
          "features": {
            "pickup": true,
            "nif_canarias": true,
            "vat_required": true,
            "region_required": false,
            "enabled_reward_points": true,
            "request_invoice": false,
            "invoice_form_url": null,
            "max_percentage_redeem_points": 25
          },
          "brands_menu": {
            "_1693990186485_485": {
              "brand_title": "Naturitas Essentials",
              "brand_link": "b/naturitas-essentials"
            },
            "_1693990302901_901": {
              "brand_title": "Zentrity",
              "brand_link": "b/zentrity-by-naturitas"
            },
            "_1693990329061_61": {
              "brand_title": "Woments",
              "brand_link": "b/woments"
            },
            "_1729698456518_518": {
              "brand_title": "Zeutics",
              "brand_link": "zeutics-by-naturitas-app"
            }
          },
          "blog": {
            "doofinder_hash_id": "000000000000000000000"
          }
        }
        """.data(using: .utf8)!
    }
}

#endif
