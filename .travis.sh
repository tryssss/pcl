#!/bin/sh

PCL_DIR=`pwd`
BUILD_DIR=$PCL_DIR/build
DOC_DIR=$BUILD_DIR/doc/doxygen/html

TUTORIALS_DIR=$BUILD_DIR/doc/tutorials/html
ADVANCED_DIR=$BUILD_DIR/doc/advanced/html

CMAKE_C_FLAGS="-Wall -Wextra -Wabi -O2"
CMAKE_CXX_FLAGS="-Wall -Wextra -Wabi -O2"

if [ "$TRAVIS_OS_NAME" == "linux" ]; then
  if [ "$CC" == "clang" ]; then
    CMAKE_C_FLAGS="$CMAKE_C_FLAGS -Qunused-arguments"
    CMAKE_CXX_FLAGS="$CMAKE_CXX_FLAGS -Qunused-arguments"
  fi
fi

function before_install ()
{
  if [ "$TRAVIS_OS_NAME" == "linux" ]; then
    if [ "$CC" == "clang" ]; then
      sudo ln -s ../../bin/ccache /usr/lib/ccache/clang
      sudo ln -s ../../bin/ccache /usr/lib/ccache/clang++
    fi
  fi
}

function build ()
{
  case $CC in
    clang ) build_lib;;
    gcc ) build_lib_core;;
  esac
}

function build_lib ()
{
  # A complete build
  # Configure
  mkdir $BUILD_DIR && cd $BUILD_DIR
  cmake -DCMAKE_C_FLAGS="$CMAKE_C_FLAGS" -DCMAKE_CXX_FLAGS="$CMAKE_CXX_FLAGS" \
        -DPCL_ONLY_CORE_POINT_TYPES=ON \
        -DPCL_QT_VERSION=4 \
        -DBUILD_simulation=ON \
        -DBUILD_global_tests=OFF \
        -DBUILD_examples=OFF \
        -DBUILD_tools=OFF \
        -DBUILD_apps=OFF \
        -DBUILD_apps_3d_rec_framework=OFF \
        -DBUILD_apps_cloud_composer=OFF \
        -DBUILD_apps_in_hand_scanner=OFF \
        -DBUILD_apps_modeler=OFF \
        -DBUILD_apps_optronic_viewer=OFF \
        -DBUILD_apps_point_cloud_editor=OFF \
        $PCL_DIR
  # Build
  make -j2
}

function build_examples ()
{
  # A complete build
  # Configure
  mkdir $BUILD_DIR && cd $BUILD_DIR
  cmake -DCMAKE_C_FLAGS="$CMAKE_C_FLAGS" -DCMAKE_CXX_FLAGS="$CMAKE_CXX_FLAGS" \
        -DPCL_ONLY_CORE_POINT_TYPES=ON \
        -DPCL_QT_VERSION=4 \
        -DBUILD_simulation=ON \
        -DBUILD_global_tests=OFF \
        -DBUILD_examples=ON \
        -DBUILD_tools=OFF \
        -DBUILD_apps=OFF \
        $PCL_DIR
  # Build
  make -j2
}

function build_tools ()
{
  # A complete build
  # Configure
  mkdir $BUILD_DIR && cd $BUILD_DIR
  cmake -DCMAKE_C_FLAGS="$CMAKE_C_FLAGS" -DCMAKE_CXX_FLAGS="$CMAKE_CXX_FLAGS" \
        -DPCL_ONLY_CORE_POINT_TYPES=ON \
        -DPCL_QT_VERSION=4 \
        -DBUILD_simulation=ON \
        -DBUILD_global_tests=OFF \
        -DBUILD_examples=OFF \
        -DBUILD_tools=ON \
        -DBUILD_apps=OFF \
        $PCL_DIR
  # Build
  make -j2
}

function build_apps ()
{
  # A complete build
  # Configure
  mkdir $BUILD_DIR && cd $BUILD_DIR
  cmake -DCMAKE_C_FLAGS="$CMAKE_C_FLAGS" -DCMAKE_CXX_FLAGS="$CMAKE_CXX_FLAGS" \
        -DPCL_ONLY_CORE_POINT_TYPES=ON \
        -DPCL_QT_VERSION=4 \
        -DBUILD_simulation=OFF \
        -DBUILD_outofcore=OFF \
        -DBUILD_people=OFF \
        -DBUILD_global_tests=OFF \
        -DBUILD_examples=OFF \
        -DBUILD_tools=OFF \
        -DBUILD_apps=ON \
        -DBUILD_apps_3d_rec_framework=ON \
        -DBUILD_apps_cloud_composer=ON \
        -DBUILD_apps_in_hand_scanner=ON \
        -DBUILD_apps_modeler=ON \
        -DBUILD_apps_optronic_viewer=OFF \
        -DBUILD_apps_point_cloud_editor=ON \
        $PCL_DIR
  # Build
  make -j2
}

