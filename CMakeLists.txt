cmake_minimum_required(VERSION 3.10)
project(QTC_Blockchain)

set(CMAKE_CXX_STANDARD 11)

# Find OpenSSL
find_package(OpenSSL REQUIRED)

# Add executable
add_executable(qtc main.cpp)

# Link OpenSSL libraries
target_link_libraries(qtc OpenSSL::SSL OpenSSL::Crypto)
