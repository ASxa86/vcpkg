vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/dawn
    REF e93ab20875ca3303ab2a1bc543debdda83c755f6
    SHA512 7f625d07b76a16d35b7a4fc6da4469db2664fe173fd7e3f53360b1a1ec2b10f1fc4a28c5d1a164cf68aee8f80bddb4c95b653f3309820c4d629d5f3756d2674c
    HEAD_REF master
    PATCHES
        fix-dependencies.patch
)

# Dawn third_party git submodules.

# Abseil-cpp # Dawn failed to link against the vcpkg "abseil" port. Continue using the "dawn way".
vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH_ABSEILCPP
    URL https://chromium.googlesource.com/chromium/src/third_party/abseil-cpp
    REF f81f6c011baf9b0132a5594c034fe0060820711d
)
file(COPY ${SOURCE_PATH_ABSEILCPP}/ DESTINATION ${SOURCE_PATH}/third_party/abseil-cpp)

# JINJA 2 # Dawn failed to import the jinja module during configuration as it expects markupsafe to be a sibling directory.
vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH_JINJA2
    URL https://chromium.googlesource.com/chromium/src/third_party/jinja2
    REF e2d024354e11cc6b041b0cff032d73f0c7e43a07
)
file(COPY ${SOURCE_PATH_JINJA2}/ DESTINATION ${SOURCE_PATH}/third_party/jinja2)

# MarkupSafe
vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH_MARKUPSAFE
    URL https://chromium.googlesource.com/chromium/src/third_party/markupsafe
    REF 0bad08bb207bbfc1d6f3bbc82b9242b0c50e5794
)
file(COPY ${SOURCE_PATH_MARKUPSAFE}/ DESTINATION ${SOURCE_PATH}/third_party/markupsafe)

# SPIRV-Tools # Dawn appears to be using implementation headers to build the tint modules. These headers are not provided by vcpkg port "spirv-tools".
vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH_SPIRVTOOLS
    URL https://chromium.googlesource.com/external/github.com/KhronosGroup/SPIRV-Tools
    REF 3d24089292ed357658e3de81ddc2e72f11296e39
)
file(COPY ${SOURCE_PATH_SPIRVTOOLS}/ DESTINATION ${SOURCE_PATH}/third_party/spirv-tools/src)

# Dawn requires python3 to perform auto generation with jinja2.
vcpkg_find_acquire_program(PYTHON3)

# Force the library to be built static only. There is some work that needs done to the dawn library with
# its cmake link targets to support shared correctly.
set(VCPKG_LIBRARY_LINKAGE static)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DDAWN_BUILD_SAMPLES=OFF
        -DDAWN_ENABLE_INSTALL=ON
        -DDAWN_USE_GLFW=OFF
        -DTINT_BUILD_CMD_TOOLS=OFF
        -DTINT_BUILD_TESTS=OFF
        # Dawn doesn't seem to have the tint modules as install dependents causing compilation failures when running vcpkg_cmake_install().
        -DTINT_ENABLE_INSTALL=OFF
        -DPython3_EXECUTABLE=${PYTHON3}
)

vcpkg_cmake_install()

# Ensure debug share exists for cmake targets.
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/share/dawn)
vcpkg_cmake_config_fixup()
vcpkg_copy_pdbs()
vcpkg_install_copyright(FILE_LIST ${SOURCE_PATH}/LICENSE)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
