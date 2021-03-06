set(LLVM_LINK_COMPONENTS
  AllTargetsAsmParsers
  AllTargetsCodeGens
  AllTargetsDescs
  AllTargetsInfos
  Analysis
  BitWriter
  CodeGen
  Core
  IPO
  IRReader
  AggressiveInstCombine
  InstCombine
  Instrumentation
  Linker
  ObjCARCOpts
  ScalarOpts
  Support
  Target
  TransformUtils
  Vectorize
  )

add_llvm_tool(bugpoint
  BugDriver.cpp
  CrashDebugger.cpp
  ExecutionDriver.cpp
  ExtractFunction.cpp
  FindBugs.cpp
  Miscompilation.cpp
  OptimizerDriver.cpp
  ToolRunner.cpp
  bugpoint.cpp

  ENABLE_PLUGINS

  DEPENDS
  intrinsics_gen
  SUPPORT_PLUGINS
  )
export_executable_symbols(bugpoint)
