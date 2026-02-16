//
//  AnalisysPhotoMetadata.swift
//  RealLens
//
//  Created by Vagner Reis on 06/02/26.
//

import Foundation
import UIKit

/// Implementação concreta do protocolo `Analisys` responsável
/// por detectar se uma imagem foi possivelmente gerada por IA.
///
/// Essa classe combina duas estratégias de análise:
///
/// 1️⃣ Análise heurística baseada em metadados (rápida e barata)
/// 2️⃣ Inferência via modelo CoreML (mais precisa porém mais custosa)
///
/// ## Pipeline de análise
///
/// A ordem das etapas foi pensada para performance:
///
/// - Primeiro é executada a análise de metadados.
/// - Caso o score heurístico seja alto o suficiente,
///   a inferência ML pode ser evitada (early exit).
/// - Caso contrário, o modelo CoreML é utilizado.
/// - O resultado final combina ambos os scores.
///
/// ## Estratégia de fusão
///
/// ```
/// finalScore = (mlScore * 0.7) + (metadataScore * 0.3)
/// ```
///
/// Onde:
/// - ML possui maior peso por ser mais confiável.
/// - Metadata ajuda como sinal complementar.
///
/// ⚠️ Observação:
/// - Os pesos e thresholds podem ser ajustados conforme
///   testes reais e validação do modelo.
///
/// ## Uso
///
/// Essa classe é normalmente encapsulada por `AnyAnalysis`
/// e utilizada pelo `AIAnalyzer`.
final class PhotoAIAnalyzer: Analisys {

    typealias AIMediaType = UIImage

    /// Define que este analyzer trabalha apenas com imagens.
    var assetType: AssetType { .image }

    /// Analyzer heurístico baseado em metadados.
    private let metadataAnalyzer = MetadataAnalyzer()

    /// Analyzer baseado em Machine Learning (CoreML).
    private let mlAnalyzer = MLAnalyzer.shared

    /// Executa a análise completa combinando heurística
    /// e inferência ML.
    ///
    /// - Parameters:
    ///   - media: imagem a ser analisada.
    ///   - metadata: dicionário de metadados extraídos da imagem.
    ///
    /// - Returns:
    ///   Estrutura contendo:
    ///   - `isAI`: indica se a imagem foi classificada como IA.
    ///   - `confidence`: probabilidade final (0...1).
    func analyze(
        media: AIMediaType,
        metadata: [String: Any],
        completion: @escaping (AIAnalysisResult) -> Void
    ) {

        // 1️⃣ Análise rápida via metadata
        let metadataScore = metadataAnalyzer.analyze(metadata)

        // Early exit caso heurística indique forte evidência
        if metadataScore >= 60 {
            completion(AIAnalysisResult(
                isAI: true,
                confidence: Float(metadataScore) / 100
            )
           )
            return 
        }

        // 2️⃣ Inferência ML
         mlAnalyzer.score(image: media) { mlScore in
             // 3️⃣ Combinação dos resultados
             let finalScore =
                 (mlScore * 0.7) +
                 ((Float(metadataScore) / 100) * 0.3)
             
             completion(AIAnalysisResult(
                 isAI: finalScore > 0.5,
                 confidence: finalScore
             ))
        }
    }
}
