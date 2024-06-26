# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/nowide
    REF boost-${VERSION}
    SHA512 c36ff430d155af583741d3040f0b3b647856e7dca5ead892651398a840b5fef54e96e0bd315d8c350e4fa841802593a857921456d7751ea356e772f3919b3227
    HEAD_REF master
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
