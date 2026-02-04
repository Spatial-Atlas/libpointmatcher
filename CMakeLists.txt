cmake_minimum_required(VERSION 3.15)
project(pointmatcher VERSION 1.0.0 LANGUAGES CXX)

# Pointmatcher lib and install
set(POINTMATCHER_SRC
	${PROJECT_NAME}/Logger.cpp
	${PROJECT_NAME}/Exceptions.cpp
	${PROJECT_NAME}/DataPoints.cpp
	${PROJECT_NAME}/Matches.cpp
	${PROJECT_NAME}/ICP.cpp
	${PROJECT_NAME}/Registry.cpp
	${PROJECT_NAME}/Registrar.cpp
	${PROJECT_NAME}/DataPointsFilter.cpp
	${PROJECT_NAME}/Matcher.cpp
	${PROJECT_NAME}/OutlierFilter.cpp
	${PROJECT_NAME}/ErrorMinimizer.cpp
	${PROJECT_NAME}/Transformation.cpp
	${PROJECT_NAME}/TransformationChecker.cpp
	${PROJECT_NAME}/Inspector.cpp
	${PROJECT_NAME}/IO.cpp
	${PROJECT_NAME}/IOFunctions.cpp
	${PROJECT_NAME}/Bibliography.cpp
	${PROJECT_NAME}/Timer.cpp
	${PROJECT_NAME}/Histogram.cpp
	${PROJECT_NAME}/Parametrizable.cpp
	${PROJECT_NAME}/LoggerImpl.cpp
	${PROJECT_NAME}/MatchersImpl.cpp
	${PROJECT_NAME}/OutlierFiltersImpl.cpp
	${PROJECT_NAME}/SurfaceNormalEstimatorPCA.cpp
	${PROJECT_NAME}/TransformationsImpl.cpp
	${PROJECT_NAME}/TransformationCheckersImpl.cpp
	${PROJECT_NAME}/InspectorsImpl.cpp
#ErrorMinimizers
	${PROJECT_NAME}/ErrorMinimizers/PointToPlane.cpp
	${PROJECT_NAME}/ErrorMinimizers/Identity.cpp
#DataPointsFilters	
	${PROJECT_NAME}/DataPointsFilters/Identity.cpp
	${PROJECT_NAME}/DataPointsFilters/RemoveNaN.cpp
	${PROJECT_NAME}/DataPointsFilters/BoundingBox.cpp
	${PROJECT_NAME}/DataPointsFilters/MaxDensity.cpp
	${PROJECT_NAME}/DataPointsFilters/SurfaceNormal.cpp
	${PROJECT_NAME}/DataPointsFilters/OrientNormals.cpp
	${PROJECT_NAME}/DataPointsFilters/IncidenceAngle.cpp
	${PROJECT_NAME}/DataPointsFilters/RandomSampling.cpp
	${PROJECT_NAME}/DataPointsFilters/Shadow.cpp
	${PROJECT_NAME}/DataPointsFilters/ObservationDirection.cpp
	${PROJECT_NAME}/DataPointsFilters/OctreeGrid.cpp
	${PROJECT_NAME}/DataPointsFilters/NormalSpace.cpp
	${PROJECT_NAME}/DataPointsFilters/DistanceLimit.cpp
	${PROJECT_NAME}/DataPointsFilters/OrganizedCloudSurfaceNormal.cpp
#PointCloudGenerators
	${PROJECT_NAME}/PointCloudGenerator.cpp
)

file(GLOB_RECURSE POINTMATCHER_HEADERS "${PROJECT_NAME}/*.h")

# Set C++ standard
set(CMAKE_CXX_STANDARD 20) # Use C++20 standard
set(CMAKE_CXX_STANDARD_REQUIRED ON) # Ensures that the specified C++ standard (set elsewhere) is strictly required for the project.
set(CMAKE_CXX_EXTENSIONS OFF) # Disables compiler-specific language extensions, enforcing strict compliance with the chosen C++ standard.

# Export compile commands for CI/CD tools
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Define compiler options
add_compile_options(-Wall -Wextra -Wpedantic -Werror=return-type -Wunused -Wunused-function -Wunused-variable -Wunreachable-code)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
if (NOT CMAKE_BUILD_TYPE STREQUAL "Debug")
  add_definitions(-O3)
endif(NOT CMAKE_BUILD_TYPE STREQUAL "Debug")

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
  ${Boost_INCLUDE_DIRS}
)
target_link_libraries(core PRIVATE
  Eigen3::Eigen
  Boost::chrono
  Boost::date_time
  Boost::filesystem
  Boost::program_options
  Boost::system
  Boost::thread
  Boost::timer
  yaml-cpp
  nabo::knn
)
set_target_properties(core PROPERTIES POSITION_INDEPENDENT_CODE ON)
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
)
target_link_libraries(testing PRIVATE
  core
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
set_target_properties(testing PROPERTIES POSITION_INDEPENDENT_CODE ON)
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
install(DIRECTORY ${CMAKE_SOURCE_DIR}/${PROJECT_NAME}
  DESTINATION include/${PROJECT_NAME}
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
include(CTest)
if(BUILD_TESTS)
  enable_testing()

  find_package(GTest REQUIRED)

  # Symbol that controls whether data used for tests should be saved to disk for debugging.
  set(SAVE_TEST_DATA_TO_DISK 0)
  add_definitions(-DSAVE_TEST_DATA_TO_DISK=${SAVE_TEST_DATA_TO_DISK})
  set(TEST_DATA_FOLDER "${CMAKE_SOURCE_DIR}/examples/data/")
  add_definitions(-DUTEST_TEST_DATA_PATH="${TEST_DATA_FOLDER}/")
  
  add_executable(unit_tests
      utest/utest.cpp
      utest/ui/DataFilters.cpp
      utest/ui/DataPoints.cpp
      utest/ui/ErrorMinimizers.cpp
      utest/ui/Inspectors.cpp
      utest/ui/IO.cpp
      utest/ui/Loggers.cpp
      utest/ui/Matcher.cpp
      utest/ui/Outliers.cpp
      utest/ui/PointCloudGenerator.cpp
      utest/ui/Transformations.cpp
      utest/ui/octree/Octree.cpp
      utest/ui/icp/GeneralTests.cpp
      utest/ui/icp/Conditioning.cpp
  )
  add_dependencies(unit_tests
    core
    testing
  )
  target_include_directories(unit_tests PRIVATE
    ${CMAKE_SOURCE_DIR}
    ${CMAKE_SOURCE_DIR}/${PROJECT_NAME}
    ${CMAKE_SOURCE_DIR}/${PROJECT_NAME}/DataPointsFilters
    ${CMAKE_SOURCE_DIR}/${PROJECT_NAME}/DataPointsFilters/utils
    ${CMAKE_SOURCE_DIR}/testing
  )
  target_include_directories(unit_tests SYSTEM PUBLIC
    ${Boost_INCLUDE_DIRS}
  )
  target_link_libraries(unit_tests PRIVATE
    core
    testing
    Eigen3::Eigen
    yaml-cpp
    gtest
    gtest_main
    pthread
  )
  install(
    TARGETS
      unit_tests
    EXPORT ${PROJECT_NAME}_Targets
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
  )

  gtest_discover_tests(unit_tests)
endif()