//===-- DPURegisterInfo.td - DPU Register defs -------------*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
//  Description of the DPU instructions.
//===----------------------------------------------------------------------===//

def SDT_DPUSetCC        : SDTypeProfile<1, 3, []>;
def DPUSetCC            : SDNode<"DPUISD::SetCC", SDT_DPUSetCC, [SDNPInGlue]>;

// Same as a standard brcc except that the first item is an integer.
def SDT_DPUBrCC         : SDTypeProfile<0, 4, [SDTCisInt<0>, SDTCisSameAs<1, 2>, SDTCisVT<3, OtherVT>]>;
def DPUBrCC             : SDNode<"DPUISD::BrCC", SDT_DPUBrCC, [SDNPHasChain]>;
def DPUBrCCi            : SDNode<"DPUISD::BrCCi", SDT_DPUBrCC, [SDNPHasChain]>;

def SDT_COUNT           : SDTypeProfile<1, 1, [ SDTCisInt<0>, SDTCisInt<1> ]>;
def SDT_Clo             : SDNode<"DPUISD::Clo", SDT_COUNT, [SDNPHasChain]>;
def SDT_Cls             : SDNode<"DPUISD::Cls", SDT_COUNT, [SDNPHasChain]>;

def SDT_SHIFT : SDTypeProfile<1, 2, [ SDTCisInt<0>, SDTCisInt<1>, SDTCisInt<2> ]>;
def SDT_Lslx            : SDNode<"DPUISD::Lslx" , SDT_SHIFT, [SDNPHasChain]>;
def SDT_Lsl1            : SDNode<"DPUISD::Lsl1" , SDT_SHIFT, [SDNPHasChain]>;
def SDT_Lsl1x           : SDNode<"DPUISD::Lsl1x", SDT_SHIFT, [SDNPHasChain]>;
def SDT_Lsrx            : SDNode<"DPUISD::Lsrx" , SDT_SHIFT, [SDNPHasChain]>;
def SDT_Lsr1            : SDNode<"DPUISD::Lsr1" , SDT_SHIFT, [SDNPHasChain]>;
def SDT_Lsr1x           : SDNode<"DPUISD::Lsr1x", SDT_SHIFT, [SDNPHasChain]>;

def SDT_SHIFT_ADD : SDTypeProfile<1, 3, [SDTCisInt<0>, SDTCisInt<1>, SDTCisInt<2>, SDTCisInt<3>]>;
def SDT_Lsl_add         : SDNode<"DPUISD::LslAdd", SDT_SHIFT_ADD, []>;

def SDT_Mul8            : SDTypeProfile<1, 2, [SDTCisSameAs<1, 2>]>;
def SDT_Mul8UU          : SDNode<"DPUISD::MUL8_UU", SDT_Mul8, [SDNPInGlue]>;
def SDT_Mul8SU          : SDNode<"DPUISD::MUL8_SU", SDT_Mul8, [SDNPInGlue]>;
def SDT_Mul8SS          : SDNode<"DPUISD::MUL8_SS", SDT_Mul8, [SDNPInGlue]>;

def SDT_DPUMul16         : SDTypeProfile<1, 2, [SDTCisSameAs<1, 2>]>;
def DPUMul16UU           : SDNode<"DPUISD::MUL16_UU", SDT_DPUMul16, [SDNPInGlue]>;
def DPUMul16SU           : SDNode<"DPUISD::MUL16_SU", SDT_DPUMul16, [SDNPInGlue]>;
def DPUMul16SS           : SDNode<"DPUISD::MUL16_SS", SDT_DPUMul16, [SDNPInGlue]>;

def SDT_DPUCallSeqStart : SDCallSeqStart<[SDTCisVT<0, i16>, SDTCisVT<1, i16>]>;
def SDT_DPUCallSeqEnd   : SDCallSeqEnd<[SDTCisVT<0, i16>, SDTCisVT<1, i16>]>;
def SDT_DPUCall         : SDTypeProfile<0, -1, [SDTCisVT<0, iPTR>]>;

def DPUretflag          : SDNode<"DPUISD::RET_FLAG", SDTNone, [SDNPHasChain, SDNPOptInGlue, SDNPVariadic]>;
def DPUcallseq_start    : SDNode<"ISD::CALLSEQ_START", SDT_DPUCallSeqStart, [SDNPHasChain, SDNPOutGlue]>;
def DPUcallseq_end      : SDNode<"ISD::CALLSEQ_END",   SDT_DPUCallSeqEnd, [SDNPHasChain, SDNPOptInGlue, SDNPOutGlue]>;

def DPUcall             : SDNode<"DPUISD::CALL", SDT_DPUCall, [SDNPHasChain, SDNPOptInGlue, SDNPOutGlue, SDNPVariadic]>;

def SDT_DMA  : SDTypeProfile<0, 3, [SDTCisInt<2>, SDTCisVT<0, iPTR>, SDTCisVT<1, iPTR>]>;
def SDT_Ldma : SDNode<"DPUISD::LDMA", SDT_DMA, [SDNPHasChain]>;
def SDT_Sdma : SDNode<"DPUISD::SDMA", SDT_DMA, [SDNPHasChain]>;

def SDT_SEQREAD_GET : SDTypeProfile<1, 5, [SDTCisInt<0>, SDTCisInt<1>, SDTCisVT<2, iPTR>, SDTCisInt<3>, SDTCisInt<4>]>;
def DPUSeqreadGet : SDNode<"DPUISD::SEQREAD_GET", SDT_SEQREAD_GET, [SDNPHasChain]>;
def DPUSeqreadGetCst : SDNode<"DPUISD::SEQREAD_GET_CST", SDT_SEQREAD_GET, [SDNPHasChain]>;

