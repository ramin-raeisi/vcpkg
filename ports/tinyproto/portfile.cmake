vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ramin-raeisi/tinyproto
    REF d10aa6dbc3b7baadaad4c2418a82359f8efccc8f
    SHA512 e1a6a19552bd1eb78af849b7dbbabea4e4228715b8debb8c05f1e3aa2cbb79700455bfe47c214a11d13dcb13954eb263dba0506011a21325860a42eccee81c37
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

