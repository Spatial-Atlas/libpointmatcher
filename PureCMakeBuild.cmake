# Find dependencies
find_package(Eigen3 REQUIRED)
find_package(Boost REQUIRED COMPONENTS chrono date_time filesystem program_options system thread timer)
find_package(nabo REQUIRED)
find_package(yaml-cpp REQUIRED)

########################
## Library definition ##
########################
# Core library
add_library(core
  ${POINTMATCHER_SRC}
  ${POINTMATCHER_HEADERS}
)

target_include_directories(core PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_NAME}>
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_NAME}/DataPointsFilters>
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_NAME}/DataPointsFilters/utils>
  $<INSTALL_INTERFACE:include/${PROJECT_NAME}>
)
target_include_directories(core SYSTEM PRIVATE
  ${EIGEN3_INCLUDE_DIR}
  ${Boost_INCLUDE_DIRS}
  ${catkin_INCLUDE_DIRS}
)
target_link_libraries(core
  ${catkin_LIBRARIES}
  Boost::chrono
  Boost::date_time
  Boost::filesystem
  Boost::program_options
  Boost::thread
  Boost::timer
  Boost::system
  yaml-cpp
  nabo::knn
)
add_library(${PROJECT_NAME}::core ALIAS core)

# Testing utils
add_library(testing
  ${PROJECT_NAME}/testing/utils_filesystem.cpp
  ${PROJECT_NAME}/testing/utils_filesystem.h
  ${PROJECT_NAME}/testing/utils_geometry.cpp
  ${PROJECT_NAME}/testing/utils_geometry.h
  ${PROJECT_NAME}/testing/utils_gtest.cpp
  ${PROJECT_NAME}/testing/utils_registration.cpp
  ${PROJECT_NAME}/testing/utils_transformations.cpp
  ${PROJECT_NAME}/testing/RegistrationTestCase.cpp
  ${PROJECT_NAME}/testing/RegistrationTestResult.cpp
  ${PROJECT_NAME}/testing/TransformationError.cpp
)
add_dependencies(testing
  core
)
target_include_directories(testing PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_NAME}/testing>
)
target_include_directories(testing SYSTEM PRIVATE
  ${Boost_INCLUDE_DIRS}
  ${catkin_INCLUDE_DIRS}
)
target_link_libraries(testing
  core
  ${catkin_LIBRARIES}
  Eigen3::Eigen
  Boost::chrono
  Boost::date_time
  Boost::filesystem
  Boost::program_options
  Boost::thread
  Boost::timer
  Boost::system
  yaml-cpp
  nabo::knn
)
add_library(${PROJECT_NAME}::testing ALIAS testing)

#############
## Install ##
#############
install(
  TARGETS
    core
    testing
  EXPORT ${PROJECT_NAME}_Targets
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
  RUNTIME DESTINATION bin
)
install(DIRECTORY ${CMAKE_SOURCE_DIR}/${PROJECT_NAME}/
  DESTINATION include
  FILES_MATCHING PATTERN "*.h"
)
install(FILES ${CMAKE_BINARY_DIR}/compile_commands.json
  DESTINATION .
  OPTIONAL
)
install(
  EXPORT ${PROJECT_NAME}_Targets
  FILE ${PROJECT_NAME}Config.cmake
  NAMESPACE ${PROJECT_NAME}::
  DESTINATION share/${PROJECT_NAME}
)
install(
  EXPORT ${PROJECT_NAME}_Targets
  FILE Find${PROJECT_NAME}.cmake
  DESTINATION share/${PROJECT_NAME}
)
install(FILES
  "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
  DESTINATION share/${PROJECT_NAME}
)
include(CMakePackageConfigHelpers)
write_basic_package_version_file(
  "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
  VERSION ${PROJECT_VERSION}
  COMPATIBILITY SameMajorVersion
)
install(FILES
  "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
  DESTINATION share/${PROJECT_NAME}
)

##########
## Test ##
##########
# find_package(cmake_code_coverage QUIET)
# if(CATKIN_ENABLE_TESTING)
#   # Symbol that controls whether data used for tests should be saved to disk for debugging.
#   set(SAVE_TEST_DATA_TO_DISK 0)
#   add_definitions(-DSAVE_TEST_DATA_TO_DISK=${SAVE_TEST_DATA_TO_DISK})
#   catkin_add_gtest(test_${PROJECT_NAME}
#       utest/utest.cpp
#       utest/ui/DataFilters.cpp
#       utest/ui/DataPoints.cpp
#       utest/ui/ErrorMinimizers.cpp
#       utest/ui/Inspectors.cpp
#       utest/ui/IO.cpp
#       utest/ui/Loggers.cpp
#       utest/ui/Matcher.cpp
#       utest/ui/Outliers.cpp
#       utest/ui/PointCloudGenerator.cpp
#       utest/ui/Transformations.cpp
#       utest/ui/octree/Octree.cpp
#       utest/ui/icp/GeneralTests.cpp
#       utest/ui/icp/Conditioning.cpp
#   )
#   add_dependencies(test_${PROJECT_NAME}
#     core
#     testing
#   )
#   target_include_directories(test_${PROJECT_NAME} PRIVATE
#     ${CMAKE_SOURCE_DIR}
#     ${CMAKE_SOURCE_DIR}/${PROJECT_NAME}
#     ${CMAKE_SOURCE_DIR}/${PROJECT_NAME}/DataPointsFilters
#     ${CMAKE_SOURCE_DIR}/${PROJECT_NAME}/DataPointsFilters/utils
#     ${CMAKE_SOURCE_DIR}/testing
#   )
#   target_include_directories(test_${PROJECT_NAME} SYSTEM PUBLIC
#     ${EIGEN3_INCLUDE_DIR}
#     ${Boost_INCLUDE_DIRS}
#     ${catkin_INCLUDE_DIRS}
#   )
#   target_link_libraries(test_${PROJECT_NAME}
#     core
#     testing
#     yaml-cpp
#     ${catkin_LIBRARIES}
#   )

#   set(TEST_DATA_FOLDER "${CMAKE_SOURCE_DIR}/examples/data/")
#   add_definitions(-DUTEST_TEST_DATA_PATH="${TEST_DATA_FOLDER}/")
# endif(CATKIN_ENABLE_TESTING)