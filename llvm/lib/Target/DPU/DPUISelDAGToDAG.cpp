//===-- DPUISelDAGToDAG.cpp - A dag to dag inst selector for DPU ----------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file defines an instruction selector for the DPU target.
//
//===----------------------------------------------------------------------===//

#include "DPUISelDAGToDAG.h"
#include "DPUTargetMachine.h"

#include "DPUISelLowering.h"
#include "llvm/CodeGen/ISDOpcodes.h"
#include "llvm/CodeGen/MachineConstantPool.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/SelectionDAGISel.h"
#include "llvm/CodeGen/SelectionDAGNodes.h"
#include "llvm/IR/GlobalObject.h"
#include "llvm/IR/Intrinsics.h"
#include "llvm/Support/Compiler.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"

#define DEBUG_TYPE "dpu-isel"

using namespace llvm;
#define GET_INSTRINFO_ENUM

#include "DPUGenInstrInfo.inc"

#define GET_REGINFO_ENUM

#include "DPUGenRegisterInfo.inc"

namespace {
class DPUDAGToDAGISel : public SelectionDAGISel {
public:
  DPUDAGToDAGISel(TargetMachine &tm, CodeGenOpt::Level OptLevel)
      : SelectionDAGISel(tm, OptLevel) {}

  bool runOnMachineFunction(MachineFunction &MF) override;

  StringRef getPassName() const override;

private:
  // Include the pieces autogenerated from the target description.
#include "DPUGenDAGISel.inc"

  void Select(SDNode *N) override;

  // Complex Pattern for address selection. Declared by DPUInstrInfo.td.
  bool SelectAddr(SDValue Addr, SDValue &Base, SDValue &Offset);

  bool SelectAddrFI(SDValue Addr, SDValue &Base);

  void LowerGlobalAddress(SDValue Addr, SDValue Base);

  // Inline assembly directives.
  /// SelectInlineAsmMemoryOperand - Implement addressing mode selection for
  /// inline asm expressions.
  bool SelectInlineAsmMemoryOperand(const SDValue &Op, unsigned ConstraintID,
                                    std::vector<SDValue> &OutOps) override;

  // This special function is a barrier to validate the result of a Select.
  // It checks the consistence of a selection result, thus immediatly
  // stopping the flow in case of error, rather than letting the things
  // go and get untrackable errors later on in the process.
  bool VerifyThatSelectionMakesSense(SDNode *result);

  // Checks whether the source of a load operation is the requested address
  // space.
  bool IsALoadFromAddrSpace(SDNode *Node, unsigned int AddrSpace) const;

  // Checks whether the target of a store operation is the requested address
  // space.
  bool IsAStoreToAddrSpace(SDNode *Node, unsigned int AddrSpace) const;

  bool IsGlobalAddrInImmediateSection(SDNode *Node) const;

  void processFunctionAfterISel(MachineFunction &MF);

  bool replaceUsesWithConstantReg(MachineRegisterInfo *MRI,
                                  const DPUInstrInfo *DII,
                                  const TargetRegisterInfo *TRI,
                                  const MachineInstr &MI);

  bool SelectAddLikeOr(SDNode *Parent, SDValue N, SDValue &Out);
};
} // namespace

StringRef DPUDAGToDAGISel::getPassName() const { return "DPUDAGToDAGISel"; }

bool DPUDAGToDAGISel::runOnMachineFunction(MachineFunction &MF) {
  bool Ret = SelectionDAGISel::runOnMachineFunction(MF);

  processFunctionAfterISel(MF);

  return Ret;
}

void DPUDAGToDAGISel::processFunctionAfterISel(MachineFunction &MF) {
  MachineRegisterInfo *MRI = &MF.getRegInfo();

  auto &SubTarget = static_cast<const DPUSubtarget &>(MF.getSubtarget());
  auto InstrInfo = SubTarget.getInstrInfo();
  auto RegInfo = SubTarget.getRegisterInfo();

  for (MachineFunction::iterator MFI = MF.begin(), MFE = MF.end(); MFI != MFE;
       ++MFI)
    for (MachineBasicBlock::iterator I = MFI->begin(); I != MFI->end(); ++I) {
      replaceUsesWithConstantReg(MRI, InstrInfo, RegInfo, *I);
    }
}