// To promote special types of operands to registers (see the patterns below).
def SDTDPUWrapper       : SDTypeProfile<1, 1, [SDTCisSameAs<0, 1>, SDTCisPtrTy<0>]>;
def DPUWrapper          : SDNode<"DPUISD::Wrapper", SDTDPUWrapper>;

def SDT_DPUAddVAStart   : SDTypeProfile<1, 1, [SDTCisPtrTy<0>]>;
def DPUAddVAStart       : SDNode<"DPUISD::ADD_VASTART", SDT_DPUAddVAStart>;

def SDT_DPULoadBig : SDTypeProfile<1, 1, [SDTCisPtrTy<0>]>;
def DPULhuBig : SDNode <"DPUISD::LHU_BIG", SDT_DPULoadBig, [SDNPHasChain, SDNPMayLoad]>;
def DPULhsBig : SDNode <"DPUISD::LHS_BIG", SDT_DPULoadBig, [SDNPHasChain, SDNPMayLoad]>;
def DPULwBig : SDNode <"DPUISD::LW_BIG", SDT_DPULoadBig, [SDNPHasChain, SDNPMayLoad]>;
def DPULdBig : SDNode <"DPUISD::LD_BIG", SDT_DPULoadBig, [SDNPHasChain, SDNPMayLoad]>;

include "DPUInstrFormats.td"

let usesCustomInserter = 1 in {
def SEQREAD_GET: PseudoDPUInstruction<
    (outs SimpleReg:$rc),
    (ins SimpleReg:$ptr, SimpleReg:$inc, SimpleReg:$reader, i32imm:$cc, i32imm:$pageSize),
    "",
    [(set i32:$rc, (DPUSeqreadGet i32:$ptr, i32:$inc, i32:$reader, (i32 imm:$cc), (i32 imm:$pageSize)))]>;

def SEQREAD_GET_CST: PseudoDPUInstruction<
    (outs SimpleReg:$rc),
    (ins SimpleReg:$ptr, s8_imm:$inc, SimpleReg:$reader, i32imm:$cc, i32imm:$pageSize),
    "",
    [(set i32:$rc, (DPUSeqreadGetCst i32:$ptr, (s8_imm:$inc), i32:$reader, (i32 imm:$cc), (i32 imm:$pageSize)))]>;
}

def ADD_VAStart: PseudoDPUInstruction<
                    (outs SimpleReg:$rc), (ins SimpleReg:$ra),
                    "",
                    [(set i32:$rc, (DPUAddVAStart i32:$ra))]>;

def : Pat<(trap), (FAULTi 4)>;

def : Pat<(SDT_Lsl_add SimpleReg:$rb, SimpleRegOrCst:$ra, u5_imm:$shift),
          (LSL_ADDrrri SimpleReg:$rb, SimpleRegOrCst:$ra, u5_imm:$shift)>;

// Necessary because a frameindex can't be matched directly in a pattern.
def AddrFI : ComplexPattern<iPTR, 1, "SelectAddrFI", [frameindex], []>;

def : Pat<(DPULhuBig AddrFI:$addr), (LHUerri 1, AddrFI:$addr, 0)>;
def : Pat<(DPULhsBig AddrFI:$addr), (LHSerri 1, AddrFI:$addr, 0)>;
def : Pat<(DPULwBig AddrFI:$addr), (LWerri 1, AddrFI:$addr, 0)>;
def : Pat<(DPULdBig AddrFI:$addr), (LDerri 1, AddrFI:$addr, 0)>;

// Inspects parent to determine whether an or instruction can be implemented as
// an add (i.e. whether we know overflow won't occur in the add).
def AddLikeOrOp : ComplexPattern<i32, 1, "SelectAddLikeOr", [],
                                 [SDNPWantParent]>;

def IsOrAdd: PatFrag<(ops node:$A, node:$B), (or node:$A, node:$B), [{
  return isOrEquivalentToAdd(N);
}]>;

class wram_load_frag<PatFrag base_load> : PatFrag<(ops node:$ptr), (base_load node:$ptr), [{
    return IsALoadFromAddrSpace(N, DPUADDR_SPACE::WRAM);
}]>;

class wram_store_frag<PatFrag base_store> : PatFrag<(ops node:$val, node:$ptr), (base_store node:$val, node:$ptr), [{
    return IsAStoreToAddrSpace(N, DPUADDR_SPACE::WRAM);
}]>;

def IsInImmediateSection: PatFrag<(ops node:$sym), (DPUWrapper node:$sym), [{
    return IsGlobalAddrInImmediateSection(N);
}]>;

multiclass WramLoadXPat<ImmOperand LdTy, PatFrag LoadOp, DPUInstruction Inst> {
  def : Pat<(LdTy (wram_load_frag<LoadOp> SimpleRegOrCst:$ra)), (Inst SimpleRegOrCst:$ra, 0)>;
  def : Pat<(LdTy (wram_load_frag<LoadOp> AddrFI:$ra)), (Inst AddrFI:$ra, 0)>;
  def : Pat<(LdTy (wram_load_frag<LoadOp> (DPUWrapper i32:$off))), (Inst ZERO, i32:$off)>;
  def : Pat<(LdTy (wram_load_frag<LoadOp> (add SimpleRegOrCst:$ra, s24_imm:$off))), (Inst SimpleRegOrCst:$ra, s24_imm:$off)>;
  def : Pat<(LdTy (wram_load_frag<LoadOp> (add SimpleRegOrCst:$ra, (DPUWrapper i32:$off)))), (Inst SimpleRegOrCst:$ra, i32:$off)>;
  def : Pat<(LdTy (wram_load_frag<LoadOp> (add AddrFI:$ra, s24_imm:$off))), (Inst AddrFI:$ra, s24_imm:$off)>;
  def : Pat<(LdTy (wram_load_frag<LoadOp> (add AddrFI:$ra, (DPUWrapper i32:$off)))), (Inst AddrFI:$ra, i32:$off)>;
  def : Pat<(LdTy (wram_load_frag<LoadOp> (IsOrAdd SimpleRegOrCst:$ra, s24_imm:$off))), (Inst SimpleRegOrCst:$ra, s24_imm:$off)>;
  def : Pat<(LdTy (wram_load_frag<LoadOp> (IsOrAdd SimpleRegOrCst:$ra, (DPUWrapper i32:$off)))), (Inst SimpleRegOrCst:$ra, i32:$off)>;
  def : Pat<(LdTy (wram_load_frag<LoadOp> (IsOrAdd AddrFI:$ra, s24_imm:$off))), (Inst AddrFI:$ra, s24_imm:$off)>;
  def : Pat<(LdTy (wram_load_frag<LoadOp> (IsOrAdd AddrFI:$ra, (DPUWrapper i32:$off)))), (Inst AddrFI:$ra, i32:$off)>;
}

