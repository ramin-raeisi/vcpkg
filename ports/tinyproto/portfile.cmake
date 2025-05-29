vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ramin-raeisi/tinyproto
    REF 75c8bd3dd259b6c62a827090a8823a448fa331d4 # 1.0.0 + 156 commits
    SHA512 7093c9b78212e80a9660e6cab9e1bb8e53eb5deb30a9cacaa22c69eba57751b001212c9ff1a47704ae871d17d30643a85d9da510332ea0e822917ca354eb3af0
    HEAD_REF feature/add-macos-supportability
)

vcpkg_cmake_configure(
	SOURCE_PATH "${SOURCE_PATH}"
	OPTIONS "-DCMAKE_CXX_STANDARD=11"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/tinyproto")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

