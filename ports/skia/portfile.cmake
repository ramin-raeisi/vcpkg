include("${CMAKE_CURRENT_LIST_DIR}/skia-functions.cmake")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/skia
    REF "aefbd9403c1b3032ad4cd0281ef312ed262c7125"
    SHA512 8d1af006d4974c919c5760f4e461331db5dcf8ad4c4ee91c12433a88b15ea186a8932b7cd241ce47b012eb0fa5ed28f5d5d9ad187abb2bfd45a6ece8edb48d19
    PATCHES
        disable-msvc-env-setup.patch
        # disable-dev-test.patch
        skia-include-string.patch
        bentleyottmann-build.patch
        graphite.patch
        vulkan-headers.patch
        pdfsubsetfont-uwp.diff
        skparagraph-dllexport.patch
)

# De-vendor
file(REMOVE_RECURSE "${SOURCE_PATH}/include/third_party/vulkan")

# these following aren't available in vcpkg
# to update, visit the DEPS file in Skia's root directory
declare_external_from_git(abseil-cpp
    URL "https://github.com/abseil/abseil-cpp.git"
    REF "65a55c2ba891f6d2492477707f4a2e327a0b40dc"
    LICENSE_FILE LICENSE
)
declare_external_from_git(d3d12allocator
    URL "https://github.com/GPUOpen-LibrariesAndSDKs/D3D12MemoryAllocator.git"
    REF "169895d529dfce00390a20e69c2f516066fe7a3b"
    LICENSE_FILE LICENSE.txt
)
declare_external_from_git(dawn
    URL "https://dawn.googlesource.com/dawn.git"
    REF "acd89d9f169a9d09b9ada09d1bd80350376b8544"
    LICENSE_FILE LICENSE
)
declare_external_from_git(dng_sdk
    URL "https://android.googlesource.com/platform/external/dng_sdk.git"
    REF "c8d0c9b1d16bfda56f15165d39e0ffa360a11123"
    LICENSE_FILE LICENSE
)
declare_external_from_git(jinja2
    URL "https://chromium.googlesource.com/chromium/src/third_party/jinja2"
    REF "e2d024354e11cc6b041b0cff032d73f0c7e43a07"
    LICENSE_FILE LICENSE.rst
)
declare_external_from_git(markupsafe
    URL "https://chromium.googlesource.com/chromium/src/third_party/markupsafe"
    REF "0bad08bb207bbfc1d6f3bbc82b9242b0c50e5794"
    LICENSE_FILE LICENSE
)
declare_external_from_git(partition_alloc
    URL "https://chromium.googlesource.com/chromium/src/base/allocator/partition_allocator.git"
    REF "ce13777cb731e0a60c606d1741091fd11a0574d7"
    LICENSE_FILE LICENSE
)
declare_external_from_git(piex
    URL "https://android.googlesource.com/platform/external/piex.git"
    REF "bb217acdca1cc0c16b704669dd6f91a1b509c406"
    LICENSE_FILE LICENSE
)
declare_external_from_git(spirv-cross
    URL "https://github.com/KhronosGroup/SPIRV-Cross"
    REF "b8fcf307f1f347089e3c46eb4451d27f32ebc8d3"
    LICENSE_FILE LICENSE
)
declare_external_from_git(spirv-headers
    URL "https://github.com/KhronosGroup/SPIRV-Headers.git"
    REF "e7294a8ebed84f8c5bd3686c68dbe12a4e65b644"
    LICENSE_FILE LICENSE
)
declare_external_from_git(spirv-tools
    URL "https://github.com/KhronosGroup/SPIRV-Tools.git"
    REF "ce37fd67f83cd1e8793b988d2e4126bbf72b19dd"
    LICENSE_FILE LICENSE
)
declare_external_from_git(wuffs
    URL "https://github.com/google/wuffs-mirror-release-c.git"
    REF "e3f919ccfe3ef542cfc983a82146070258fb57f8"
    LICENSE_FILE LICENSE
)

declare_external_from_pkgconfig(expat)
declare_external_from_pkgconfig(fontconfig PATH "third_party")
declare_external_from_pkgconfig(freetype2)
declare_external_from_pkgconfig(harfbuzz MODULES harfbuzz harfbuzz-subset)
declare_external_from_pkgconfig(icu MODULES icu-uc)
declare_external_from_pkgconfig(libjpeg PATH "third_party/libjpeg-turbo" MODULES libturbojpeg libjpeg)
declare_external_from_pkgconfig(libpng)
declare_external_from_pkgconfig(libwebp MODULES libwebpdecoder libwebpdemux libwebpmux libwebp)
declare_external_from_pkgconfig(zlib)

declare_external_from_vcpkg(vulkan_headers PATH third_party/externals/vulkan-headers)

set(known_cpus x86 x64 arm arm64 wasm)
if(NOT VCPKG_TARGET_ARCHITECTURE IN_LIST known_cpus)
    message(WARNING "Unknown target cpu '${VCPKG_TARGET_ARCHITECTURE}'.")
endif()

