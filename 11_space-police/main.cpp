
// https://adventofcode.com/2019/day/11

//   g++ -o main main.cpp $(pkg-config --cflags --libs python3) -lpython3.8 && ./main

#include <Python.h>
#include <iostream>
#include <map>
#include <vector>
#include <unordered_map>


int main() {

  // Set PYTHONPATH TO working directory
  setenv("PYTHONPATH", "../lib/", 1);

  PyObject *pName, *pModule, *pDict, *pFunc, *pValue, *presult;

   // Initialize the Python Interpreter
   Py_Initialize();

  PyObject* module = PyImport_ImportModule("intcode");
  assert(module != NULL);

  PyObject* klass = PyObject_GetAttrString(module, "IntCodeComputer");
  assert(klass != NULL);

  // PyObject* instance = PyInstance_New(klass, NULL, NULL);
  // assert(instance != NULL);
  PyObject* main_mod = PyMapping_GetItemString(module, "IntCodeComputer");

  PyObject* result = PyObject_CallMethod(main_mod, "load_intcode", "input.txt");
  // assert(result != NULL);

  printf("output: %ld\n", PyLong_AsLong(result));

  Py_Finalize();



  // std::vector<long long int> intcode;
  // std::string input = "input.txt";
  //
  // // intcode = IntCodeComputer.load_intcode(args.intcode
  // // computer = IntCodeComputer(input))
  // std::unordered_map<std::pair<int,int>, char, PointHash> pointColorMap; //. -> black, # -> white
  // char dirs[] = {'^', '>', 'v', '<'};
  //
  // int curDir = 0;
  // std::pair<int,int> curPoint = std::make_pair(0, 0);
  // while(!computer.wait_for_input){
  //     // computer.start_program(intcode, [0])
  //     auto pointIt = pointColorMap.find(curPoint);
  //     char curColor = (pointIt != pointColorMap.end() ? pointIt->second : '.');
  //     // int paintWhite = computer.step_program([int(curColor)])
  //     // int turnRight = computer.step_program()
  //
  //     //paint
  //     pointColorMap[curPoint] = (paintWhite ? '#' : '.');
  //
  //     //rotate
  //     if(turnRight) curDir++;
  //     else curDir--;
  //
  //     if(curDir < 0) curDir = 3;
  //     if(curDir > 3) curDir = 0;
  //
  //     //move
  //     switch(dirs[curDir]){
  //         case '^': curPoint.second++; break;
  //         case 'v': curPoint.second--; break;
  //         case '<': curPoint.first--; break;
  //         case '>': curPoint.first++; break;
  //     }
  // }
  //
  // std::cout << "output: " << pointColorMap.size() << std::endl;
}