static inline bool canCommuteOperation(MachineInstr *MI, unsigned opNo,
                                       unsigned &newOpNo) {
  switch (MI->getOpcode()) {
  case DPU::ADDrrr:
  case DPU::ANDrrr:
  case DPU::ORrrr:
  case DPU::XORrrr:
    switch (opNo) {
    case 1:
      newOpNo = 2;
      break;
    case 2:
      newOpNo = 1;
      break;
    default:
      return false;
    }

    return true;
  default:
    return false;
  }
}

bool DPUDAGToDAGISel::replaceUsesWithConstantReg(MachineRegisterInfo *MRI,
                                                 const DPUInstrInfo *DII,
                                                 const TargetRegisterInfo *TRI,
                                                 const MachineInstr &MI) {
  unsigned DstReg = 0, CstReg = 0;

  if (MI.getOpcode() == DPU::COPY) {
    unsigned reg = MI.getOperand(1).getReg();

    DstReg = MI.getOperand(0).getReg();
    switch (reg) {
    case DPU::ID:
    case DPU::ID2:
    case DPU::ID4:
    case DPU::ID8:
      CstReg = reg;
      break;
    default:
      break;
    }
  } else if (((MI.getOpcode() == DPU::MOVErr) &&
              (MI.getOperand(1).getReg() == DPU::ZERO)) ||
             ((MI.getOpcode() == DPU::MOVEri) && (MI.getOperand(1).isImm()) &&
              (MI.getOperand(1).getImm() == 0))) {
    DstReg = MI.getOperand(0).getReg();
    CstReg = DPU::ZERO;
  } else if (((MI.getOpcode() == DPU::MOVErr) &&
              (MI.getOperand(1).getReg() == DPU::ONE)) ||
             ((MI.getOpcode() == DPU::MOVEri) && (MI.getOperand(1).isImm()) &&
              (MI.getOperand(1).getImm() == 1))) {
    DstReg = MI.getOperand(0).getReg();
    CstReg = DPU::ONE;
  } else if (((MI.getOpcode() == DPU::MOVErr) &&
              (MI.getOperand(1).getReg() == DPU::LNEG)) ||
             ((MI.getOpcode() == DPU::MOVEri) && (MI.getOperand(1).isImm()) &&
              (MI.getOperand(1).getImm() == -1))) {
    DstReg = MI.getOperand(0).getReg();
    CstReg = DPU::LNEG;
  } else if (((MI.getOpcode() == DPU::MOVErr) &&
              (MI.getOperand(1).getReg() == DPU::MNEG)) ||
             ((MI.getOpcode() == DPU::MOVEri) && (MI.getOperand(1).isImm()) &&
              (MI.getOperand(1).getImm() == 0x8000000))) {
    DstReg = MI.getOperand(0).getReg();
    CstReg = DPU::MNEG;
  }

  if (!CstReg)
    return false;

  // Replace uses with CstReg.
  for (MachineRegisterInfo::use_iterator U = MRI->use_begin(DstReg),
                                         E = MRI->use_end();
       U != E;) {
    MachineOperand &MO = *U;
    unsigned OpNo = U.getOperandNo();
    MachineInstr *UMI = MO.getParent();
    ++U;

    // Do not replace if it is a phi's operand or is tied to def operand.
    if (UMI->isPHI() || UMI->isRegTiedToDefOperand(OpNo) || UMI->isPseudo())
      continue;

    // Also, we have to check that the register class of the operand
    // contains the constant register.
    if (!UMI->getRegClassConstraint(OpNo, DII, TRI)->contains(CstReg)) {
      unsigned newOpNo;

      if (canCommuteOperation(UMI, OpNo, newOpNo)) {
        auto OtherReg = UMI->getOperand(newOpNo).getReg();

        if (UMI->getRegClassConstraint(newOpNo, DII, TRI)->contains(CstReg) &&
            (!TRI->isPhysicalRegister(OtherReg) ||
             UMI->getRegClassConstraint(OpNo, DII, TRI)->contains(OtherReg))) {
          UMI->getOperand(newOpNo).setReg(CstReg);
          UMI->getOperand(OpNo).setReg(OtherReg);
        }
      }

      continue;
    }

    MO.setReg(CstReg);
  }

  return true;
}

bool DPUDAGToDAGISel::SelectAddrFI(SDValue Addr, SDValue &Base) {
  if (auto FIN = dyn_cast<FrameIndexSDNode>(Addr)) {
    Base = CurDAG->getTargetFrameIndex(FIN->getIndex(), MVT::i32);
    return true;
  }
  return false;
}

