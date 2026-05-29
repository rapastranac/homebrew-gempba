class Gempba < Formula
  desc "GemPBA - parallel branch-and-bound C++23 framework (multithreading flavor)"
  homepage "https://github.com/rapastranac/gempba"
  url "https://api.github.com/repos/rapastranac/gempba/tarball/refs/tags/v4.1.0"
  version "4.1.0"
  sha256 "146b0e812f07290abedce4a9c4a3652ff17388643cece38fed337987f5dcdb5b"
  license "MIT"
  head "https://github.com/rapastranac/gempba.git", branch: "main"

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "boost"
  depends_on "fmt"
  depends_on "hwloc"
  depends_on "libomp"
  depends_on "spdlog"

  def install
    libomp = Formula["libomp"]
    args = std_cmake_args + [
      "-DGEMPBA_BUILD_TESTS=OFF",
      "-DGEMPBA_DEV_MODE=OFF",
      "-DGEMPBA_MULTIPROCESSING=OFF",
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
      project(gempba_smoke LANGUAGES CXX)
      set(CMAKE_CXX_STANDARD 23)
      set(CMAKE_CXX_STANDARD_REQUIRED ON)
      find_package(gempba REQUIRED COMPONENTS mt)
    CMAKE

    system "cmake", "-S", testpath, "-B", testpath/"build",
           "-DCMAKE_PREFIX_PATH=#{opt_prefix};#{Formula["boost"].opt_prefix}"
  end
end
