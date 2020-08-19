//===-- DPUSubtarget.h - Define Subtarget for the DPU -----------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file declares the DPU specific subclass of TargetSubtargetInfo.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_DPU_DPUSUBTARGET_H
#define LLVM_LIB_TARGET_DPU_DPUSUBTARGET_H

#include "DPUFrameLowering.h"
#include "DPUInstrInfo.h"
#include "DPUTargetLowering.h"
#include "DPUSelectionDAGInfo.h"
#include "llvm/CodeGen/SelectionDAGTargetInfo.h"
#include "llvm/CodeGen/TargetSubtargetInfo.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/Target/TargetMachine.h"

#define GET_SUBTARGETINFO_HEADER
#include "DPUGenSubtargetInfo.inc"

namespace llvm {
class StringRef;

class DPUSubtarget : public DPUGenSubtargetInfo {
  virtual void anchor();
  DPUInstrInfo InstrInfo;
  DPUFrameLowering FrameLowering;
  DPUTargetLowering TargetLowering;
  const DPUSelectionDAGInfo TSInfo;
  bool noSugar;
  bool disableMramCheck;

public:
  // This constructor initializes the data members to match that
  // of the specified triple.
  DPUSubtarget(const Triple &TT, const std::string &CPU, const std::string &FS,
               const TargetMachine &TM);

  // ParseSubtargetFeatures - Parses features string setting specified
  // subtarget options.  Definition of function is auto generated by tblgen.
  void ParseSubtargetFeatures(StringRef CPU, StringRef FS);

  const DPUInstrInfo *getInstrInfo() const override { return &InstrInfo; }

  const TargetFrameLowering *getFrameLowering() const override {
    return &FrameLowering;
  }

  const DPUTargetLowering *getTargetLowering() const override {
    return &TargetLowering;
  }

  const SelectionDAGTargetInfo *getSelectionDAGInfo() const override {
    return &TSInfo;
  }
  const DPURegisterInfo *getRegisterInfo() const override {
    return &InstrInfo.getRegisterInfo();
  }

  bool enableMachineScheduler() const override;
};
} // namespace llvm

#endif
