include_guard(GLOBAL)

macro(ZQF_CEF_PREBUILT_STARTUP)
  option(USE_ATL OFF)
  option(USE_SANDBOX OFF)

  if(NOT DEFINED PROJECT_ARCH)
    if(APPLE AND CMAKE_OSX_ARCHITECTURES)
      set(_zqf_cef_target_arch "${CMAKE_OSX_ARCHITECTURES}")
    elseif(CMAKE_CXX_COMPILER_ARCHITECTURE_ID)
      set(_zqf_cef_target_arch "${CMAKE_CXX_COMPILER_ARCHITECTURE_ID}")
    elseif(CMAKE_CXX_COMPILER_TARGET)
      set(_zqf_cef_target_arch "${CMAKE_CXX_COMPILER_TARGET}")
    elseif(CMAKE_SYSTEM_PROCESSOR)
      set(_zqf_cef_target_arch "${CMAKE_SYSTEM_PROCESSOR}")
    else()
      message(FATAL_ERROR "Unable to determine the CEF target architecture")
    endif()

    string(TOLOWER "${_zqf_cef_target_arch}" _zqf_cef_target_arch)

    if(_zqf_cef_target_arch MATCHES "^(x64|x86_64|amd64)(-|$)")
      set(PROJECT_ARCH "x86_64")
    elseif(_zqf_cef_target_arch MATCHES "^(x86|win32|i[3-6]86)(-|$)")
      set(PROJECT_ARCH "x86")
    elseif(_zqf_cef_target_arch MATCHES "^(arm64|aarch64)(-|$)")
      set(PROJECT_ARCH "arm64")
    elseif(_zqf_cef_target_arch MATCHES "^(arm|armv[5-8][a-z0-9]*)(-|$)")
      set(PROJECT_ARCH "arm")
    else()
      message(FATAL_ERROR "Unsupported CEF target architecture: ${_zqf_cef_target_arch}")
    endif()
  endif()

  set(_zqf_cmake_generator_backup ${CMAKE_GENERATOR})
  set(_zqf_cmake_osx_deployment_target_backup ${CMAKE_OSX_DEPLOYMENT_TARGET})
  set(CMAKE_GENERATOR "UNKNOWN")
  include("${CEF_ROOT}/cmake/FindCEF.cmake")
  set(CMAKE_GENERATOR ${_zqf_cmake_generator_backup})
  set(CMAKE_OSX_DEPLOYMENT_TARGET ${_zqf_cmake_osx_deployment_target_backup})

  list(REMOVE_ITEM CEF_CXX_COMPILER_FLAGS "-std=c++20")
  list(REMOVE_ITEM CEF_CXX_COMPILER_FLAGS "/std:c++20")
  list(REMOVE_ITEM CEF_CXX_COMPILER_FLAGS "-fno-exceptions")
  list(REMOVE_ITEM CEF_COMPILER_FLAGS_RELEASE "/MT")
  list(REMOVE_ITEM CEF_COMPILER_FLAGS_RELEASE "/O2")
  list(REMOVE_ITEM CEF_COMPILER_FLAGS_RELEASE "/Ob2")
  list(REMOVE_ITEM CEF_COMPILER_FLAGS_DEBUG "/MTd")
  list(REMOVE_ITEM CEF_COMPILER_FLAGS_DEBUG "/RTC1")
  list(REMOVE_ITEM CEF_COMPILER_FLAGS_DEBUG "/Od")
  list(REMOVE_ITEM CEF_COMPILER_FLAGS "/Zi")
  list(REMOVE_ITEM CEF_COMPILER_FLAGS "/GR-")
  list(REMOVE_ITEM CEF_COMPILER_FLAGS "/MP")
  list(REMOVE_ITEM CEF_COMPILER_DEFINES "_HAS_EXCEPTIONS=0")
  list(FILTER CEF_COMPILER_FLAGS EXCLUDE REGEX "^-mmacosx-version-min=")

  if(NOT TARGET ZQF::CEFPrebuilt::CEF)
    if(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
      add_library(zqf_cef_prebuilt_cef INTERFACE)
      add_library(ZQF::CEFPrebuilt::CEF ALIAS zqf_cef_prebuilt_cef)
      target_link_libraries(zqf_cef_prebuilt_cef INTERFACE libcef_dll_wrapper ${CEF_STANDARD_LIBS})
    else()
      # Add CEF C Libary Target
      ADD_LOGICAL_TARGET("libcef_lib" "${CEF_LIB_DEBUG}" "${CEF_LIB_RELEASE}")

      # C Library
      add_library(zqf_cefprebuilt_c_library INTERFACE)
      add_library(ZQF::CEFPrebuilt::CLibrary ALIAS zqf_cefprebuilt_c_library)
      target_link_libraries(zqf_cefprebuilt_c_library INTERFACE libcef_lib ${CEF_STANDARD_LIBS})

      # CXX Wrapper
      add_library(zqf_cefprebuilt_cxx_wrapper INTERFACE)
      add_library(ZQF::CEFPrebuilt::CXXWrapper ALIAS zqf_cefprebuilt_cxx_wrapper)
      target_link_libraries(zqf_cefprebuilt_cxx_wrapper INTERFACE libcef_dll_wrapper)

      # Combine C Libary And CXX Wrapper
      add_library(zqf_cefprebuilt_full INTERFACE)
      add_library(ZQF::CEFPrebuilt::CEF ALIAS zqf_cefprebuilt_full)
      target_link_libraries(zqf_cefprebuilt_full INTERFACE ZQF::CEFPrebuilt::CLibrary ZQF::CEFPrebuilt::CXXWrapper)
    endif()
  endif()
endmacro()

function(zqf_cef_prebuilt_config target)
  SET_EXECUTABLE_TARGET_PROPERTIES("${target}")
endfunction()

function(zqf_cef_prebuilt_copyfiles target)
  if(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    set(target_dir "$<TARGET_BUNDLE_DIR:${target}>/../")
    add_custom_command(
      POST_BUILD
      TARGET "${target}"
      COMMAND ${CMAKE_COMMAND} -E copy_directory_if_different
      "${CEF_BINARY_DIR}/Chromium Embedded Framework.framework"
      "${target_dir}/Chromium Embedded Framework.framework"
      VERBATIM
    )
  else()
    set(target_dir "$<TARGET_FILE_DIR:${target}>")
    COPY_FILES("${target}" "${CEF_BINARY_FILES}" "${CEF_BINARY_DIR}" "${target_dir}")
    COPY_FILES("${target}" "${CEF_RESOURCE_FILES}" "${CEF_RESOURCE_DIR}" "${target_dir}")

    if(EXISTS "${CEF_BINARY_DIR}/libminigbm.so")
      COPY_FILES("${target}" "libminigbm.so" "${CEF_BINARY_DIR}" "${target_dir}")
    endif()
  endif()
endfunction()
