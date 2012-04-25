// http://stackoverflow.com/questions/80875
#include <stdio.h>

int main(int argc, char *argv[])
{
   if (argc != 2) {
      return 1;
    }
   int ret = unlink(argv[1]);
   if (ret != 0) {
      perror("unlink");
    }
   return ret;
}

