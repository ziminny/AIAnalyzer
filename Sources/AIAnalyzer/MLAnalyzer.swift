//
//  MLAnalyzer.swift
//  RealLens
//
//  Created by Vagner Reis on 13/02/26.
//

import Foundation
import CoreML
import UIKit

/// Analyzer responsável por executar inferência de Machine Learning
/// para detecção de imagens geradas por Inteligência Artificial.
///
/// Esta classe utiliza um modelo CoreML (`AIDetector`) otimizado
/// para execução offline diretamente no dispositivo.
///
/// Características principais:
/// - Singleton thread-safe para evitar múltiplas instâncias do modelo.
/// - Uso de `CIContext` para conversão rápida de imagem.
/// - Execução otimizada usando CPU + Neural Engine.
/// - Pipeline leve para análise em tempo real.
///
/// Fluxo interno:
/// UIImage
///     ↓
/// CVPixelBuffer (via CoreImage)
///     ↓
/// CoreML prediction
///     ↓
/// Softmax
///     ↓
/// Probabilidade final de IA
///
final class MLAnalyzer {

    /// Instância compartilhada do analyzer.
    ///
    /// Utiliza `nonisolated(unsafe)` para permitir acesso fora
    /// de contextos actor sem overhead de isolamento.
    nonisolated(unsafe) static let shared = MLAnalyzer()

    /// Contexto CoreImage reutilizado para evitar recriação
    /// frequente e reduzir overhead de processamento.
    private let ciContext = CIContext()
    
    private let analysisQueue = DispatchQueue(
        label: "ai.analysis.queue",
        qos: .background
    )

    /// Modelo CoreML carregado de forma lazy.
    ///
    /// O modelo é carregado apenas na primeira utilização,
    /// reduzindo o tempo de inicialização do app.
    private lazy var model: AIDetector = {

        let config = MLModelConfiguration()

        /// Permite execução usando CPU + Neural Engine.
        /// Melhor balanceamento entre performance e consumo.
        config.computeUnits = .cpuAndNeuralEngine

        /// Bundle do Swift Package.
        let bundle = Bundle.module

        guard let url = bundle.url(
            forResource: "AIDetector",
            withExtension: "mlmodelc"
        ) else {
            fatalError("Modelo não encontrado")
        }

        let mlmodel = try! MLModel(contentsOf: url, configuration: config)

        return AIDetector(model: mlmodel)

    }()

    /// Inicializador privado para garantir padrão singleton.
    private init() {}

    /// Executa análise ML e retorna probabilidade da imagem ser gerada por IA.
    ///
    /// - Parameter image: UIImage a ser analisada.
    /// - Returns: Valor entre `0.0` e `1.0`.
    ///     - 0 → provavelmente real
    ///     - 1 → provavelmente IA
    func score(image: UIImage, completion: @escaping (Float) -> Void) {

        analysisQueue.async {

            guard let buffer = image.fastPixelBuffer(context: self.ciContext) else {
                DispatchQueue.main.async {
                    completion(0)
                }
                return
            }

            do {

                let input = AIDetectorInput(x: buffer)
                let output = try self.model.prediction(input: input)

                guard let array = output.featureValue(for: "var_4710")?.multiArrayValue else {

                    DispatchQueue.main.async {
                        completion(0)
                    }

                    return
                }

                let logits = self.multiArrayToFloatArray(array)
                let probs = self.softmax(logits)

                let result = probs.count >= 2 ? probs[1] : 0

                DispatchQueue.main.async {
                    completion(result)
                }

            } catch {

                DispatchQueue.main.async {
                    completion(0)
                }
            }
        }
    }


    /// Aplica função Softmax para converter logits em probabilidades.
    ///
    /// - Parameter logits: Valores brutos do modelo.
    /// - Returns: Array de probabilidades normalizadas.
    private func softmax(_ logits: [Float]) -> [Float] {

        let maxLogit = logits.max() ?? 0
        let exps = logits.map { exp($0 - maxLogit) }
        let sum = exps.reduce(0,+)

        return exps.map { $0 / sum }
    }

    /// Converte `MLMultiArray` em `[Float]`.
    ///
    /// - Parameter array: Saída do modelo CoreML.
    /// - Returns: Array Swift com os valores convertidos.
    private func multiArrayToFloatArray(_ array: MLMultiArray) -> [Float] {

        let ptr = UnsafeMutablePointer<Float>(OpaquePointer(array.dataPointer))

        return Array(UnsafeBufferPointer(start: ptr, count: array.count))
    }
}
