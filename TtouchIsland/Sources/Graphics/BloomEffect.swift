//
//  BloomEffect.swift
//  TtouchIsland
//
//  Created by Hyeok Cho on 7/29/25.
//  Copyright © 2025 Graphicana. All rights reserved.
//

import Combine
import Foundation
import Metal
import MetalPerformanceShaders
import RealityKit
import SwiftUI

final class BloomEffect: @unchecked Sendable {
    // MTLTexture: Metal에서 GPU가 사용하는 이미지데이터 객체. 픽셀 데이터를 사용. JPG, PNG와는 다름
    // png → UIImage → CGImage → MTLTexture 순으로 변환함
    var bloomTexture: MTLTexture?
    var illuminationTexture: MTLTexture?

    let bloomThreshold: Float = 0.55
    let bloomBlur: Float = 40.0

    // 옵셔널 타입으로 선언되었기에 초기화 할 게 없지만 명시는 해둠.
    init() {}

    // PostProcessEffectContext는 후처리 효과를 적용할 때 필요한 GPU 관련 리소스들을 모아놓은 컨텍스트 객체
    // PostProcessEffectContext에는 후처리 효과에 필요한 모든 기본 리소스(GPU 디바이스, 입력/출력 텍스처 등)는 이미 다 갖고 있고, 어떤 커맨드버퍼를 사용할지만 우리가 결정
//    func postProcess(context: borrowing PostProcessEffectContext<any MTLCommandBuffer>) {
//        //commandBuffer는 GPU에 명령을 보내는 작업들의 묶음
//        //MetalPerformanceShaders에서 이 버퍼를 이용해 이미지를 처리하는 명령을 추가함
//        //예를 들면, 밝기 추출, 곱셉, 블러, 합성 등이 commandBuffer에 쌓임
//        let commandBuffer = context.commandBuffer
//        //옵셔널과 nil을 비교할 때는 ?를 붙이지 않아도 됨
//        if bloomTexture == nil ||
//            //화면 해상도가 바뀌는 경우, 혹은 윈도우 크기 조절 등이 일어났을 때 기존 bloomTexture의 크기다 맞지 않게 되고, 그러면 GPU연산이 실패할 수 있음
//            //iPhone에서도 화면 회전(가로/세로 변경)**이 발생하면 내부 렌더링 해상도가 달라질 수 있음
//            //드물지만, 다른 해상도(예: 외부 디스플레이, AirPlay, 미러링 등)가 적용될 수도 있음
//            //프레임워크의 내부 업데이트(예: 시스템이 실제 내부 텍스처 크기를 바꿀 수 있는 경우)도 완전히 배제할 수 없으므로 필요
//            //context.sourceColorTexture = 실행기기에서 GPU가 렌더링한 결과(=화면 이미지)
//            //document 설명 보면 sourceColorTexture는 rendered frame buffer라고 나옴
//            //frame buffer가 뭐냐면 컴퓨터가 렌더링한 화면을 모니터로 내보내기 전에 잠깐 저장하는 곳임
//            //예를 들어, 주사율이 60hz인 모니터가 있다 치면 1초에 60회 이미지가 frame buffer에 저장됨
//            //frame buffer는 하나의 프레임만 저장함. 즉, 다음 프레임이 계속 덮어씌워지는 곳임
//            bloomTexture?.width != context.sourceColorTexture.width ||
//            bloomTexture?.height != context.sourceColorTexture.height {
//            //텍스쳐가 없거나 GPU가 렌더링한 결과(=화면 이미지)와 해상도가 다른 경우 빈 텍스쳐 생성
//            bloomTexture = makeEmptyTextureLike(context.sourceColorTexture, device: context.device)
//            illuminationTexture = makeEmptyTextureLike(context.sourceColorTexture, device: context.device)
//        }
//        guard let illuminationTexture, var bloomTexture else { return }
//
//        //illuminationTexture ← 밝은 부분만 추출
//        //bloomTexture ← 밝은 부분 × 원본 색
//        //bloomTexture ← Gaussian blur 적용됨 (soft glow)
//        //targetColorTexture ← 원본 + blur된 bloom 합성
//
//        //앞으로 나오는 MPSImage~ 는 모두 MetalPerformanceShader관련 코드임
//        //MPSImageThresholdToZero: single image를 binary image로 변환함
//        //single 이미지는 회색조 binary 이미지는 각 픽셀이 두 값 중 하나만 가짐 (흑/백)
//        //device: 어떤 GPU에서 실행할지, thresholdValue: 임계값, linearGrayColorTransform: graysclae 변환 계수
//        let brightness = MPSImageThresholdToZero(
//            device: context.device,
//            thresholdValue: bloomThreshold,
//            linearGrayColorTransform: [1.1, 0.2, -0.3]
//        )
//        brightness.encode(
//            commandBuffer: commandBuffer,
//            sourceTexture: context.sourceColorTexture,
//            destinationTexture: illuminationTexture
//        )
//
//        //멀티플라이 적용
//        let multiply = MPSImageMultiply(device: context.device)
//        multiply.primaryScale = 1.0
//        multiply.secondaryScale = 1.0
//        multiply.bias = 0.0
//        multiply.encode(
//            commandBuffer: commandBuffer,
//            primaryTexture: illuminationTexture,
//            secondaryTexture: context.sourceColorTexture,
//            destinationTexture: bloomTexture
//        )
//
//        //가우시안 블러 적용
//        let gaussianBlur = MPSImageGaussianBlur(device: context.device, sigma: bloomBlur)
//        gaussianBlur.encode(commandBuffer: commandBuffer, inPlaceTexture: &bloomTexture)
//
//        let add = MPSImageAdd(device: context.device)
//        add.primaryScale = 0//0.7
//        add.secondaryScale = 1//0.6
    ////        최종 후처리 이미지를 씌우는 코드. 이거 없음 새까맣게 나옴
//        add.encode(commandBuffer: commandBuffer,
//                   primaryTexture: context.sourceColorTexture,
//                   secondaryTexture: bloomTexture,
//                   destinationTexture: context.targetColorTexture)
//    }

    func makeEmptyTextureLike(_ source: MTLTexture, device: MTLDevice) -> MTLTexture? {
        let desc = MTLTextureDescriptor()
        desc.textureType = source.textureType
        desc.pixelFormat = source.pixelFormat
        desc.width = source.width
        desc.height = source.height
        desc.mipmapLevelCount = 1
        desc.usage = [.shaderRead, .shaderWrite]
        desc.storageMode = .shared
        guard let texture = device.makeTexture(descriptor: desc)
        else { return nil }

        let width = desc.width
        let height = desc.height
        let bytesPerPixel = {
            switch source.pixelFormat {
            case .bgra8Unorm_srgb: 4
            case .bgra10_xr_srgb: 5
            case .rgba16Float: 8
            default:
                fatalError("Unhandled pixel format \(source.pixelFormat)")
            }
        }()
        let bytesPerRow = width * bytesPerPixel
        let emptyData = [UInt8](repeating: 0, count: bytesPerRow * height)

        let region = MTLRegionMake2D(0, 0, width, height)
        texture.replace(region: region, mipmapLevel: 0, withBytes: emptyData, bytesPerRow: bytesPerRow)
        return texture
    }

    static func deviceSupportsEffect() -> Bool {
        let device = MTLCreateSystemDefaultDevice()
        return device?.supportsFamily(.apple8) ?? false
    }
}