multiclass WramLoadPat<PatFrag LoadOp, DPUInstruction Inst, DPUInstruction Inst64> {
    defm : WramLoadXPat<i32, LoadOp, Inst>;
    defm : WramLoadXPat<i64, LoadOp, Inst64>;
}

multiclass WramStorePat<PatFrag StoreOp, DPUInstruction Inst, RegisterClass StTy> {
  def : Pat<(wram_store_frag<StoreOp> StTy:$rb, SimpleRegOrCst:$ra), (Inst SimpleRegOrCst:$ra, 0, StTy:$rb)>;
  def : Pat<(wram_store_frag<StoreOp> StTy:$rb, AddrFI:$ra), (Inst AddrFI:$ra, 0, StTy:$rb)>;
  def : Pat<(wram_store_frag<StoreOp> StTy:$rb, (DPUWrapper i32:$off)), (Inst ZERO, i32:$off, StTy:$rb)>;
  def : Pat<(wram_store_frag<StoreOp> StTy:$rb, (add SimpleRegOrCst:$ra, s24_imm:$off)), (Inst SimpleRegOrCst:$ra, s24_imm:$off, StTy:$rb)>;
  def : Pat<(wram_store_frag<StoreOp> StTy:$rb, (add SimpleRegOrCst:$ra, (DPUWrapper i32:$off))), (Inst SimpleRegOrCst:$ra, i32:$off, StTy:$rb)>;
  def : Pat<(wram_store_frag<StoreOp> StTy:$rb, (add AddrFI:$ra, s24_imm:$off)), (Inst AddrFI:$ra, s24_imm:$off, StTy:$rb)>;
  def : Pat<(wram_store_frag<StoreOp> StTy:$rb, (add AddrFI:$ra, (DPUWrapper i32:$off))), (Inst AddrFI:$ra, i32:$off, StTy:$rb)>;
  def : Pat<(wram_store_frag<StoreOp> StTy:$rb, (IsOrAdd SimpleRegOrCst:$ra, s24_imm:$off)), (Inst SimpleRegOrCst:$ra, s24_imm:$off, StTy:$rb)>;
  def : Pat<(wram_store_frag<StoreOp> StTy:$rb, (IsOrAdd SimpleRegOrCst:$ra, (DPUWrapper i32:$off))), (Inst SimpleRegOrCst:$ra, i32:$off, StTy:$rb)>;
  def : Pat<(wram_store_frag<StoreOp> StTy:$rb, (IsOrAdd AddrFI:$ra, s24_imm:$off)), (Inst AddrFI:$ra, s24_imm:$off, StTy:$rb)>;
  def : Pat<(wram_store_frag<StoreOp> StTy:$rb, (IsOrAdd AddrFI:$ra, (DPUWrapper i32:$off))), (Inst AddrFI:$ra, i32:$off, StTy:$rb)>;
}

multiclass WramStoreSub64Pat<PatFrag StoreOp, DPUInstruction Inst> {
  def : Pat<(wram_store_frag<StoreOp> DoubleReg:$rb, SimpleRegOrCst:$ra), (Inst SimpleRegOrCst:$ra, 0, (EXTRACT_SUBREG DoubleReg:$rb, sub_32bit))>;
  def : Pat<(wram_store_frag<StoreOp> DoubleReg:$rb, AddrFI:$ra), (Inst AddrFI:$ra, 0, (EXTRACT_SUBREG DoubleReg:$rb, sub_32bit))>;
  def : Pat<(wram_store_frag<StoreOp> DoubleReg:$rb, (DPUWrapper i32:$off)), (Inst ZERO, i32:$off, (EXTRACT_SUBREG DoubleReg:$rb, sub_32bit))>;
  def : Pat<(wram_store_frag<StoreOp> DoubleReg:$rb, (add SimpleRegOrCst:$ra, s24_imm:$off)), (Inst SimpleRegOrCst:$ra, s24_imm:$off, (EXTRACT_SUBREG DoubleReg:$rb, sub_32bit))>;
  def : Pat<(wram_store_frag<StoreOp> DoubleReg:$rb, (add SimpleRegOrCst:$ra, (DPUWrapper i32:$off))), (Inst SimpleRegOrCst:$ra, i32:$off, (EXTRACT_SUBREG DoubleReg:$rb, sub_32bit))>;
  def : Pat<(wram_store_frag<StoreOp> DoubleReg:$rb, (add AddrFI:$ra, s24_imm:$off)), (Inst AddrFI:$ra, s24_imm:$off, (EXTRACT_SUBREG DoubleReg:$rb, sub_32bit))>;
  def : Pat<(wram_store_frag<StoreOp> DoubleReg:$rb, (add AddrFI:$ra, (DPUWrapper i32:$off))), (Inst AddrFI:$ra, i32:$off, (EXTRACT_SUBREG DoubleReg:$rb, sub_32bit))>;
  def : Pat<(wram_store_frag<StoreOp> DoubleReg:$rb, (IsOrAdd SimpleRegOrCst:$ra, s24_imm:$off)), (Inst SimpleRegOrCst:$ra, s24_imm:$off, (EXTRACT_SUBREG DoubleReg:$rb, sub_32bit))>;
  def : Pat<(wram_store_frag<StoreOp> DoubleReg:$rb, (IsOrAdd SimpleRegOrCst:$ra, (DPUWrapper i32:$off))), (Inst SimpleRegOrCst:$ra, i32:$off, (EXTRACT_SUBREG DoubleReg:$rb, sub_32bit))>;
  def : Pat<(wram_store_frag<StoreOp> DoubleReg:$rb, (IsOrAdd AddrFI:$ra, s24_imm:$off)), (Inst AddrFI:$ra, s24_imm:$off, (EXTRACT_SUBREG DoubleReg:$rb, sub_32bit))>;
  def : Pat<(wram_store_frag<StoreOp> DoubleReg:$rb, (IsOrAdd AddrFI:$ra, (DPUWrapper i32:$off))), (Inst AddrFI:$ra, i32:$off, (EXTRACT_SUBREG DoubleReg:$rb, sub_32bit))>;
}

