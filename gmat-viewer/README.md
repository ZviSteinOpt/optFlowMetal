# GMAT Viewer

Image Watch for Rust — visualize `Mat` matrices live during debugging in VS Code / Cursor.

Built for [forge_cv](https://github.com/ZviSteinOpt/forge_cv)'s `Mat` type. Inspect images, feature maps, and numeric matrices without leaving the debugger.

## Features

- Browse multiple matrices in a sidebar
- Supports uint8, int32, float32, float64 with any number of channels
- Linked pan/zoom across images
- Pixel-level inspection with per-channel values on hover
- Zoom in to see individual pixel values overlaid on the image
- Normalize toggle for float data

### Overview — switch between RGB and grayscale

![overview](https://raw.githubusercontent.com/ZviSteinOpt/optFlowMetal/main/gmat-viewer/readme/overview.gif)

### Pixel values — zoom in to inspect individual values

![pixel values](https://raw.githubusercontent.com/ZviSteinOpt/optFlowMetal/main/gmat-viewer/readme/pixel_values.gif)

## Usage

1. Set a breakpoint after creating a `Mat`
2. When the debugger hits the breakpoint, right-click a `Mat` variable and select **GMAT: View Matrix Variable**
3. The Mat Viewer panel opens with all watched matrices

Matrices are serialized to `.gmat` files via `mat.save_debug()` and displayed in the viewer.

## Supported types

| ScalarType | Display |
|---|---|
| `Uint8` | 0-255 values, color-mapped |
| `Int32` | Integer values |
| `Float32` | Normalized to [0,1] when Norm is checked |
| `Float64` | Normalized to [0,1] when Norm is checked |

## Install

```
cursor --install-extension gmat-viewer-0.3.0.vsix
```
