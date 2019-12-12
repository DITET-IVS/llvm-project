//===-- DpuContext.cpp ---------------------------------------- -*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "DpuContext.h"

// C Includes
#include <errno.h>
#include <stdint.h>
#include <string.h>
#include <unistd.h>

// C++ Includes
#include <mutex>
#include <string>

// Other libraries and framework includes
#include "lldb/Core/Module.h"
#include "lldb/Core/Section.h"
#include "lldb/Symbol/ObjectFile.h"

#include "RegisterContextDpu.h"

extern "C" {
#include <dpu.h>
}

using namespace lldb;
using namespace lldb_private;
using namespace lldb_private::dpu;

// -----------------------------------------------------------------------------
// DPU context handling
// -----------------------------------------------------------------------------

DpuContext::DpuContext(dpu_t *dpu, struct _dpu_context_t *context,
                       uint32_t _nr_threads)
    : m_dpu(dpu), m_context(context), nr_threads(_nr_threads) {
  running_threads = new uint8_t[nr_threads];
  last_resume_threads = new uint8_t[nr_threads];
  for (unsigned int each_thread = 0; each_thread < nr_threads; each_thread++) {
    running_threads[each_thread] = 0xff;
    last_resume_threads[each_thread] = 0xff;
  }
  running_threads[0] = 0;
}

DpuContext::~DpuContext() {
  dpu_free_dpu_context(m_context);
  delete running_threads;
  delete last_resume_threads;
}

struct _dpu_context_t *DpuContext::Get() {
  return m_context;
}

void DpuContext::UpdateContext(struct _dpu_context_t *new_context) {
  dpu_free_dpu_context(m_context);
  m_context = new_context;
}

bool DpuContext::StopThreads() {
  ResetScheduling();

  m_context->bkp_fault = false;
  m_context->dma_fault = false;
  m_context->mem_fault = false;

  int ret = DPU_API_SUCCESS;
  ret = dpu_initialize_fault_process_for_dpu(m_dpu, m_context);
  if (ret != DPU_API_SUCCESS)
    return false;
  ret = dpu_extract_context_for_dpu(m_dpu, m_context);

  for (unsigned int each_thread = 0; each_thread < nr_threads; each_thread++) {
    if ((m_context->scheduling[each_thread] == 0xff) !=
        (last_resume_threads[each_thread] == 0xff)) {
      running_threads[each_thread] = m_context->scheduling[each_thread];
    }
  }

  return ret == DPU_API_SUCCESS;
}

bool DpuContext::ResumeThreads(llvm::SmallVector<uint32_t, 8> *resume_list) {
  ResetScheduling();

  if (resume_list == NULL) {
    for (unsigned int each_thread = 0; each_thread < nr_threads;
         each_thread++) {
      if (!AddThreadInScheduling(each_thread)) {
        return false;
      }
    }
  } else {
    for (auto thread_id : *resume_list) {
      if (running_threads[thread_id] != 0xff) {
        if (!AddThreadInScheduling(thread_id))
          return false;
      }
    }
  }

  memcpy(last_resume_threads, m_context->scheduling,
         nr_threads * sizeof(uint8_t));

  return dpu_finalize_fault_process_for_dpu(m_dpu, m_context) ==
         DPU_API_SUCCESS;
}

dpu_api_status_t DpuContext::StepThread(uint32_t thread_index) {
  dpu_api_status_t ret =
      dpu_execute_thread_step_in_fault_for_dpu(m_dpu, thread_index, m_context);
  if (ret != DPU_API_SUCCESS)
    return ret;
  return dpu_extract_context_for_dpu(m_dpu, m_context);
}

unsigned int DpuContext::GetExitStatus() {
  return m_context->registers[lldb_private::r0_dpu];
}

lldb::addr_t DpuContext::GetPcOfThread(dpu_thread_t thread) {
  return InstIdx2InstAddr(m_context->pcs[thread]);
}

bool DpuContext::ScheduledThread(uint32_t thread) {
  return running_threads[thread] != 0xff;
}

bool DpuContext::ContextReadyForResumeOrStep() {
  m_context->bkp_fault = false;
  return !(m_context->dma_fault || m_context->mem_fault);
}

bool DpuContext::AddThreadInScheduling(unsigned int thread) {
  if (m_context->nr_of_running_threads >= nr_threads)
    return false;

  m_context->scheduling[thread] = m_context->nr_of_running_threads;
  m_context->nr_of_running_threads++;
  return true;
}

void DpuContext::ResetScheduling() {
  m_context->nr_of_running_threads = 0;
  for (dpu_thread_t each_thread = 0; each_thread < nr_threads; ++each_thread) {
    m_context->scheduling[each_thread] = 0xff;
  }
}
