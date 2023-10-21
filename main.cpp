#include <iostream>
#include <opencv2/opencv.hpp>

int main(int argc, char *argv[]) {
  if (argc < 2) {
    std::cerr << "usage: " << argv[0] << " <input> [output=dithered.ext]" << std::endl;
    return 1;
  }

  auto path = std::string(argv[1]);
  auto image = cv::imread(path);
  // auto ext = std::string(argv[1]).substr(std::string(argv[1]).find_last_of(".") + 1);
  auto ext = path.substr(path.find_last_of(".") + 1);

  if (image.empty()) {
    std::cerr << "error: could not open image file" << std::endl;
    return 1;
  }

  // Bayer matrix, https://en.wikipedia.org/wiki/Ordered_dithering
  cv::Mat matrix = (cv::Mat_<float>(4, 4) << 0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5);
  matrix /= 16;

  for (int y = 0; y < image.rows; y++) {
    for (int x = 0; x < image.cols; x++) {
      auto pixel = image.at<cv::Vec3b>(y, x);

      // Luma, https://en.wikipedia.org/wiki/Luma_%28video%29
      auto grayscale =
          0.2126 * pixel[2] + 0.7152 * pixel[1] + 0.0722 * pixel[0];

      auto threshold = matrix.at<float>(y % 4, x % 4) * 255;
      auto dithered = (grayscale > threshold) ? 255 : 0;

      image.at<cv::Vec3b>(y, x) = cv::Vec3b(dithered, dithered, dithered);
    }
  }

  cv::imwrite(argv[2] ? argv[2] : std::string("dithered.") + ext, image);
  image.release();
  
  return 0;
}
