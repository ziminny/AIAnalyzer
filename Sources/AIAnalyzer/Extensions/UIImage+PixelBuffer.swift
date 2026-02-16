//
//  UIImage+PixelBuffer.swift
//  AIAnalyzer
//
//  Created by Vagner Reis on 13/02/26.
//

import Foundation
import UIKit
import CoreImage
import CoreVideo

extension UIImage {

    func toPixelBuffer() -> CVPixelBuffer? {

        let attrs = [
            kCVPixelBufferCGImageCompatibilityKey: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey: true
        ] as CFDictionary

        var pixelBuffer: CVPixelBuffer?

        let width = 224
        let height = 224

        CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            kCVPixelFormatType_32BGRA,
            attrs,
            &pixelBuffer
        )

        guard let buffer = pixelBuffer else { return nil }

        CVPixelBufferLockBaseAddress(buffer, [])

        let context = CGContext(
            data: CVPixelBufferGetBaseAddress(buffer),
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        )

        guard let cgImage = self.cgImage else { return nil }

        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        CVPixelBufferUnlockBaseAddress(buffer, [])

        return buffer
    }
}

extension UIImage {

    func fastPixelBuffer(context: CIContext) -> CVPixelBuffer? {

        guard let cgImage = self.cgImage else { return nil }

        let width = 224
        let height = 224

        var pixelBuffer: CVPixelBuffer?

        let attrs = [
            kCVPixelBufferCGImageCompatibilityKey: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey: true,
            kCVPixelBufferMetalCompatibilityKey: true
        ] as CFDictionary

        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            kCVPixelFormatType_32BGRA,
            attrs,
            &pixelBuffer
        )

        guard status == kCVReturnSuccess,
              let buffer = pixelBuffer else {
            return nil
        }

        let ciImage = CIImage(cgImage: cgImage)

        // resize + render direto no buffer (MUITO mais rápido)
        let scaleX = CGFloat(width) / ciImage.extent.width
        let scaleY = CGFloat(height) / ciImage.extent.height

        let resized = ciImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

        context.render(resized, to: buffer)

        return buffer
    }
}