bool DPUDAGToDAGISel::SelectAddr(SDValue Addr, SDValue &Base, SDValue &Offset) {
  SDLoc DL(Addr);

  LLVM_DEBUG({
    dbgs() << "DPU/DAGSel - SelectAddr of ";
    Addr.dump(CurDAG);
  });
  if (FrameIndexSDNode *FIN = dyn_cast<FrameIndexSDNode>(Addr)) {
    Base = CurDAG->getTargetFrameIndex(FIN->getIndex(), MVT::i32);
    Offset = CurDAG->getTargetConstant(0, DL, MVT::i32);
    return true;
  }

  switch (Addr.getOpcode()) {
  case ISD::FrameIndex:
    assert(false && "DPU - UNEXPECTED LOWERING OF FRAMEINDEX IN SelectAddr");
    break;

  case ISD::TargetGlobalAddress:
    LLVM_DEBUG({
      dbgs() << "DPU/DAGsel - selecting target global address for ";
      Addr->dump(CurDAG);
    });
    return false;

  case ISD::TargetExternalSymbol:
    LLVM_DEBUG({
      dbgs() << "DPU/DAGsel - selecting target external symbol for address ";
      Addr->dump(CurDAG);
    });
    // Disp = CurDAG->getTargetExternalSymbol(AM.ES, MVT::i32,
    // 0/*AM.SymbolFlags*/);
    return false;

  default:
    LLVM_DEBUG({
      dbgs() << "DPU/DAGsel - no specific processing on address ";
      Addr->dump(CurDAG);
      dbgs() << "\n";
    });
  }

  LLVM_DEBUG({
    dbgs() << "DPU/DAGSel - select addr for DAG \n";
    Addr->dump(CurDAG);
  });
  if (CurDAG->isBaseWithConstantOffset(Addr)) {
    // Addresses of the form FI + const or FI | const
    LLVM_DEBUG(dbgs() << "DPU/DAGSel - FI with constant!\n");
    ConstantSDNode *CN = dyn_cast<ConstantSDNode>(Addr.getOperand(1));
    if (isInt<32>(CN->getSExtValue())) {

      // If the first operand is a FI, get the TargetFI Node
      if (FrameIndexSDNode *FIN =
              dyn_cast<FrameIndexSDNode>(Addr.getOperand(0)))
        Base = CurDAG->getTargetFrameIndex(FIN->getIndex(), MVT::i32);
      else
        Base = Addr.getOperand(0);

      Offset = CurDAG->getTargetConstant(CN->getSExtValue(), DL, MVT::i32);
      return true;
    }
  }

  Base = Addr;
  Offset = CurDAG->getTargetConstant(0, DL, MVT::i32, true);
  return true;
}

bool DPUDAGToDAGISel::IsALoadFromAddrSpace(SDNode *Node,
                                           unsigned int AddrSpace) const {
  LoadSDNode *LoadOp = cast<LoadSDNode>(Node);
  if (LoadOp) {
    MachineMemOperand *MemOperand = LoadOp->getMemOperand();
    if (MemOperand) {
      const Value *Operand = MemOperand->getValue();
      if (Operand) {
        auto *PT = dyn_cast<PointerType>(Operand->getType());
        if (PT) {
          auto ThisAddrSpace = PT->getAddressSpace();
          return ThisAddrSpace == AddrSpace;
        }
      } else {
        return AddrSpace == DPUADDR_SPACE::WRAM;
      }
    }
  }
  return false;
}

bool DPUDAGToDAGISel::IsAStoreToAddrSpace(SDNode *Node,
                                          unsigned int AddrSpace) const {
  StoreSDNode *StoreOp = cast<StoreSDNode>(Node);
  if (StoreOp) {
    MachineMemOperand *MemOperand = StoreOp->getMemOperand();
    if (MemOperand) {
      const Value *Operand = MemOperand->getValue();
      if (Operand) {
        auto *PT = dyn_cast<PointerType>(Operand->getType());
        if (PT) {
          auto ThisAddrSpace = PT->getAddressSpace();
          return ThisAddrSpace == AddrSpace;
        }
      } else {
        return AddrSpace == DPUADDR_SPACE::WRAM;
      }
    }
  }
  return false;
}

