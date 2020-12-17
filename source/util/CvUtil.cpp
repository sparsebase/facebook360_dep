/**
 * Copyright 2004-present Facebook. All Rights Reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#include "source/util/CvUtil.h"

#include <fstream>
#include <string>
#include <vector>

#include <boost/format.hpp>
#include <glog/logging.h>

namespace fb360_dep {
namespace cv_util {

using namespace math_util;

cv::Mat imreadExceptionOnFail(const filesystem::path& filename, const int flags) {
  CHECK_NE(filename.extension(), ".pfm")
      << boost::format("Cannot imread .pfm with OpenCV: %1%") % filename.string();
  const cv::Mat image = cv::imread(filename.string(), flags);
  CHECK(!image.empty()) << boost::format("failed to load image: %1%") % filename.string();
  return image;
}

void imwriteExceptionOnFail(
    const filesystem::path& filename,
    const cv::Mat& image,
    const std::vector<int>& params) {
  CHECK(imwrite(filename.string(), image, params))
      << boost::format("failed to save image: %1%") % filename.string();
}

void writeCvMat32FC1ToPFM(const filesystem::path& path, const cv::Mat_<float>& m) {
  const int height = m.rows;
  const int width = m.cols;

  std::ofstream file(path.string(), std::ios::binary);
  file << "Pf\n";
  file << width << " " << height << "\n";
  file << "-1.0\n";
  CHECK_EQ(m.step[0], width * sizeof(float)) << "expected contiguous float Mat";
  file.write((char*)m.ptr(), width * height * sizeof(float));
}

cv::Mat_<float> readCvMat32FC1FromPFM(const filesystem::path& path) {
  std::ifstream file(path.string(), std::ios::binary);

  CHECK(file.good()) << "cannot load file: " << path;

  std::string format;
  getline(file, format);
  CHECK_EQ(format, "Pf") << boost::format(
      "expected 'Pf' in 1-channel .pfm file header: %1%") % path.string();

  int width, height;
  file >> width >> height;

  double endian;
  file >> endian;
  CHECK_LE(endian, 0.0) << boost::format(
      "only little endian .pfm files supported: %1%") % path.string();
  file.ignore(); // eat newline

  cv::Mat_<float> m(cv::Size(width, height));
  file.read((char*)m.ptr(), width * height * sizeof(float));
  return m;
}

} // namespace cv_util
} // namespace fb360_dep
