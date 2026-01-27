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


# Build type options:
#	* catkin.
#	* cmake.
#	* ament (future).
# Regardless of the type chosen, the library 'libnabo' must be configured in the same way for the linker to suceed.
set(BUILD_TYPE "cmake")
if (BUILD_TYPE STREQUAL "catkin")
	include(CatkinBuild.cmake)
else()
	include(PureCMakeBuild.cmake)
endif()