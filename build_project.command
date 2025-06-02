#!/bin/bash
cd /Users/zvistein/GitHub_repos/optFlowMetal
rm -rf build
cmake -B build -GXcode
open build/MetalOpenCV.xcodeproj