string(JOIN " " OPTIONS
    "target_cpu=\"${VCPKG_TARGET_ARCHITECTURE}\""
    skia_enable_android_utils=false
    skia_enable_spirv_validation=false
    skia_enable_tools=false
    skia_enable_gpu_debug_layers=false
    skia_use_jpeg_gainmaps=false
    skia_use_libheif=false
    skia_use_lua=false
)
set(OPTIONS_DBG "is_debug=true")
set(OPTIONS_REL "is_official_build=true")
vcpkg_list(SET SKIA_TARGETS :skia :modules)

if(VCPKG_TARGET_IS_ANDROID)
    string(APPEND OPTIONS " target_os=\"android\"")
elseif(VCPKG_TARGET_IS_IOS)
    string(APPEND OPTIONS " target_os=\"ios\"")
elseif(VCPKG_TARGET_IS_EMSCRIPTEN)
    string(APPEND OPTIONS " target_os=\"wasm\"")
elseif(VCPKG_TARGET_IS_WINDOWS)
    string(APPEND OPTIONS " target_os=\"win\"")
    if(VCPKG_TARGET_IS_UWP)
        string(APPEND OPTIONS " skia_enable_winuwp=true skia_enable_fontmgr_win=false skia_use_xps=false")
    endif()
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        string(APPEND OPTIONS " skia_enable_bentleyottmann=false")
    endif()
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    string(APPEND OPTIONS " is_component_build=true")
else()
    string(APPEND OPTIONS " is_component_build=false")
endif()

set(required_externals
    dng_sdk
    expat
    libjpeg
    libpng
    libwebp
    piex
    zlib
    wuffs
)

if("fontconfig" IN_LIST FEATURES)
    list(APPEND required_externals fontconfig)
    string(APPEND OPTIONS " skia_use_fontconfig=true")
    if(VCPKG_TARGET_IS_WINDOWS)
        string(APPEND OPTIONS " skia_enable_fontmgr_FontConfigInterface=false")
    endif()
else()
    string(APPEND OPTIONS " skia_use_fontconfig=false")
endif()

if("freetype" IN_LIST FEATURES)
    list(APPEND required_externals freetype2)
    string(APPEND OPTIONS " skia_use_freetype=true")
else()
    string(APPEND OPTIONS " skia_use_freetype=false")
endif()

if("harfbuzz" IN_LIST FEATURES)
    list(APPEND required_externals harfbuzz)
    string(APPEND OPTIONS " skia_use_harfbuzz=true")
else()
    string(APPEND OPTIONS " skia_use_harfbuzz=false")
endif()

if("icu" IN_LIST FEATURES)
    list(APPEND required_externals icu)
    string(APPEND OPTIONS " skia_use_icu=true skia_use_system_icu=true")
else()
    string(APPEND OPTIONS " skia_use_icu=false")
endif()

if("gl" IN_LIST FEATURES)
    string(APPEND OPTIONS " skia_use_gl=true")
else()
    string(APPEND OPTIONS " skia_use_gl=false")
endif()

if("metal" IN_LIST FEATURES)
    string(APPEND OPTIONS " skia_use_metal=true")
endif()

if("vulkan" IN_LIST FEATURES)
    list(APPEND required_externals
        vulkan_headers
    )
    string(APPEND OPTIONS " skia_use_vulkan=true skia_vulkan_memory_allocator_dir=\"${CURRENT_INSTALLED_DIR}\"")
endif()

if("direct3d" IN_LIST FEATURES)
    list(APPEND required_externals
        spirv-cross
        spirv-headers
        spirv-tools
        d3d12allocator
    )
    string(APPEND OPTIONS " skia_use_direct3d=true")
endif()

if("graphite" IN_LIST FEATURES)
    string(APPEND OPTIONS " skia_enable_graphite=true")
endif()

if("dawn" IN_LIST FEATURES)
    if (VCPKG_TARGET_IS_LINUX)
        message(WARNING
[[
dawn support requires the following libraries from the system package manager:

    libx11-xcb-dev mesa-common-dev

They can be installed on Debian based systems via

    apt-get install libx11-xcb-dev mesa-common-dev
]]
        )
    endif()

    list(APPEND required_externals
        spirv-cross
        spirv-headers
        spirv-tools
        jinja2
        markupsafe
        vulkan_headers
## Remove
        abseil-cpp
## REMOVE ^
        partition_alloc
        dawn
    )
    file(REMOVE_RECURSE "${SOURCE_PATH}/third_party/externals/opengl-registry")
    file(INSTALL "${CURRENT_INSTALLED_DIR}/share/opengl/" DESTINATION "${SOURCE_PATH}/third_party/externals/opengl-registry/xml")
    # cf. external dawn/src/dawn/native/BUILD.gn
    string(APPEND OPTIONS " skia_use_dawn=true dawn_use_swiftshader=false")
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        string(APPEND OPTIONS " dawn_complete_static_libs=true")
    endif()
endif()

