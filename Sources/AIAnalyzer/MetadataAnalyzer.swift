//
//  MetadataAnalyzer.swift
//  RealLens
//
//  Created by Vagner Reis on 13/02/26.
//

import Foundation

/// Responsável por analisar metadados de mídia e gerar
/// um score heurístico indicando probabilidade de conteúdo
/// gerado por IA.
///
/// Esse analyzer NÃO utiliza Machine Learning.
/// Ele aplica apenas regras heurísticas baseadas em
/// padrões comuns encontrados em imagens geradas por IA.
///
/// ## Estratégia utilizada
///
/// O score é calculado somando pontos conforme
/// características específicas dos metadados:
///
/// - Ausência de EXIF → pode indicar exportação artificial.
/// - Presença de dados PNG → alguns pipelines de IA exportam
///   frequentemente em PNG.
/// - Ausência de GPS → comum em imagens sintéticas.
/// - Dimensões múltiplas de 64 → muitos modelos de IA
///   trabalham com grids alinhados (ex: Stable Diffusion).
///
/// ⚠️ IMPORTANTE:
///
/// Esse score NÃO deve ser usado isoladamente para
/// classificação definitiva. O ideal é combinar
/// com análise via CoreML.
///
/// ## Exemplo de uso
///
/// ```swift
/// let analyzer = MetadataAnalyzer()
/// let score = analyzer.analyze(metadata)
/// ```
struct MetadataAnalyzer {

    /// Analisa metadados e retorna um score heurístico.
    ///
    /// - Parameter metadata:
    ///   Dicionário de propriedades retornado por
    ///   `CGImageSourceCopyPropertiesAtIndex`.
    ///
    /// - Returns:
    ///   Um valor inteiro representando a probabilidade
    ///   heurística de a imagem ser gerada por IA.
    func analyze(_ metadata: [String: Any]) -> Int {

        var score = 0

        // Ausência de EXIF pode indicar imagem sintetizada
        if metadata["{Exif}"] == nil {
            score += 30
        }

        // PNG aparece frequentemente em pipelines de IA
        if metadata["{PNG}"] != nil {
            score += 15
        }

        // Ausência de GPS é comum em imagens artificiais
        if metadata["{GPS}"] == nil {
            score += 5
        }

        // Dimensões múltiplas de 64 são comuns em modelos generativos
        if let w = metadata["PixelWidth"] as? Int,
           let h = metadata["PixelHeight"] as? Int {

            if w % 64 == 0 && h % 64 == 0 {
                score += 20
            }
        }

        return score
    }
}

