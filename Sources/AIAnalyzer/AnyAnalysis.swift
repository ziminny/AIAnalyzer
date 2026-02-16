//
//  AnyAnalysis.swift
//  RealLens
//
//  Created by Vagner Reis on 13/02/26.
//

import Foundation

/// Type-erasure wrapper para o protocolo `Analisys`.
///
/// Como o protocolo `Analisys` possui um `associatedtype`,
/// não é possível armazenar diferentes implementações dele
/// diretamente em uma coleção heterogênea (ex: `[Analisys]`).
///
/// O `AnyAnalysis` resolve essa limitação utilizando
/// **type-erasure**, permitindo armazenar múltiplos analyzers
/// com tipos de mídia diferentes dentro de uma única coleção.
///
/// ## Como funciona
///
/// - Captura a implementação concreta do analyzer.
/// - Converte o método `analyze` em uma closure interna.
/// - Faz o casting dinâmico do tipo de mídia (`Any`)
///   para o tipo esperado pelo analyzer.
///
/// ## Arquitetura
///
/// Esse padrão permite:
///
/// - Adicionar novos analyzers sem alterar o pipeline.
/// - Suportar múltiplos tipos de mídia (imagem, vídeo, etc).
/// - Selecionar o analyzer correto em runtime usando
///   `assetType`.
///
/// ## Exemplo de uso
///
/// ```swift
/// let analyzers: [AnyAnalysis] = [
///     AnyAnalysis(PhotoAIAnalyzer()),
///     AnyAnalysis(VideoAIAnalyzer())
/// ]
///
/// let result = analyzers
///     .first(where: { $0.assetType == .image })?
///     .analyze(media: image, metadata: [:])
/// ```
///
/// ## Segurança de tipos
///
/// O método `analyze(media:)` recebe `Any`, porém:
///
/// - Internamente é feito cast seguro para o tipo esperado.
/// - Caso o tipo seja inválido, retorna `nil`.
///
/// - Important: Sempre garanta que o tipo de mídia enviado
///   corresponde ao `assetType`, evitando falhas de casting.
    struct AnyAnalysis {
        
        let assetType: AssetType
        
        private let _analyze: (Any, [String: Any], @escaping (AIAnalysisResult?) -> Void) -> Void
        
        init<A: Analisys>(_ analysis: A) {
            
            assetType = analysis.assetType
            
            _analyze = { media, metadata, completion in
                
                guard let typedMedia = media as? A.AIMediaType else {
                    completion(nil)
                    return
                }
                
                analysis.analyze(
                    media: typedMedia,
                    metadata: metadata,
                    completion: completion
                )
            }
        }
        
        func analyze(
            media: Any,
            metadata: [String: Any],
            completion: @escaping (AIAnalysisResult?) -> Void
        ) {
            
            _analyze(media, metadata, completion)
        }
    }
