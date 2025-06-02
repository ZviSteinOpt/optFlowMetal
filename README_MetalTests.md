# Running MetalTests (.xctest) in Xcode

This project uses XCTest to run tests written in Objective-C++ (`srcTests.mm`) that call into C++.

## ✅ One-time Setup

### 1. Build with Xcode generator

```bash
cd /Users/zvistein/GitHub_repos/optFlowMetal
rm -rf build
cmake -B build -GXcode -DCMAKE_OSX_SYSROOT=macosx15.4
open build/MetalOpenCV.xcodeproj
```

### 2. Create and configure test scheme

- In Xcode(above bar outsside the UI): `Product > Scheme > Manage Schemes`
- If `MetalTests` does **not** appear:
  - Click `+`
  - Select `MetalTests` target
  - Click OK
- Click **Edit...**
  - In the **“Test”** section, click `+` and add the `MetalTests` bundle if it’s missing
  - Make sure test plan is **not set** (use “default configuration”)
### 3. add frameworks
    go to MetalOpenCV
    build Phases
    chouse MetalTest
    under Link Binary With Libraries
    + MetalKit.framework
    + ModelIO.framework
     
### 4. Run tests

- In Xcode: select `MetalTests` in the top-left dropdown
- Press **Cmd + U** to run the tests

OR run from terminal:

```bash
xcodebuild test -scheme MetalTests -project build/MetalOpenCV.xcodeproj -destination 'platform=macOS'
```

## Notes
- `MetalTests` is built as a `.xctest` bundle using:
  ```cmake
  add_library(MetalTests MODULE srcTests.mm srcTests.cpp)
  set_target_properties(MetalTests PROPERTIES
      BUNDLE TRUE
      BUNDLE_EXTENSION "xctest"
      XCODE_PRODUCT_TYPE com.apple.product-type.bundle.unit-test
  )
  ```
- Test cases must be written as subclasses of `XCTestCase`.

$$$$$$$$$$$$$$$ FOR MY FUTURE ME$$$$$$$$$$$$$$$$$$
- I left when test runing sucessfully but I comment wjacoby  
gpu Mat hold MTLTexture m_texture;   tot as a pointer id<MTLTexture> 
this cause me trouble in wjacoby function signiture, and as I see it it looks lik data copy cause id is pointer.
so i guess I need to changes it , but it will cause a lot of aditional cahnges
