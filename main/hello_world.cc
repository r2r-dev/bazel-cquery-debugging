#include <ctime>
#include <string>
#include <iostream>
#include <thread>

thread_local int i=0;

void f(int newval){
    i=newval;
}

void g(){
    std::cout<< i << "|";
}

void threadfunc(int id){
    f(id);
    ++i;
    g();
}

int main(){
    i=9;
    std::thread t1(threadfunc,1);
    std::thread t2(threadfunc,2);
    std::thread t3(threadfunc,3);

    t1.join();
    t2.join();
    t3.join();
    std::cout<<i<<std::endl;

    //output: 2|3|4|9
}
