set(LLDB_PLUGINS)

if(CMAKE_SYSTEM_NAME MATCHES "Linux|Android")
  list(APPEND LLDB_PLUGINS lldbPluginProcessLinux)
endif()

if(CMAKE_SYSTEM_NAME MATCHES "NetBSD")
  list(APPEND LLDB_PLUGINS lldbPluginProcessNetBSD)
endif()

if(CMAKE_SYSTEM_NAME MATCHES "Darwin")
  list(APPEND LLDB_PLUGINS lldbPluginObjectFileMachO)
elseif(CMAKE_SYSTEM_NAME MATCHES "Windows")
  list(APPEND LLDB_PLUGINS lldbPluginObjectFilePECOFF)
else()
  list(APPEND LLDB_PLUGINS lldbPluginObjectFileELF)
endif()

if(IOS)
  if(LLDB_CODESIGN_IDENTITY)
    # Use explicit LLDB identity
    set(LLVM_CODESIGNING_IDENTITY ${LLDB_CODESIGN_IDENTITY})
  else()
    # Use explicit LLVM identity or default to lldb_codesign if empty
    if(NOT LLVM_CODESIGNING_IDENTITY)
      set(LLVM_CODESIGNING_IDENTITY lldb_codesign)
    endif()
  endif()
endif()

add_lldb_tool(lldb-server
    Acceptor.cpp
    lldb-gdbserver.cpp
    lldb-platform.cpp
    lldb-server.cpp
    LLDBServerUtilities.cpp
    SystemInitializerLLGS.cpp

    LINK_LIBS
      lldbBase
      lldbHost
      lldbInitialization
      ${LLDB_PLUGINS}
      lldbPluginInstructionARM
      lldbPluginInstructionMIPS
      lldbPluginInstructionMIPS64
      ${LLDB_SYSTEM_LIBS}

    LINK_COMPONENTS
      Support
)

target_include_directories(lldb-server PRIVATE "${LLDB_SOURCE_DIR}/source")
target_link_libraries(lldb-server PRIVATE ${LLDB_SYSTEM_LIBS})


if(HAVE_LIBDPU)
# Specialized lldb-server for DPU targets

link_directories(${UPMEM_API_LIB})
set(LLDB_PLUGINS)

list(APPEND LLDB_PLUGINS lldbPluginProcessDpu)
list(APPEND LLDB_PLUGINS lldbPluginObjectFileELF)

add_lldb_tool(lldb-server-dpu
    Acceptor.cpp
    lldb-gdbserver.cpp
    lldb-platform.cpp
    lldb-server.cpp
    LLDBServerUtilities.cpp
    SystemInitializerLLGS.cpp

    LINK_LIBS
      lldbBase
      lldbHostDpu
      lldbInitialization
      ${LLDB_PLUGINS}
      ${LLDB_SYSTEM_LIBS}

    LINK_COMPONENTS
      Support
)

target_include_directories(lldb-server-dpu PRIVATE "${LLDB_SOURCE_DIR}/source")
target_link_libraries(lldb-server-dpu PRIVATE ${LLDB_SYSTEM_LIBS} "dpu" "dpuverbose")
set_property(TARGET lldb-server-dpu APPEND_STRING PROPERTY LINK_FLAGS " -Wl,--enable-new-dtags")
target_compile_options(lldb-server-dpu PRIVATE -DUSE_DPU)
endif()
