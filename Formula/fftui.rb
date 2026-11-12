class Fftui < Formula
  desc "Terminal interface for FFmpeg"
  homepage "https://github.com/part-avocado/fftui"
  url "https://github.com/part-avocado/fftui/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "85090565c11d90e714fb8424246b7a2c9b959c2a27f9a98fe88c3b8375ba6bb2"
  license "MIT"
  head "https://github.com/part-avocado/fftui.git", branch: "main"

  depends_on "go" => :build
  depends_on "ffmpeg"

  def install
    system "go", "build", *std_go_args(ldflags: "-X main.version=#{version}"), "./cmd/fftui"
  end

  test do
    assert_equal "fftui #{version}", shell_output("#{bin}/fftui --version").strip
  end
end