bool DPUDAGToDAGISel::IsGlobalAddrInImmediateSection(SDNode *Node) const {
  if (Node->getOpcode() != DPUISD::Wrapper) {
    return false;
  }

  SDValue Value = Node->getOperand(0);

  GlobalAddressSDNode *AddrNode = cast<GlobalAddressSDNode>(Value);

  if (!AddrNode) {
    return false;
  }

  const auto GO = AddrNode->getGlobal()->getBaseObject();
  const auto *GVA = dyn_cast<GlobalVariable>(GO);

  if (!GVA->hasSection()) {
    return false;
  }

  StringRef Section = GVA->getSection();

  return Section.startswith(".data.immediate_memory");
}

void DPUDAGToDAGISel::Select(SDNode *Node) {
  unsigned Opcode = Node->getOpcode();

  // We may find a custom node, enclosing something which is already
  // a machine opcode, generated by the target lowering stage.
  if (Node->isMachineOpcode()) {
    LLVM_DEBUG(dbgs() << "DPU/DAGsel - skipping DPU machine instruction "
                      << Opcode << '\n');
    return;
  }

  switch (Opcode) {
  case ISD::FrameIndex: {
    int FI = cast<FrameIndexSDNode>(Node)->getIndex();
    EVT VT = Node->getValueType(0);
    SDValue TFI = CurDAG->getTargetFrameIndex(FI, VT);
    unsigned Opc = DPU::ADDrri;
    if (Node->hasOneUse()) {
      LLVM_DEBUG(dbgs() << "hasOneUse\n");
      CurDAG->SelectNodeTo(Node, Opc, VT,
                           CurDAG->getRegister(DPU::R22, MVT::i32), TFI);
      return;
    } else {
      ReplaceNode(Node, CurDAG->getMachineNode(
                            Opc, SDLoc(Node), VT,
                            CurDAG->getRegister(DPU::R22, MVT::i32), TFI));
      return;
    }
  } break;

  case ISD::SETCC: {
    // The target lowering is long gone now and trapped the setcc to transform
    // them to DPUISD::SETCC. In between, some optimization may have generated
    // new setcc. Typically: i1: xor X Y is changed to setcc.
    LLVM_DEBUG(dbgs() << "DPU/DAGsel - native setcc generated after target "
                         "lowering. Normalizing\n");
    SDValue V = SDValue(Node, 0);
    auto *DPUTLI = (const DPUTargetLowering *)TLI;
    Node = DPUTLI->LowerSetCc(V, *CurDAG).getNode();
  } break;
  }

  // Select the default instruction
  SelectCode(Node);
}

bool DPUDAGToDAGISel::SelectInlineAsmMemoryOperand(
    const SDValue &Op, unsigned ConstraintID, std::vector<SDValue> &OutOps) {
  LLVM_DEBUG({
    dbgs() << "DPU/DAGsel - selecting inline assembly operand ";
    Op.dump(CurDAG);
    dbgs() << ConstraintID << "\n";
  });
  SDValue Op0, Op1;
  switch (ConstraintID) {
  default:
    return true;
  case InlineAsm::Constraint_m: // memory
    if (!SelectAddr(Op, Op0, Op1))
      return true;
    break;
  }

  OutOps.push_back(Op0);
  OutOps.push_back(Op1);
  return false;
}

// Determine whether an ISD::OR's operands are suitable to turn the operation
// into an addition, which often has more compact encodings.
bool DPUDAGToDAGISel::SelectAddLikeOr(SDNode *Parent, SDValue N, SDValue &Out) {
  assert(Parent->getOpcode() == ISD::OR && "unexpected parent");
  Out = N;
  bool SanityCheck =
      !(N != Parent->getOperand(0) && N != Parent->getOperand(1));
  // In debug, assert
  assert(SanityCheck);
  // In release, let's just not do the optimization
  if (!SanityCheck)
    return false;
  return CurDAG->haveNoCommonBitsSet(Parent->getOperand(0),
                                     Parent->getOperand(1));
}

/// createDPUISelDag - This pass converts a legalized DAG into a
/// DPU-specific DAG.
///
FunctionPass *llvm::createDPUISelDag(DPUTargetMachine &TM,
                                     CodeGenOpt::Level OptLevel) {
  return new DPUDAGToDAGISel(TM, OptLevel);
}