multiclass WramStoreImmPat<PatFrag WramStoreImmOp, DPUInstruction Inst, ImmOperand StTy> {
  def : Pat<(wram_store_frag<WramStoreImmOp> (StTy:$imm), (IsInImmediateSection i32:$addr)), (Inst ZERO, i32:$addr, StTy:$imm)>;
  def : Pat<(wram_store_frag<WramStoreImmOp> (StTy:$imm), SimpleRegOrCst:$ra), (Inst SimpleRegOrCst:$ra, 0, StTy:$imm)>;
  def : Pat<(wram_store_frag<WramStoreImmOp> (StTy:$imm), AddrFI:$ra), (Inst AddrFI:$ra, 0, StTy:$imm)>;
  def : Pat<(wram_store_frag<WramStoreImmOp> (StTy:$imm), (add SimpleRegOrCst:$ra, (IsInImmediateSection i32:$off))), (Inst SimpleRegOrCst:$ra, i32:$off, StTy:$imm)>;
  def : Pat<(wram_store_frag<WramStoreImmOp> (StTy:$imm), (add SimpleRegOrCst:$ra, s12_imm:$off)), (Inst SimpleRegOrCst:$ra, s12_imm:$off, StTy:$imm)>;
  def : Pat<(wram_store_frag<WramStoreImmOp> (StTy:$imm), (add AddrFI:$ra, s12_imm:$off)), (Inst AddrFI:$ra, s12_imm:$off, StTy:$imm)>;
  def : Pat<(wram_store_frag<WramStoreImmOp> (StTy:$imm), (IsOrAdd SimpleRegOrCst:$ra, s12_imm:$off)), (Inst SimpleRegOrCst:$ra, s12_imm:$off, StTy:$imm)>;
  def : Pat<(wram_store_frag<WramStoreImmOp> (StTy:$imm), (IsOrAdd AddrFI:$ra, s12_imm:$off)), (Inst AddrFI:$ra, s12_imm:$off, StTy:$imm)>;
}

defm : WramLoadPat<zextloadi8, LBUrri, LBU_Urri>;
defm : WramLoadPat<sextloadi8, LBSrri, LBS_Srri>;
defm : WramLoadPat<extloadi8, LBSrri, LBS_Srri>;
defm : WramLoadPat<zextloadi16, LHUrri, LHU_Urri>;
defm : WramLoadPat<sextloadi16, LHSrri, LHS_Srri>;
defm : WramLoadPat<extloadi16, LHSrri, LHS_Srri>;
defm : WramLoadPat<load, LWrri, LDrri>;
defm : WramLoadXPat<i64, zextloadi32, LW_Urri>;
defm : WramLoadXPat<i64, sextloadi32, LW_Srri>;
defm : WramLoadXPat<i64, extloadi32, LW_Srri>;

defm : WramStorePat<truncstorei8, SBrir, SimpleReg>;
defm : WramStorePat<truncstorei16, SHrir, SimpleReg>;
defm : WramStorePat<store, SWrir, SimpleReg>;
defm : WramStorePat<store, SDrir, DoubleReg>;

defm : WramStoreSub64Pat<truncstorei8, SBrir>;
defm : WramStoreSub64Pat<truncstorei16, SHrir>;
defm : WramStoreSub64Pat<truncstorei32, SWrir>;

defm : WramStoreImmPat<truncstorei8, SBrii, su8_imm>;
defm : WramStoreImmPat<truncstorei16, SHrii, su16_imm>;
defm : WramStoreImmPat<store, SWrii, s16_imm>;
defm : WramStoreImmPat<store, SDrii, s16_i64_imm>;

// Special instructions for 64 bits emulation.

def : Pat<(i32 (trunc DoubleReg:$src)), (EXTRACT_SUBREG DoubleReg:$src, sub_32bit)>;

let isMoveImm = 1, isAsCheapAsAMove = 0 in {
  def MOVE64ri: PseudoDPUInstruction<
                    (outs GP64_REG:$dc), (ins i64imm:$imm),
                    "",
                    [(set i64:$dc, (i64 imm:$imm))]>;
}

