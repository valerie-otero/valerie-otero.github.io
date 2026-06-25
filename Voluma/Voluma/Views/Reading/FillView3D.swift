//
//  FillView3D.swift
//  Voluma
//
//  Visualisation 3D (SceneKit) construite à partir de la VRAIE forme du récipient :
//   • boîte / cylindre vertical : remplissage linéaire ;
//   • cylindre horizontal : segment circulaire extrudé ;
//   • boîte à fond incliné : prisme à plancher en pente (profil extrudé) ;
//   • boîte + puisard : cuve + creux (deux volumes) ;
//   • forme libre : profil empilé fidèle au volume (rayon = aire locale dV/dh).
//  La coque est translucide ; seul le maillage du liquide est reconstruit quand la
//  hauteur change (la caméra reste stable).
//

import SwiftUI
import SceneKit

/// Description géométrique d'un récipient pour le rendu 3D (longueurs en mm).
enum Solid3DKind: Equatable {
    case box(l: Double, w: Double, h: Double)
    case vcyl(d: Double, h: Double)
    case hcyl(d: Double, len: Double)
    case slopedBox(l: Double, w: Double, deepH: Double, shallowH: Double)
    case sumpBox(l: Double, w: Double, h: Double, sumpL: Double, sumpW: Double, sumpH: Double)
    /// Forme libre : tronçons empilés (du bas vers le haut), chacun de rayon `radii[i]`
    /// (= aire locale) et de hauteur `heights[i]`.
    case profile(radii: [Double], heights: [Double])
}

