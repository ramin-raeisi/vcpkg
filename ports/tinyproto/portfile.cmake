vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ramin-raeisi/tinyproto
    REF e92a0ef34c47339293a37c7f6a2e9f13f5629713
    SHA512 84200727bb7ce63b05197f2bf0160aa837a3fe896d64949657d9db3647fe5afc06dfe4f06f0ae4c492d2b77e973bd4e66dacd9ce0288dbdc1fe4acfe9d6b6842
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