function build_lib_core ()
{
  # A reduced build, only pcl_common
  # Configure
  mkdir $BUILD_DIR && cd $BUILD_DIR
  cmake -DCMAKE_C_FLAGS="$CMAKE_C_FLAGS" -DCMAKE_CXX_FLAGS="$CMAKE_CXX_FLAGS" \
        -DPCL_ONLY_CORE_POINT_TYPES=ON \
        -DBUILD_2d=OFF \
        -DBUILD_features=OFF \
        -DBUILD_filters=OFF \
        -DBUILD_geometry=OFF \
        -DBUILD_global_tests=OFF \
        -DBUILD_io=OFF \
        -DBUILD_kdtree=OFF \
        -DBUILD_keypoints=OFF \
        -DBUILD_ml=OFF \
        -DBUILD_octree=OFF \
        -DBUILD_outofcore=OFF \
        -DBUILD_people=OFF \
        -DBUILD_recognition=OFF \
        -DBUILD_registration=OFF \
        -DBUILD_sample_consensus=OFF \
        -DBUILD_search=OFF \
        -DBUILD_segmentation=OFF \
        -DBUILD_stereo=OFF \
        -DBUILD_surface=OFF \
        -DBUILD_tools=OFF \
        -DBUILD_tracking=OFF \
        -DBUILD_visualization=OFF \
        $PCL_DIR
  # Build
  make -j2
}

function test_all ()
{
  # Configure
  mkdir $BUILD_DIR && cd $BUILD_DIR
  cmake -DCMAKE_C_FLAGS="$CMAKE_C_FLAGS" -DCMAKE_CXX_FLAGS="$CMAKE_CXX_FLAGS" \
        -DPCL_ONLY_CORE_POINT_TYPES=ON \
        -DBUILD_tools=OFF \
        -DBUILD_examples=OFF \
        -DBUILD_apps=OFF \
        -DBUILD_simulation=OFF \
        -DBUILD_stereo=OFF \
        -DBUILD_tracking=OFF \
        -DBUILD_global_tests=ON \
        $PCL_DIR
  # Build and run tests
  make -j2 tests
}

function doc ()
{
  # Do not generate documentation for pull requests
  if [[ $TRAVIS_PULL_REQUEST != 'false' ]]; then exit; fi
  # Install sphinx
  pip3 install --user sphinx pyparsing==2.1.9 sphinxcontrib-doxylink
  # Configure
  mkdir $BUILD_DIR && cd $BUILD_DIR
  cmake -DDOXYGEN_USE_SHORT_NAMES=OFF \
        -DSPHINX_HTML_FILE_SUFFIX=php \
        -DWITH_DOCS=ON \
        -DWITH_TUTORIALS=ON \
        $PCL_DIR

  git config --global user.email "documentation@pointclouds.org"
  git config --global user.name "PointCloudLibrary (via TravisCI)"

  if [ -z "$id_rsa_{1..23}" ]; then echo 'No $id_rsa_{1..23} found !' ; exit 1; fi

  echo -n $id_rsa_{1..23} >> ~/.ssh/travis_rsa_64
  base64 --decode --ignore-garbage ~/.ssh/travis_rsa_64 > ~/.ssh/id_rsa

  chmod 600 ~/.ssh/id_rsa

  echo -e "Host github.com\n\tStrictHostKeyChecking no\n" >> ~/.ssh/config

  cd $DOC_DIR
  git clone git@github.com:PointCloudLibrary/documentation.git .

  # Generate documentation and tutorials
  cd $BUILD_DIR
  make doc tutorials advanced

  # Upload to GitHub if generation succeeded
  if [[ $? == 0 ]]; then
    # Copy generated tutorials to the doc directory
    cp -r $TUTORIALS_DIR/* $DOC_DIR/tutorials
    cp -r $ADVANCED_DIR/* $DOC_DIR/advanced
    # Commit and push
    cd $DOC_DIR
    git add --all
    git commit --amend --reset-author -m "Documentation for commit $TRAVIS_COMMIT" -q
    git push --force
  else
    exit 2
  fi
}

case $1 in
  before-install ) before_install;;
  build ) build;;
  build-examples ) build_examples;;
  build-tools ) build_tools;;
  build-apps ) build_apps;;
  test ) test_all;;
  doc ) doc;;
esac