struct FillView3D: UIViewRepresentable {
    let kind: Solid3DKind
    let heightFraction: Double
    var liquidColor: UIColor = .systemBlue

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.backgroundColor = .clear
        view.antialiasingMode = .multisampling4X
        view.allowsCameraControl = true
        view.autoenablesDefaultLighting = true
        let scene = SCNScene()
        view.scene = scene
        context.coordinator.rebuild(in: scene, kind: kind, liquidColor: liquidColor)
        context.coordinator.updateLiquid(fraction: heightFraction)
        return view
    }

    func updateUIView(_ view: SCNView, context: Context) {
        guard let scene = view.scene else { return }
        context.coordinator.rebuildIfNeeded(in: scene, kind: kind, liquidColor: liquidColor)
        // La géométrie ne change pas quand on change seulement de liquide : il faut
        // donc rafraîchir la couleur indépendamment de la reconstruction du maillage.
        context.coordinator.updateColor(liquidColor)
        context.coordinator.updateLiquid(fraction: heightFraction)
    }

    // MARK: - Coordinator

    final class Coordinator {
        private var signature = ""
        private var nKind: Solid3DKind = .box(l: 1, w: 1, h: 1)   // version NORMALISÉE (échelle ~2)
        private let liquidNode = SCNNode()
        private let liquidMaterial = SCNMaterial()

        func rebuildIfNeeded(in scene: SCNScene, kind: Solid3DKind, liquidColor: UIColor) {
            if "\(kind)" != signature {
                rebuild(in: scene, kind: kind, liquidColor: liquidColor)
            }
        }

        func rebuild(in scene: SCNScene, kind: Solid3DKind, liquidColor: UIColor) {
            signature = "\(kind)"
            nKind = Self.normalized(kind)
            scene.rootNode.childNodes.forEach { $0.removeFromParentNode() }

            // Caméra
            let cameraNode = SCNNode()
            cameraNode.camera = SCNCamera()
            cameraNode.position = SCNVector3(2.4, 1.2, 3.3)
            cameraNode.look(at: SCNVector3Zero)
            scene.rootNode.addChildNode(cameraNode)

            // Coque translucide (verre) + arêtes nettes. La coque n'écrit PAS la profondeur :
            // sinon une de ses faces, rendue avant le liquide, le masquerait (puisard « transparent »).
            let shell = SCNMaterial()
            shell.lightingModel = .constant
            shell.diffuse.contents = UIColor.systemGray2.withAlphaComponent(0.15)
            shell.isDoubleSided = true
            shell.writesToDepthBuffer = false

            let edge = SCNMaterial()
            edge.lightingModel = .constant
            edge.diffuse.contents = UIColor.label

            // `renderingOrder` n'est PAS hérité des parents : on le pose sur chaque nœud enfant
            // (liquide 0 < coque 10 < arêtes 12) pour un tri de transparence correct.
            let shellNode = SCNNode()
            let edgesNode = SCNNode()
            for n in Self.shellNodes(nKind) { n.geometry?.firstMaterial = shell; n.renderingOrder = 10; shellNode.addChildNode(n) }
            for n in Self.edgeNodes(nKind) { n.geometry?.firstMaterial = edge; n.renderingOrder = 12; edgesNode.addChildNode(n) }
            scene.rootNode.addChildNode(shellNode)
            scene.rootNode.addChildNode(edgesNode)

            // Liquide
            liquidMaterial.diffuse.contents = liquidColor.withAlphaComponent(0.92)
            liquidMaterial.lightingModel = .physicallyBased
            liquidMaterial.isDoubleSided = true
            liquidNode.renderingOrder = 0
            scene.rootNode.addChildNode(liquidNode)
        }

        /// Met à jour la seule couleur du liquide, sans reconstruire la géométrie.
        /// Corrige le cas « on change de liquide mais pas de récipient » : le maillage
        /// est inchangé, seule la teinte du matériau partagé doit suivre.
        func updateColor(_ color: UIColor) {
            liquidMaterial.diffuse.contents = color.withAlphaComponent(0.92)
        }

        func updateLiquid(fraction: Double) {
            let f = max(0, min(1, fraction))
            // On repart d'un nœud vide à chaque mise à jour.
            liquidNode.geometry = nil
            liquidNode.childNodes.forEach { $0.removeFromParentNode() }
            liquidNode.position = SCNVector3Zero
            liquidNode.eulerAngles = SCNVector3Zero

            for part in Self.liquidParts(nKind, fraction: f) {
                part.geometry?.firstMaterial = liquidMaterial
                part.renderingOrder = 0          // le liquide se rend avant la coque
                liquidNode.addChildNode(part)
            }
        }

        // MARK: - Normalisation (plus grande dimension → 2.0)

        private static func maxDim(_ k: Solid3DKind) -> Double {
            switch k {
            case let .box(l, w, h):                 return max(l, w, h)
            case let .vcyl(d, h):                    return max(d, h)
            case let .hcyl(d, len):                  return max(d, len)
            case let .slopedBox(l, w, deepH, _):     return max(l, w, deepH)
            case let .sumpBox(l, w, h, _, _, sH):    return max(l, w, h + sH)
            case let .profile(radii, heights):       return max(heights.reduce(0,+), 2 * (radii.max() ?? 1))
            }
        }

        private static func normalized(_ k: Solid3DKind) -> Solid3DKind {
            let m = maxDim(k)
            let s = m > 0 ? 2.0 / m : 1
            switch k {
            case let .box(l, w, h):                  return .box(l: l*s, w: w*s, h: h*s)
            case let .vcyl(d, h):                     return .vcyl(d: d*s, h: h*s)
            case let .hcyl(d, len):                   return .hcyl(d: d*s, len: len*s)
            case let .slopedBox(l, w, dH, sH):        return .slopedBox(l: l*s, w: w*s, deepH: dH*s, shallowH: sH*s)
            case let .sumpBox(l, w, h, sl, sw, sh):   return .sumpBox(l: l*s, w: w*s, h: h*s, sumpL: sl*s, sumpW: sw*s, sumpH: sh*s)
            case let .profile(radii, heights):        return .profile(radii: radii.map { $0*s }, heights: heights.map { $0*s })
            }
        }

        // MARK: - Coques & arêtes (nœuds entièrement positionnés / orientés)

        private static func shellNodes(_ k: Solid3DKind) -> [SCNNode] {
            switch k {
            case let .box(l, w, h):
                return [SCNNode(geometry: SCNBox(width: l, height: h, length: w, chamferRadius: 0))]
            case let .vcyl(d, h):
                return [SCNNode(geometry: SCNCylinder(radius: d/2, height: h))]
            case let .hcyl(d, len):
                let n = SCNNode(geometry: SCNCylinder(radius: d/2, height: len))
                n.eulerAngles = SCNVector3(Double.pi/2, 0, 0)   // axe le long de Z
                return [n]
            case let .slopedBox(l, w, dH, sH):
                return [SCNNode(geometry: SCNShape(path: slopedProfile(l: l, deepH: dH, shallowH: sH),
                                                   extrusionDepth: w))]
            case let .sumpBox(l, w, h, sl, sw, sh):
                let total = h + sh
                let main = SCNNode(geometry: SCNBox(width: l, height: h, length: w, chamferRadius: 0))
                main.position = SCNVector3(0, -total/2 + sh + h/2, 0)
                let sump = SCNNode(geometry: SCNBox(width: sl, height: sh, length: sw, chamferRadius: 0))
                sump.position = SCNVector3(0, -total/2 + sh/2, 0)
                return [main, sump]
            case let .profile(radii, heights):
                var nodes: [SCNNode] = []
                let total = heights.reduce(0, +)
                var y = -total / 2
                for (r, hgt) in zip(radii, heights) {
                    let n = SCNNode(geometry: SCNCylinder(radius: max(r, 0.0001), height: max(hgt, 0.0001)))
                    n.position = SCNVector3(0, y + hgt/2, 0)
                    nodes.append(n); y += hgt
                }
                return nodes
            }
        }

        private static func edgeNodes(_ k: Solid3DKind) -> [SCNNode] {
            switch k {
            case let .box(l, w, h):
                return [SCNNode(geometry: boxEdges(l, h, w))]
            case let .vcyl(d, h):
                return [SCNNode(geometry: cylinderEdges(radius: d/2, height: h))]
            case let .hcyl(d, len):
                let n = SCNNode(geometry: cylinderEdges(radius: d/2, height: len))
                n.eulerAngles = SCNVector3(Double.pi/2, 0, 0)
                return [n]
            case let .slopedBox(l, w, dH, sH):
                return [SCNNode(geometry: slopedEdges(l: l, w: w, deepH: dH, shallowH: sH))]
            case let .sumpBox(l, w, h, sl, sw, sh):
                let total = h + sh
                let main = SCNNode(geometry: boxEdges(l, h, w))
                main.position = SCNVector3(0, -total/2 + sh + h/2, 0)
                let sump = SCNNode(geometry: boxEdges(sl, sh, sw))
                sump.position = SCNVector3(0, -total/2 + sh/2, 0)
                return [main, sump]
            case .profile:
                return []   // les anneaux empilés alourdiraient ; la coque translucide suffit
            }
        }

        // MARK: - Liquide (par forme)

        private static func liquidParts(_ k: Solid3DKind, fraction f: Double) -> [SCNNode] {
            switch k {
            case let .box(l, w, h):
                let lh = max(h * f, 0.0001)
                let n = SCNNode(geometry: SCNBox(width: l*0.97, height: lh, length: w*0.97, chamferRadius: 0))
                n.position = SCNVector3(0, -h/2 + lh/2, 0); return [n]

            case let .vcyl(d, h):
                let lh = max(h * f, 0.0001)
                let n = SCNNode(geometry: SCNCylinder(radius: d/2*0.97, height: lh))
                n.position = SCNVector3(0, -h/2 + lh/2, 0); return [n]

            case let .hcyl(d, len):
                let r = d/2
                let n = SCNNode(geometry: segmentGeometry(r: r*0.985, h: 2*r*f, depth: len*0.985))
                return [n]

            case let .slopedBox(l, w, dH, sH):
                let h = dH * f
                let n = SCNNode(geometry: SCNShape(
                    path: slopedWetted(l: l, deepH: dH, shallowH: sH, water: h), extrusionDepth: w*0.96))
                return [n]

            case let .sumpBox(l, w, h, sl, sw, sh):
                let total = h + sh
                let water = total * f
                var parts: [SCNNode] = []
                let sumpFill = min(water, sh)
                if sumpFill > 0.0001 {
                    let n = SCNNode(geometry: SCNBox(width: sl*0.95, height: sumpFill, length: sw*0.95, chamferRadius: 0))
                    n.position = SCNVector3(0, -total/2 + sumpFill/2, 0); parts.append(n)
                }
                if water > sh {
                    let mh = water - sh
                    let n = SCNNode(geometry: SCNBox(width: l*0.97, height: mh, length: w*0.97, chamferRadius: 0))
                    n.position = SCNVector3(0, -total/2 + sh + mh/2, 0); parts.append(n)
                }
                return parts

            case let .profile(radii, heights):
                let total = heights.reduce(0, +)
                let water = total * f
                var parts: [SCNNode] = []
                var y = -total / 2, acc = 0.0
                for (r, hgt) in zip(radii, heights) {
                    let fillTop = min(water, acc + hgt)
                    let fill = fillTop - acc
                    if fill > 0.0001 {
                        let n = SCNNode(geometry: SCNCylinder(radius: max(r*0.97, 0.0001), height: fill))
                        n.position = SCNVector3(0, y + fill/2, 0); parts.append(n)
                    }
                    y += hgt; acc += hgt
                    if acc >= water { break }
                }
                return parts
            }
        }

        // MARK: - Profils 2D (fond incliné)

        /// Profil latéral complet d'une boîte à fond incliné (plan XY, côté profond à gauche).
        private static func slopedProfile(l: Double, deepH: Double, shallowH: Double) -> UIBezierPath {
            let L2 = l/2, H2 = deepH/2
            let drop = max(0, deepH - shallowH)
            let p = UIBezierPath()
            p.move(to: CGPoint(x: -L2, y: -H2))                 // plancher, côté profond
            p.addLine(to: CGPoint(x: L2, y: -H2 + drop))        // plancher, côté faible (relevé)
            p.addLine(to: CGPoint(x: L2, y: H2))                // haut droit
            p.addLine(to: CGPoint(x: -L2, y: H2))               // haut gauche
            p.close()
            return p
        }

        /// Polygone mouillé d'une boîte à fond incliné pour une hauteur d'eau `water`
        /// mesurée depuis le point le plus bas.
        private static func slopedWetted(l: Double, deepH: Double, shallowH: Double, water: Double) -> UIBezierPath {
            let L2 = l/2, H2 = deepH/2
            let drop = max(0, deepH - shallowH)
            let h = max(0.0001, min(water, deepH))
            let surfaceY = -H2 + h
            let p = UIBezierPath()
            if drop > 0, h < drop {
                // Coin triangulaire (seul le côté profond est mouillé).
                let xw = -L2 + l * h / drop
                p.move(to: CGPoint(x: -L2, y: -H2))
                p.addLine(to: CGPoint(x: xw, y: surfaceY))
                p.addLine(to: CGPoint(x: -L2, y: surfaceY))
            } else {
                // Coin plein + dalle au-dessus.
                p.move(to: CGPoint(x: -L2, y: -H2))
                p.addLine(to: CGPoint(x: L2, y: -H2 + drop))
                p.addLine(to: CGPoint(x: L2, y: surfaceY))
                p.addLine(to: CGPoint(x: -L2, y: surfaceY))
            }
            p.close()
            return p
        }

        // MARK: - Géométries de lignes

        private static func lineGeometry(_ verts: [SCNVector3], _ idx: [Int32]) -> SCNGeometry {
            SCNGeometry(sources: [SCNGeometrySource(vertices: verts)],
                        elements: [SCNGeometryElement(indices: idx, primitiveType: .line)])
        }

        private static func boxEdges(_ L: Double, _ H: Double, _ W: Double) -> SCNGeometry {
            let x = Float(L/2), y = Float(H/2), z = Float(W/2)
            let v = [
                SCNVector3(-x,-y,-z), SCNVector3(x,-y,-z), SCNVector3(x,y,-z), SCNVector3(-x,y,-z),
                SCNVector3(-x,-y, z), SCNVector3(x,-y, z), SCNVector3(x,y, z), SCNVector3(-x,y, z),
            ]
            let idx: [Int32] = [0,1,1,2,2,3,3,0, 4,5,5,6,6,7,7,4, 0,4,1,5,2,6,3,7]
            return lineGeometry(v, idx)
        }

        /// Cerclages d'extrémité + génératrices d'un cylindre (axe local Y, comme SCNCylinder).
        private static func cylinderEdges(radius r: Double, height: Double,
                                          radial: Int = 28, verticals: Int = 8) -> SCNGeometry {
            var verts: [SCNVector3] = []; var idx: [Int32] = []
            let rr = Float(r), hy = Float(height/2)
            for ring in [hy, -hy] {
                let base = Int32(verts.count)
                for i in 0..<radial {
                    let ang = 2*Double.pi*Double(i)/Double(radial)
                    verts.append(SCNVector3(rr*Float(cos(ang)), ring, rr*Float(sin(ang))))
                }
                for i in 0..<radial { idx.append(base+Int32(i)); idx.append(base+Int32((i+1)%radial)) }
            }
            for j in 0..<verticals {
                let ang = 2*Double.pi*Double(j)/Double(verticals)
                let xx = rr*Float(cos(ang)), zz = rr*Float(sin(ang))
                let base = Int32(verts.count)
                verts.append(SCNVector3(xx, hy, zz)); verts.append(SCNVector3(xx, -hy, zz))
                idx.append(base); idx.append(base+1)
            }
            return lineGeometry(verts, idx)
        }

        /// Arêtes d'une boîte à fond incliné (profil avant + arrière + connecteurs).
        private static func slopedEdges(l: Double, w: Double, deepH: Double, shallowH: Double) -> SCNGeometry {
            let L2 = Float(l/2), H2 = Float(deepH/2), Z = Float(w/2)
            let drop = Float(max(0, deepH - shallowH))
            // 4 sommets du profil
            let prof = [
                SCNVector3(-L2, -H2, 0), SCNVector3(L2, -H2 + drop, 0),
                SCNVector3(L2, H2, 0),  SCNVector3(-L2, H2, 0),
            ]
            var v: [SCNVector3] = []
            for p in prof { v.append(SCNVector3(p.x, p.y, Z)) }   // face avant 0..3
            for p in prof { v.append(SCNVector3(p.x, p.y, -Z)) }  // face arrière 4..7
            let idx: [Int32] = [0,1,1,2,2,3,3,0, 4,5,5,6,6,7,7,4, 0,4,1,5,2,6,3,7]
            return lineGeometry(v, idx)
        }

        /// Segment circulaire (cylindre horizontal) rempli par le bas, extrudé sur la longueur.
        private static func segmentGeometry(r: Double, h: Double, depth: Double) -> SCNGeometry {
            let hh = max(0.0001, min(h, 2*r))
            let halfSpan = acos(max(-1, min(1, (r - hh) / r)))
            let bottom = -Double.pi / 2
            let steps = 64
            let path = UIBezierPath()
            for i in 0...steps {
                let phi = bottom - halfSpan + (2*halfSpan) * Double(i)/Double(steps)
                let pt = CGPoint(x: r*cos(phi), y: r*sin(phi))
                if i == 0 { path.move(to: pt) } else { path.addLine(to: pt) }
            }
            path.close()
            return SCNShape(path: path, extrusionDepth: depth)
        }
    }
}