let isAsCheapAsAMove = 0 in {
def ADD64rr: PseudoDPUInstruction<
                  (outs GP64_REG:$dc), (ins GP64_REG:$da, GP64_REG:$db),
                  "",
                  [(set i64:$dc, (add i64:$da, i64:$db))]>;

def ADD64ri: PseudoDPUInstruction<
                  (outs GP64_REG:$dc), (ins GP64_REG:$da, i64imm:$imm),
                  "",
                  [(set i64:$dc, (add i64:$da, (i64 imm:$imm)))]>;

def SUB64rr: PseudoDPUInstruction<
                  (outs GP64_REG:$dc), (ins GP64_REG:$da, GP64_REG:$db),
                  "",
                  [(set i64:$dc, (sub i64:$da, i64:$db))]>;

def OR64rr: PseudoDPUInstruction<
                  (outs GP64_REG:$dc), (ins GP64_REG:$da, GP64_REG:$db),
                  "",
                  [(set i64:$dc, (or i64:$da, i64:$db))]>;

def OR64ri: PseudoDPUInstruction<
                  (outs GP64_REG:$dc), (ins GP64_REG:$da, i64imm:$imm),
                  "",
                  [(set i64:$dc, (or i64:$da, (i64 imm:$imm)))]>;

def AND64rr: PseudoDPUInstruction<
                  (outs GP64_REG:$dc), (ins GP64_REG:$da, GP64_REG:$db),
                  "",
                  [(set i64:$dc, (and i64:$da, i64:$db))]>;

def AND64ri: PseudoDPUInstruction<
                  (outs GP64_REG:$dc), (ins GP64_REG:$da, i64imm:$imm),
                  "",
                  [(set i64:$dc, (and i64:$da, (i64 imm:$imm)))]>;

def XOR64rr: PseudoDPUInstruction<
                  (outs GP64_REG:$dc), (ins GP64_REG:$da, GP64_REG:$db),
                  "",
                  [(set i64:$dc, (xor i64:$da, i64:$db))]>;

def XOR64ri: PseudoDPUInstruction<
                  (outs GP64_REG:$dc), (ins GP64_REG:$da, i64imm:$imm),
                  "",
                  [(set i64:$dc, (xor i64:$da, (i64 imm:$imm)))]>;
}

// Bit operations: 64 bits emulation.
let isAsCheapAsAMove = 0, usesCustomInserter = 1 in {
def LSL64rr: PseudoDPUInstruction<
                  (outs GP64_REG:$dc), (ins GP64_REG:$da, GP_REG:$rb),
                  "",
                  [(set i64:$dc, (shl i64:$da, i32:$rb))]>;

def LSL64ri: PseudoDPUInstruction<
                  (outs GP64_REG:$dc), (ins GP64_REG:$da, i32imm:$imm),
                  "",
                  [(set i64:$dc, (shl i64:$da, (i32 imm:$imm)))]>;

def LSR64rr: PseudoDPUInstruction<
                  (outs GP64_REG:$dc), (ins GP64_REG:$da, GP_REG:$rb),
                  "",
                  [(set i64:$dc, (srl i64:$da, i32:$rb))]>;

def LSR64ri: PseudoDPUInstruction<
                  (outs GP64_REG:$dc), (ins GP64_REG:$da, i32imm:$imm),
                  "",
                  [(set i64:$dc, (srl i64:$da, (i32 imm:$imm)))]>;

def ASR64rr: PseudoDPUInstruction<
                  (outs GP64_REG:$dc), (ins GP64_REG:$da, GP_REG:$rb),
                  "",
                  [(set i64:$dc, (sra i64:$da, i32:$rb))]>;

def ASR64ri: PseudoDPUInstruction<
                  (outs GP64_REG:$dc), (ins GP64_REG:$da, i32imm:$imm),
                  "",
                  [(set i64:$dc, (sra i64:$da, (i32 imm:$imm)))]>;

def ROL64rr: PseudoDPUInstruction<
                  (outs GP64_REG:$dc), (ins GP64_REG:$da, GP_REG:$rb),
                  "",
                  [(set i64:$dc, (rotl i64:$da, i32:$rb))]>;

def ROL64ri: PseudoDPUInstruction<
                  (outs GP64_REG:$dc), (ins GP64_REG:$da, i32imm:$imm),
                  "",
                  [(set i64:$dc, (rotl i64:$da, (i32 imm:$imm)))]>;

def ROR64rr: PseudoDPUInstruction<
                  (outs GP64_REG:$dc), (ins GP64_REG:$da, GP_REG:$rb),
                  "",
                  [(set i64:$dc, (rotr i64:$da, i32:$rb))]>;

def ROR64ri: PseudoDPUInstruction<
                  (outs GP64_REG:$dc), (ins GP64_REG:$da, i32imm:$imm),
                  "",
                  [(set i64:$dc, (rotr i64:$da, (i32 imm:$imm)))]>;

def CLZ64r: PseudoDPUInstruction<
                  (outs GP64_REG:$dc), (ins GP64_REG:$da),
                  "",
                  [(set i64:$dc, (ctlz i64:$da))]>;
}

def : Pat<(or (i32 AddLikeOrOp:$rb), (shl i32:$ra, (i32 imm:$imm))), (LSL_ADDrrri i32:$rb, i32:$ra, (i32 imm:$imm))>;

def : Pat<(i32 (trunc (srl i64:$src, (i32 32)))), (EXTRACT_SUBREG DoubleReg:$src, sub_32bit_hi)>;

def : Pat<(sext_inreg DoubleReg:$src,  i8), (EXTSB_Srr (EXTRACT_SUBREG DoubleReg:$src, sub_32bit))>;
def : Pat<(sext_inreg DoubleReg:$src, i16), (EXTSH_Srr (EXTRACT_SUBREG DoubleReg:$src, sub_32bit))>;
def : Pat<(sext_inreg DoubleReg:$src, i32), (MOVE_Srr  (EXTRACT_SUBREG DoubleReg:$src, sub_32bit))>;

