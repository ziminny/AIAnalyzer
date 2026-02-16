//
//  AssetType.swift
//  RealLens
//
//  Created by Vagner Reis on 06/02/26.
//

import Foundation
import Photos

/// Representa os tipos de mídia suportados pelo pipeline
/// de análise do `AIAnalyzer`.
///
/// Esse enum é utilizado para:
///
/// - Identificar qual analyzer deve ser executado.
/// - Abstrair tipos específicos do sistema (ex: `PHAssetMediaType`).
/// - Permitir expansão futura para novos formatos (ex: livePhoto, audio).
///
/// ## Casos suportados
///
/// - `image`: imagens estáticas (JPEG, PNG, HEIC, etc).
/// - `video`: vídeos (MOV, MP4, etc).
///
/// ## Integração com Photos Framework
///
/// A função `transform(ofType:)` converte o tipo nativo
/// do Photos (`PHAssetMediaType`) para o tipo interno
/// do pipeline.
///
/// Isso desacopla o domínio interno da implementação
/// específica do iOS.
///
/// ## Exemplo
///
/// ```swift
/// if let assetType = AssetType.transform(ofType: asset.mediaType) {
///     // usar no pipeline de análise
/// }
/// ```
public enum AssetType {

    /// Representa imagens estáticas.
    case image

    /// Representa arquivos de vídeo.
    case video

    /// Converte um `PHAssetMediaType` para `AssetType`.
    ///
    /// - Parameter type: Tipo de mídia vindo do Photos framework.
    /// - Returns:
    ///   Um `AssetType` correspondente ou `nil`
    ///   caso o tipo não seja suportado pelo analyzer.
    public static func transform(ofType type: PHAssetMediaType) -> Self? {

        switch type {

        case .image:
            return .image

        case .video:
            return .video

        default:
            // Tipos não suportados atualmente
            // (ex: unknown, audio, etc)
            return nil
        }
    }
}

