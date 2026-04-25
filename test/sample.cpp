// sample.cpp —— smoke test fixture
#include <cstdio>

int add(int a, int b) {
    return a + b;
}

int main() {
    int result = add(2, 3);
    std::printf("result = %d\n", result);
    return 0;
}
