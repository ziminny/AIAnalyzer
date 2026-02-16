//
//  Analisys.swift
//  RealLens
//
//  Created by Vagner Reis on 06/02/26.
//

import Foundation
import Photos

/// Define o contrato base para qualquer estratégia de análise
/// utilizada dentro do pipeline de IA.
///
/// O protocolo `Analisys` representa uma unidade responsável
/// por processar um tipo específico de mídia (ex: imagem, vídeo)
/// e retornar um resultado padronizado (`AIAnalysisResult`).
///
/// Cada implementação concreta deve especificar o tipo de mídia
/// através do `associatedtype AIMediaType`.
///
/// ## Arquitetura
///
/// Este protocolo segue o padrão **Strategy**, permitindo que
/// diferentes tipos de análise sejam adicionados ao sistema
/// sem alterar o código existente.
///
/// Como o protocolo possui `associatedtype`, ele não pode ser
/// armazenado diretamente em coleções heterogêneas. Para isso,
/// recomenda-se utilizar um wrapper com **type-erasure**
/// (ex: `AnyAnalysis`).
///
/// ## Implementando um analyzer
///
/// ```swift
/// final class PhotoAIAnalyzer: Analisys {
///
///     typealias AIMediaType = UIImage
///
///     var assetType: AssetType { .image }
///
///     func analyze(
///         media: UIImage,
///         metadata: [String : Any]
///     ) -> AIAnalysisResult {
///         // executar inferência do modelo
///     }
/// }
/// ```
///
/// ## Observações
///
/// - Cada analyzer deve ser responsável apenas por um tipo
///   de mídia.
/// - O `assetType` é usado para selecionar dinamicamente
///   qual analyzer deve executar.
///
/// - Important: A implementação deve garantir que o tipo
///   recebido em `media` corresponda ao tipo esperado.
protocol Analisys {
    
    /// Tipo de mídia suportado pelo analyzer.
    ///
    /// Exemplos:
    /// - `UIImage` para imagens
    /// - `URL` ou `AVAsset` para vídeos
    associatedtype AIMediaType
    
    /// Tipo de asset suportado (imagem, vídeo, etc).
    ///
    /// Usado pelo pipeline para selecionar o analyzer correto.
    var assetType: AssetType { get }
    
    /// Executa a análise sobre a mídia fornecida.
    ///
    /// - Parameters:
    ///   - media: Mídia a ser analisada.
    ///   - metadata: Metadados adicionais que podem
    ///     influenciar o processamento.
    ///
    /// - Returns:
    ///   Resultado padronizado contendo informações
    ///   geradas pela análise de IA.
    func analyze(
        media: AIMediaType,
        metadata: [String: Any],
        completion: @escaping (AIAnalysisResult) -> Void
    )
}
