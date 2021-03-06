require File.expand_path("../Abstract/portable-formula", __dir__)

class PortableReadline < PortableFormula
  desc "Library for command-line editing"
  homepage "https://tiswww.case.edu/php/chet/readline/rltop.html"
  url "https://ftpmirror.gnu.org/readline/readline-8.0.tar.gz"
  mirror "https://ftp.gnu.org/gnu/readline/readline-8.0.tar.gz"
  sha256 "e339f51971478d369f8a053a330a190781acb9864cf4c541060f12078948e461"

  depends_on "portable-ncurses" => :build if OS.linux?

  def install
    system "./configure", "--prefix=#{prefix}",
                          "--enable-multibyte",
                          "--enable-static",
                          "--disable-shared",
                          ("--with-curses" if OS.linux?)
    args = []
    args << "SHLIB_LIBS=-lcurses" if OS.linux?
    system "make", "install", *args
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <stdio.h>
      #include <stdlib.h>
      #include <readline/readline.h>

      int main()
      {
        printf("%s\\n", readline("test> "));
        return 0;
      }
    EOS
    args = %W[test.c -I#{include} -L#{lib} -lreadline -lncurses -o test]
    if OS.linux?
      ncurses = Formula["portable-ncurses"]
      args += %W[-I#{ncurses.include} -L#{ncurses.lib}]
    end
    system ENV.cc, *args
    assert_equal "test> Hello, World!\nHello, World!",
      pipe_output("./test", "Hello, World!\n").strip
  end
end
