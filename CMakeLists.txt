cmake_minimum_required(VERSION 3.10)
project(QTC_Blockchain_Full)

set(CMAKE_CXX_STANDARD 17)

# Find required packages
find_package(OpenSSL REQUIRED)
find_package(Threads REQUIRED)

# Include directories
include_directories(include)

# Collect all source files
file(GLOB_RECURSE SOURCES "src/*.cpp")

# Create executable
add_executable(qtc_full ${SOURCES})

# Link libraries
target_link_libraries(qtc_full
    OpenSSL::SSL
    OpenSSL::Crypto
    Threads::Threads
)
