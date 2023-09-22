#include <iostream>
#include <cmath>
#include <cstdio>

using namespace std;

int main()
{
    int c;
    int a;
    int b;
    cout << "Input a: ";
    scanf("%d", &a);
    cout << "Input b: ";
    scanf("%d", &b);
    c = (a * a) + (b * b);
    cout << "c = "<< sqrt(c);    
    return 0;
}