def : Pat<(anyext SimpleRegOrCst:$ra), (MOVE_Srr SimpleRegOrCst:$ra)>;
def : Pat<(ctpop DoubleReg:$src), (ADD_Urrr (CAOrr (EXTRACT_SUBREG DoubleReg:$src, sub_32bit)), (CAOrr (EXTRACT_SUBREG DoubleReg:$src, sub_32bit_hi)))>;

let isAsCheapAsAMove = 0, usesCustomInserter = 1 in {
def Mul16UUrr: PseudoDPUInstruction<
                   (outs GP_REG:$rc), (ins GP_REG:$ra, GP_REG:$rb),
                   "",
                   [(set i32:$rc, (DPUMul16UU i32:$ra, i32:$rb))]
                   >;

def Mul16SUrr: PseudoDPUInstruction<
                   (outs GP_REG:$rc), (ins GP_REG:$ra, GP_REG:$rb),
                   "",
                   [(set i32:$rc, (DPUMul16SU i32:$ra, i32:$rb))]
                   >;

def Mul16SSrr: PseudoDPUInstruction<
                   (outs GP_REG:$rc), (ins GP_REG:$ra, GP_REG:$rb),
                   "",
                   [(set i32:$rc, (DPUMul16SS i32:$ra, i32:$rb))]
                   >;
}

// -----------------------------------------------------------------------------
// SELECT
// -----------------------------------------------------------------------------

let usesCustomInserter = 1 in {
def SELECTrr: PseudoDPUInstruction<
                (outs GP_REG:$rc), (ins GP_REG:$ccreg, GP_REG:$t, GP_REG:$f),
                "",
                [(set i32:$rc, (select i32:$ccreg, i32:$t, i32:$f))]>;

def SELECT64rr: PseudoDPUInstruction<
                (outs GP64_REG:$rc), (ins GP_REG:$ccreg, GP64_REG:$t, GP64_REG:$f),
                "",
                [(set i64:$rc, (select i32:$ccreg, i64:$t, i64:$f))]>;
}

// -----------------------------------------------------------------------------
// STACK
// -----------------------------------------------------------------------------


let isReturn=1, isTerminator = 1, isBarrier = 1, Uses = [R23] in {
    def RETi: PseudoDPUInstruction<(outs), (ins), "", [(DPUretflag)]>;
}

// Stack adjustments will not be generated... Instead, we update the stack pointer
// as if it was a frame pointer, by substituting these fake instructions.
// See DPUFrameLowering.cpp::eliminateCallFramePseudoInstr.
let Uses = [R23], hasSideEffects = 1, isCodeGenOnly = 1 in {
  def ADJCALLSTACKDOWN : PseudoDPUInstruction<(outs), (ins i16imm:$amt1, i16imm:$amt2),
                                "// ADJCALLSTACKDOWN $amt1 $amt2",
                                [(DPUcallseq_start i16:$amt1, i16:$amt2)]>;
  def ADJCALLSTACKUP   : PseudoDPUInstruction<(outs), (ins i16imm:$amt1, i16imm:$amt2),
                                "// ADJCALLSTACKUP $amt1 @$amt2",
                                [(DPUcallseq_end i16:$amt1, i16:$amt2)]>;
}

// -----------------------------------------------------------------------------
// CONDITIONAL JUMP
// -----------------------------------------------------------------------------

// Operand for printing out a condition code.
def ccopcode : Operand<i32> {
  let PrintMethod = "printCCOperand";
}

// Short jump targets have OtherVT type and are printed as pcrel imm values.
def pcoffset : Operand<OtherVT> {
  let PrintMethod = "printPCOffsetOperand";
}

// Jump and save PC
// An invocation to call allows to save the current PC position in an arbitrary
// register.
let isCall=1, hasDelaySlot=0, Defs = [R23]
    in {
      def CALLi : PseudoDPUInstruction<
                  (outs), (ins i32imm:$addr),
                  "",
                  // Note: not linked to DPUcall here, because we wrap
                  // this in different patterns (see below).
                  []
      >;
      def CALLr : PseudoDPUInstruction<
                  (outs), (ins GP_REG:$addr),
                  "",
                  // Note: not linked to DPUcall here, because we wrap
                  // this in different patterns (see below).
                  []
      >;
}

def : Pat<(DPUcall tglobaladdr:$dst), (CALLi tglobaladdr:$dst)>;
def : Pat<(DPUcall texternalsym:$dst), (CALLi texternalsym:$dst)>;
def : Pat<(DPUcall imm:$dst), (CALLi imm:$dst)>;
def : Pat<(DPUcall GP_REG:$addr), (CALLr GP_REG:$addr) >;

let isBranch = 1, isTerminator = 1, isCompare = 1, isBarrier = 0, isIndirectBranch = 0, isAsCheapAsAMove = 1 in {
// DPUTargetLowering::LowerSetCc traps br_cc instructions to map the condition
// as a 32-bits immediate, forwarded as DPUISD::SetCC.
// The condition is handled by DPUInstPrinter::printCcOperand, which translates
// the value (a ISDOpcodes::CondCode) to the proper instruction string.
def Jcc: PseudoDPUInstruction<
                (outs), (ins ccopcode:$cc, OP_REG:$ra, GP_REG:$rb, pcoffset:$dst),
                "",
                [(DPUBrCC (i32 imm:$cc), i32:$ra, i32:$rb, bb:$dst)]
                >;

def Jcci: PseudoDPUInstruction<
                (outs), (ins ccopcode:$cc, OP_REG:$ra, s11_imm:$immediate, pcoffset:$dst),
                "",
                [(DPUBrCCi (i32 imm:$cc), i32:$ra, (s11_imm:$immediate), bb:$dst)]
                >;

def TmpJcci: PseudoDPUInstruction<
                (outs), (ins ccopcode:$cc, OP_REG:$ra, s11_imm:$immediate, GP_REG:$dependency, pcoffset:$dst),
                "",
                []
                >;
}