get_externals(${required_externals})
if(EXISTS "${SOURCE_PATH}/third_party/externals/dawn")
    vcpkg_find_acquire_program(GIT)
    vcpkg_replace_string("${SOURCE_PATH}/third_party/externals/dawn/generator/dawn_version_generator.py"
        "get_git(),"
        "\"${GIT}\","
    )
endif()
if("icu" IN_LIST FEATURES)
    vcpkg_replace_string("${SOURCE_PATH}/third_party/icu/BUILD.gn"
        [[config("vcpkg_icu") {]]
        [[import("icu.gni")
config("vcpkg_icu")  {]])
endif()

vcpkg_find_acquire_program(PYTHON3)
vcpkg_replace_string("${SOURCE_PATH}/.gn" "script_executable = \"python3\"" "script_executable = \"${PYTHON3}\"")
vcpkg_replace_string("${SOURCE_PATH}/gn/toolchain/BUILD.gn" "python3 " "\\\"${PYTHON3}\\\" ")

vcpkg_cmake_get_vars(cmake_vars_file)
include("${cmake_vars_file}")
if(VCPKG_TARGET_IS_WINDOWS)
    string(REGEX REPLACE "[\\]\$" "" WIN_VC "$ENV{VCINSTALLDIR}")
    string(REGEX REPLACE "[\\]\$" "" WIN_SDK "$ENV{WindowsSdkDir}")
    string(APPEND OPTIONS " win_vc=\"${WIN_VC}\"")
    string(APPEND OPTIONS " win_sdk=\"${WIN_SDK}\"")
elseif(VCPKG_TARGET_IS_ANDROID)
    string(APPEND OPTIONS " ndk=\"${VCPKG_DETECTED_CMAKE_ANDROID_NDK}\" ndk_api=${VCPKG_DETECTED_CMAKE_SYSTEM_VERSION}")
else()
    string(APPEND OPTIONS " \
        cc=\"${VCPKG_DETECTED_CMAKE_C_COMPILER}\" \
        cxx=\"${VCPKG_DETECTED_CMAKE_CXX_COMPILER}\"")
endif()

string_to_gn_list(SKIA_C_FLAGS_DBG "${VCPKG_COMBINED_C_FLAGS_DEBUG}")
string_to_gn_list(SKIA_CXX_FLAGS_DBG "${VCPKG_COMBINED_CXX_FLAGS_DEBUG}")
string(APPEND OPTIONS_DBG " \
    extra_cflags_c=${SKIA_C_FLAGS_DBG} \
    extra_cflags_cc=${SKIA_CXX_FLAGS_DBG}")
string_to_gn_list(SKIA_C_FLAGS_REL "${VCPKG_COMBINED_C_FLAGS_RELEASE}")
string_to_gn_list(SKIA_CXX_FLAGS_REL "${VCPKG_COMBINED_CXX_FLAGS_RELEASE}")
string(APPEND OPTIONS_REL " \
    extra_cflags_c=${SKIA_C_FLAGS_REL} \
    extra_cflags_cc=${SKIA_CXX_FLAGS_REL}")
if(VCPKG_TARGET_IS_UWP)
    string_to_gn_list(SKIA_LD_FLAGS "-APPCONTAINER WindowsApp.lib")
    string(APPEND OPTIONS " extra_ldflags=${SKIA_LD_FLAGS}")
endif()

vcpkg_gn_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS "${OPTIONS}"
    OPTIONS_DEBUG "${OPTIONS_DBG}"
    OPTIONS_RELEASE "${OPTIONS_REL}"
)

skia_gn_install(
    SOURCE_PATH "${SOURCE_PATH}"
    TARGETS ${SKIA_TARGETS}
)

# Use skia repository layout in ${CURRENT_PACKAGES_DIR}/include/skia
file(COPY "${SOURCE_PATH}/include"
          "${SOURCE_PATH}/modules"
          "${SOURCE_PATH}/src"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include/skia"
    FILES_MATCHING PATTERN "*.h"
)
auto_clean("${CURRENT_PACKAGES_DIR}/include/skia")
set(skia_dll_static "0")
set(skia_dll_dynamic "1")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/skia/include/private/base/SkAPI.h" "defined(SKIA_DLL)" "${skia_dll_${VCPKG_LIBRARY_LINKAGE}}")

# vcpkg legacy layout omits "include/" component. Just duplicate.
file(COPY "${CURRENT_PACKAGES_DIR}/include/skia/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/skia")

# vcpkg legacy
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/skiaConfig.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/skia")

file(INSTALL
    "${CMAKE_CURRENT_LIST_DIR}/example/CMakeLists.txt"
    "${SOURCE_PATH}/tools/convert-to-nia.cpp"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/example"
)
file(APPEND "${CURRENT_PACKAGES_DIR}/share/${PORT}/example/convert-to-nia.cpp" [[
// Test for https://github.com/microsoft/vcpkg/issues/27219
#include "include/core/SkColorSpace.h"
]])

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(GLOB third_party_licenses "${SOURCE_PATH}/third_party_licenses/*")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE" ${third_party_licenses})