extension Container {
    /// Géométrie 3D fidèle à la forme réelle du récipient (formes composées et libres incluses).
    func solid3D() -> Solid3DKind {
        if let kind = compositeKindValue {
            switch kind {
            case .slopedBox:
                return .slopedBox(l: dL, w: dW, deepH: max(dH, shallowH), shallowH: min(dH, shallowH))
            case .sumpBox:
                return .sumpBox(l: dL, w: dW, h: dH, sumpL: sumpL, sumpW: sumpW, sumpH: sumpH)
            }
        }
        switch shape {
        case .box:  return .box(l: dL, w: dW, h: dH)
        case .vcyl: return .vcyl(d: dD, h: dH)
        case .hcyl: return .hcyl(d: dD, len: dLen)
        case .custom:
            // Forme libre : profil empilé fidèle au volume — rayon de chaque tronçon tel que
            // son aire (π r²) = aire locale dV/dh, donc le volume rendu suit la table de jauge.
            var hs: [Double] = [0], vs: [Double] = [0]
            for p in gaugePoints where p.h_mm > 0 { hs.append(p.h_mm); vs.append(p.v_L) }
            guard hs.count >= 2 else { return .box(l: 1, w: 1, h: 1) }
            var radii: [Double] = [], heights: [Double] = []
            for i in 1..<hs.count {
                let dh = hs[i] - hs[i - 1]
                let dv = max(0, vs[i] - vs[i - 1])
                let area = dh > 0 ? dv * 1e6 / dh : 0          // mm²
                radii.append((area / .pi).squareRoot())
                heights.append(max(dh, 0.0001))
            }
            return .profile(radii: radii, heights: heights)
        }
    }
}
