#include <iostream>
#include <opencv2/opencv.hpp>
#include <unistd.h>

// TODO: cleanup

auto usage(char *argv[]) {
  std::cerr << "usage: " << argv[0]
            << " [-t threshold_factor] <input> [output=dithered.ext]"
            << std::endl;
  return 1;
}

int main(int argc, char *argv[]) {
  int opt;

  float threshold_factor = 1.0;

  while ((opt = getopt(argc, argv, "t:")) != -1) {
    switch (opt) {
    case 't':
      threshold_factor = std::atof(optarg);
      break;
    default:
      usage(argv);
      return 1;
    }
  }

  if (optind >= argc) {
    usage(argv);
    return 1;
  }

  auto path = std::string(argv[optind]);
  auto ext = path.substr(path.find_last_of(".") + 1);

  auto image = cv::imread(path);
  if (image.empty()) {
    std::cerr << "error: could not open image file" << std::endl;
    return 1;
  }

  // Bayer matrix, https://en.wikipedia.org/wiki/Ordered_dithering
  cv::Mat matrix = (cv::Mat_<float>(4, 4) << 0, 8, 2, 10, 12, 4, 14, 6, 3, 11,
                    1, 9, 15, 7, 13, 5);
  matrix /= 16;

  for (int y = 0; y < image.rows; y++) {
    for (int x = 0; x < image.cols; x++) {
      auto pixel = image.at<cv::Vec3b>(y, x);

      // Luma, https://en.wikipedia.org/wiki/Luma_%28video%29
      auto grayscale =
          0.2126 * pixel[2] + 0.7152 * pixel[1] + 0.0722 * pixel[0];

      auto threshold = matrix.at<float>(y % 4, x % 4) * 255 * threshold_factor;
      auto dithered = (grayscale > threshold) ? 255 : 0;

      image.at<cv::Vec3b>(y, x) = cv::Vec3b(dithered, dithered, dithered);
    }
  }

  cv::imwrite((optind + 1 < argc) ? argv[optind + 1] : "dithered." + ext,
              image);
  image.release();

  return 0;
}