let isBranch = 1, isTerminator = 1, isCompare = 1, isBarrier = 0, isIndirectBranch = 0, isAsCheapAsAMove = 0 in {
def Jcc64: PseudoDPUInstruction<
                (outs), (ins ccopcode:$cc, GP64_REG:$da, GP64_REG:$db, pcoffset:$dst),
                "",
                [(DPUBrCC (i32 imm:$cc), i64:$da, i64:$db, bb:$dst)]
                >;
}

// -----------------------------------------------------------------------------
// SETCC
// -----------------------------------------------------------------------------

let isAsCheapAsAMove = 0 in {
def SET64cc: PseudoDPUInstruction<
                    (outs GP_REG:$rc), (ins ccopcode:$cc, GP64_REG:$lhs, GP64_REG:$rhs),
                    "",
                    [(set i32:$rc, (DPUSetCC (i32 imm:$cc), i64:$lhs, i64:$rhs))]>;
}

// Addressing modes.
def ADDRESS_IN_STACK: ComplexPattern<i32, 2, "SelectAddr", [frameindex], []>;

def addr : ComplexPattern<iPTR, 2, "SelectAddr", [], []>;

def MEMri24 : Operand<i32> {
  let PrintMethod = "printMemOperandWithImm24";
  let EncoderMethod = "getMemoryOpValue";
  let MIOperandInfo = (ops OP_REG, i32imm);
}

// See DPUTargetLowering.cpp // LowerOperation
// Promote ConstantPool, GlobalAddress, ExternalSymbol, JumpTable... to immediate into
// a register.
def : Pat<(i32 (DPUWrapper tconstpool  :$dst)), (MOVEri tconstpool  :$dst)>;
def : Pat<(i32 (DPUWrapper tjumptable  :$dst)), (MOVEri tjumptable  :$dst)>;
def : Pat<(i32 (DPUWrapper tglobaltlsaddr:$dst)),(MOVEri tglobaltlsaddr:$dst)>;
def : Pat<(i32 (DPUWrapper tglobaladdr :$dst)), (MOVEri tglobaladdr :$dst)>;
def : Pat<(i32 (DPUWrapper texternalsym:$dst)), (MOVEri texternalsym:$dst)>;
def : Pat<(i32 (DPUWrapper tblockaddress:$dst)), (MOVEri tblockaddress:$dst)>;

//===----------------------------------------------------------------------===//
// Software cache instructions
//===----------------------------------------------------------------------===//
def mram_load : PatFrag<(ops node:$ptr), (unindexedload node:$ptr), [{
  return (cast<LoadSDNode>(N)->getExtensionType() == ISD::NON_EXTLOAD) && IsALoadFromAddrSpace(N, DPUADDR_SPACE::MRAM);
}]>;

def mram_extload : PatFrag<(ops node:$ptr), (unindexedload node:$ptr), [{
  return (cast<LoadSDNode>(N)->getExtensionType() == ISD::EXTLOAD) && IsALoadFromAddrSpace(N, DPUADDR_SPACE::MRAM);
}]>;

def mram_zextload : PatFrag<(ops node:$ptr), (unindexedload node:$ptr), [{
  return (cast<LoadSDNode>(N)->getExtensionType() == ISD::ZEXTLOAD) && IsALoadFromAddrSpace(N, DPUADDR_SPACE::MRAM);
}]>;

def mram_sextload : PatFrag<(ops node:$ptr), (unindexedload node:$ptr), [{
  return (cast<LoadSDNode>(N)->getExtensionType() == ISD::SEXTLOAD) && IsALoadFromAddrSpace(N, DPUADDR_SPACE::MRAM);
}]>;

def mram_extloadi8  : PatFrag<(ops node:$ptr), (mram_extload node:$ptr), [{
  return cast<LoadSDNode>(N)->getMemoryVT() == MVT::i8;
}]>;

def mram_extloadi16  : PatFrag<(ops node:$ptr), (mram_extload node:$ptr), [{
  return cast<LoadSDNode>(N)->getMemoryVT() == MVT::i16;
}]>;

def mram_extloadi32 : PatFrag<(ops node:$ptr), (mram_extload node:$ptr), [{
  return cast<LoadSDNode>(N)->getMemoryVT() == MVT::i32;
}]>;

def mram_sextloadi8  : PatFrag<(ops node:$ptr), (mram_sextload node:$ptr), [{
  return cast<LoadSDNode>(N)->getMemoryVT() == MVT::i8;
}]>;

def mram_sextloadi16  : PatFrag<(ops node:$ptr), (mram_sextload node:$ptr), [{
  return cast<LoadSDNode>(N)->getMemoryVT() == MVT::i16;
}]>;

def mram_sextloadi32 : PatFrag<(ops node:$ptr), (mram_sextload node:$ptr), [{
  return cast<LoadSDNode>(N)->getMemoryVT() == MVT::i32;
}]>;

def mram_zextloadi8  : PatFrag<(ops node:$ptr), (mram_zextload node:$ptr), [{
  return cast<LoadSDNode>(N)->getMemoryVT() == MVT::i8;
}]>;

def mram_zextloadi16  : PatFrag<(ops node:$ptr), (mram_zextload node:$ptr), [{
  return cast<LoadSDNode>(N)->getMemoryVT() == MVT::i16;
}]>;

def mram_zextloadi32 : PatFrag<(ops node:$ptr), (mram_zextload node:$ptr), [{
  return cast<LoadSDNode>(N)->getMemoryVT() == MVT::i32;
}]>;

def mram_store : PatFrag<(ops node:$val, node:$ptr),
                    (unindexedstore node:$val, node:$ptr), [{
  return !cast<StoreSDNode>(N)->isTruncatingStore() && IsAStoreToAddrSpace(N, (unsigned int) DPUADDR_SPACE::MRAM);
}]>;

