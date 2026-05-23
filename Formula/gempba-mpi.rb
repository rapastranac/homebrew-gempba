class GempbaMpi < Formula
  desc "GemPBA - parallel branch-and-bound C++23 framework (MPI multiprocessing flavor)"
  homepage "https://github.com/rapastranac/gempba"
  url "https://api.github.com/repos/rapastranac/gempba/tarball/refs/tags/v4.0.0"
  version "4.0.0"
  sha256 "f6e9762194d3d3f743e309b23cd7d09f8a1efa5de87086449e850e7d962f211e"
  license "MIT"
  head "https://github.com/rapastranac/gempba.git", branch: "main"

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "boost"
  depends_on "fmt"
  depends_on "gempba"
  depends_on "hwloc"
  depends_on "libomp"
  depends_on "open-mpi"
  depends_on "spdlog"

  def install
    libomp = Formula["libomp"]
    args = std_cmake_args + [
      "-DGEMPBA_BUILD_TESTS=OFF",
      "-DGEMPBA_DEV_MODE=OFF",
      "-DGEMPBA_MULTIPROCESSING=ON",
      "-DOpenMP_CXX_FLAGS=-Xpreprocessor -fopenmp -I#{libomp.opt_include}",
      "-DOpenMP_CXX_LIB_NAMES=omp",
      "-DOpenMP_omp_LIBRARY=#{libomp.opt_lib}/libomp.dylib",
      "-DCMAKE_PREFIX_PATH=#{Formula["boost"].opt_prefix}",
    ]

    system "cmake", "-S", ".", "-B", "build", *args
    system "cmake", "--build", "build", "--parallel"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"CMakeLists.txt").write <<~CMAKE
      cmake_minimum_required(VERSION 3.28)
      project(gempba_mpi_smoke LANGUAGES CXX)
      set(CMAKE_CXX_STANDARD 23)
      set(CMAKE_CXX_STANDARD_REQUIRED ON)
      find_package(gempba REQUIRED COMPONENTS mpi)
    CMAKE

    gempba = Formula["gempba"]
    system "cmake", "-S", testpath, "-B", testpath/"build",
           "-DCMAKE_PREFIX_PATH=#{opt_prefix};#{gempba.opt_prefix};#{Formula["boost"].opt_prefix}"
  end
end
