/*
  Copyright © 2025 Apple Inc.

  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import simd

extension simd_quatf {
    // 카메라의 수직 회전(상하 기울임)을 제거하고 수평 회전만 남김
    // 플레이어가 위나 아래를 보더라도 캐릭터는 지면에 평행하게 이동하게 됨.
    var flattened: simd_quatf {
        let forward = simd_normalize(simd_act(self, [0, 0, 1]))
        var flatForward = forward
        flatForward.y = 0
        flatForward = simd_normalize(flatForward)

        return simd_quatf(from: [0, 0, 1], to: flatForward)
    }
}