def mram_truncstorei8 : PatFrag<(ops node:$val, node:$ptr),
                    (unindexedstore node:$val, node:$ptr), [{
  return cast<StoreSDNode>(N)->isTruncatingStore() &&
          (cast<StoreSDNode>(N)->getMemoryVT() == MVT::i8) &&
          IsAStoreToAddrSpace(N, (unsigned int) DPUADDR_SPACE::MRAM);
}]>;

def mram_truncstorei16 : PatFrag<(ops node:$val, node:$ptr),
                    (unindexedstore node:$val, node:$ptr), [{
  return cast<StoreSDNode>(N)->isTruncatingStore() &&
            (cast<StoreSDNode>(N)->getMemoryVT() == MVT::i16) &&
            IsAStoreToAddrSpace(N, (unsigned int) DPUADDR_SPACE::MRAM);
}]>;

def mram_truncstorei32 : PatFrag<(ops node:$val, node:$ptr),
                    (unindexedstore node:$val, node:$ptr), [{
  return cast<StoreSDNode>(N)->isTruncatingStore() &&
            (cast<StoreSDNode>(N)->getMemoryVT() == MVT::i32) &&
            IsAStoreToAddrSpace(N, (unsigned int) DPUADDR_SPACE::MRAM);
}]>;

let usesCustomInserter = 1 in {
    class MRAM_STORE_X_rm<PatFrag OpNode> : PseudoDPUInstruction<
                      (outs), (ins GP_REG:$rb, MEMri24:$addr),
                      "",
                      [(OpNode i32:$rb, ADDRESS_IN_STACK:$addr)]>;

    class MRAM_STORE64_X_rm<PatFrag OpNode> : PseudoDPUInstruction<
                      (outs), (ins GP64_REG:$rb, MEMri24:$addr),
                      "",
                      [(OpNode i64:$rb, ADDRESS_IN_STACK:$addr)]>;

    class MRAM_LOAD_X_mr<PatFrag OpNode> : PseudoDPUInstruction<
                      (outs GP_REG:$rc), (ins MEMri24:$addr),
                      "",
                      [(set i32:$rc, (OpNode ADDRESS_IN_STACK:$addr))]>;

    class MRAM_LOAD64_X_mr<PatFrag OpNode> : PseudoDPUInstruction<
                      (outs GP64_REG:$dc), (ins MEMri24:$addr),
                      "",
                      [(set i64:$dc, (OpNode ADDRESS_IN_STACK:$addr))]>;

    def MRAM_STORErm      : MRAM_STORE_X_rm<mram_store>;
    def MRAM_STORE_BYTErm : MRAM_STORE_X_rm<mram_truncstorei8>;
    def MRAM_STORE_HALFrm : MRAM_STORE_X_rm<mram_truncstorei16>;
    def MRAM_STORE_WORDrm : MRAM_STORE_X_rm<mram_truncstorei32>;
    def MRAM_STORE64_BYTErm : MRAM_STORE64_X_rm<mram_truncstorei8>;
    def MRAM_STORE64_HALFrm : MRAM_STORE64_X_rm<mram_truncstorei16>;
    def MRAM_STORE64_WORDrm : MRAM_STORE64_X_rm<mram_truncstorei32>;

    def MRAM_STORE_DOUBLErm: PseudoDPUInstruction<
                      (outs), (ins GP64_REG:$db, MEMri24:$addr),
                      "",
                      [(mram_store i64:$db, ADDRESS_IN_STACK:$addr)]
                      >;

    def MRAM_LOADmr     : MRAM_LOAD_X_mr<mram_load>;

    def MRAM_LOAD_U8mr  : MRAM_LOAD_X_mr<mram_zextloadi8>;
    def MRAM_LOAD_U16mr : MRAM_LOAD_X_mr<mram_zextloadi16>;
    def MRAM_LOAD_U32mr : MRAM_LOAD_X_mr<mram_zextloadi32>;

    def MRAM_LOAD_S8mr  : MRAM_LOAD_X_mr<mram_sextloadi8>;
    def MRAM_LOAD_S16mr : MRAM_LOAD_X_mr<mram_sextloadi16>;
    def MRAM_LOAD_S32mr : MRAM_LOAD_X_mr<mram_sextloadi32>;

    // Notice that this applies to "anyext from iXX, where XX is 8 or 16"
    def MRAM_LOAD_X8mr  : MRAM_LOAD_X_mr<mram_extloadi8>;
    def MRAM_LOAD_X16mr : MRAM_LOAD_X_mr<mram_extloadi16>;

    def MRAM_LOAD64_U8mr  : MRAM_LOAD64_X_mr<mram_zextloadi8>;
    def MRAM_LOAD64_U16mr : MRAM_LOAD64_X_mr<mram_zextloadi16>;
    def MRAM_LOAD64_U32mr : MRAM_LOAD64_X_mr<mram_zextloadi32>;
    def MRAM_LOAD64_S8mr  : MRAM_LOAD64_X_mr<mram_sextloadi8>;
    def MRAM_LOAD64_S16mr : MRAM_LOAD64_X_mr<mram_sextloadi16>;
    def MRAM_LOAD64_S32mr : MRAM_LOAD64_X_mr<mram_sextloadi32>;
    def MRAM_LOAD64_X8mr  : MRAM_LOAD64_X_mr<mram_extloadi8>;
    def MRAM_LOAD64_X16mr : MRAM_LOAD64_X_mr<mram_extloadi16>;
    def MRAM_LOAD64_X32mr : MRAM_LOAD64_X_mr<mram_extloadi32>;
    def MRAM_LOAD_DOUBLEmr: MRAM_LOAD64_X_mr<mram_load>;
}
