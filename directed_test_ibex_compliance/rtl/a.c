#include <stdio.h>
 
int main() {
    for (unsigned int i = 0x000; i <= 0x1FF; i++) {
        printf("%03X00013\n", i);
    }
}