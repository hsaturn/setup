#include <iostream>
#include <map>
#include <vector>
#include <unistd.h>

using namespace std;

int main(int argc, const char* argv[])
{
    while(true)
    {
        sleep(1);
        cout << "Allocated 10.000 bytes." << malloc(10000) << endl;
    }
	return 0;
}


