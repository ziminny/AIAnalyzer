// The Swift Programming Language
// https://docs.swift.org/swift-book

import UIKit

/// Entry point principal para executar análises de IA sobre mídia.
///
/// `AIAnalyzer` funciona como um **orquestrador de pipeline**, responsável por
/// centralizar e gerenciar diferentes estratégias de análise (`AnyAnalysis`)
/// disponíveis dentro do pacote.
///
/// A ideia é que o consumidor do package não precise conhecer detalhes
/// internos de cada modelo ou implementação. Basta fornecer a mídia e
/// os metadados, e o analyzer selecionará automaticamente a análise
/// adequada com base no tipo de asset.
///
/// ## Arquitetura
///
/// - Usa o padrão **Strategy + Type Erasure** (`AnyAnalysis`) para permitir
///   múltiplas implementações de análise (ex: imagem, vídeo, áudio).
/// - Facilita expansão futura adicionando novos analyzers sem alterar
///   a API pública.
/// - Mantém separação entre:
///     - Pipeline público (API do package)
///     - Implementação interna dos modelos CoreML.
///
/// ## Exemplo de uso
///
/// ```swift
/// let analyzer = AIAnalyzer()
///
/// if let result = analyzer.imageAnalyze(
///     image: image,
///     metadata: [:]
/// ) {
///     print(result)
/// }
/// ```
///
/// ## Thread Safety
///
/// Esta struct é imutável após inicialização.
/// Caso algum analyzer interno não seja thread-safe,
/// a sincronização deve ser tratada na implementação
/// concreta do analyzer.
///
/// ## Observações
///
/// - Novos analyzers devem ser adicionados ao array
///   `analisys` durante a inicialização.
/// - A ordem do array pode influenciar a prioridade
///   de seleção do analyzer.
///
/// - Important: Este pacote assume que os modelos
///   CoreML necessários já estão disponíveis nos
///   resources do Swift Package.
public struct AIAnalyzer {
    
    /// Lista de estratégias de análise disponíveis.
    ///
    /// Utiliza type-erasure (`AnyAnalysis`) para permitir
    /// armazenar diferentes implementações concretas
    /// que compartilham o mesmo comportamento.
    private let analisys: [AnyAnalysis]
    
    /// Inicializa o pipeline padrão de análise.
    ///
    /// Neste setup inicial, apenas o `PhotoAIAnalyzer`
    /// é registrado para análise de imagens.
    ///
    /// Para suportar novos tipos de mídia (ex: vídeo),
    /// basta adicionar novos analyzers aqui.
    public init() {
        self.analisys = [
            AnyAnalysis(PhotoAIAnalyzer())
        ]
    }
    
    /// Executa análise de IA para uma imagem.
    ///
    /// O método seleciona automaticamente o analyzer
    /// compatível com o tipo `.image` e executa o
    /// processamento usando o modelo correspondente.
    ///
    /// - Parameters:
    ///   - image: Instância de `UIImage` que será analisada.
    ///   - metadata: Dicionário contendo metadados opcionais
    ///     que podem influenciar a análise (ex: contexto,
    ///     flags, configurações adicionais).
    ///
    /// - Returns:
    ///   Um `AIAnalysisResult` caso a análise seja bem-sucedida,
    ///   ou `nil` se nenhum analyzer compatível for encontrado
    ///   ou se ocorrer falha durante o processamento.
    public func imageAnalyze(
        image: UIImage,
        metadata: [String: Any],
        completion: @escaping (AIAnalysisResult?) -> Void
    ) {

        guard let analyzer = analisys.first(where: { $0.assetType == .image }) else {
            completion(nil)
            return
        }

        analyzer.analyze(
            media: image,
            metadata: metadata,
            completion: completion
        )
    }

}

