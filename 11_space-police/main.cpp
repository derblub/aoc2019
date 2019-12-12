
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

  PyObject *pName, *pModule, *pDict, *pClass, *pInstance, *pFunc, *pValue, *presult;

  pName = PyUnicode_FromString("IntCodeComputer");
  pModule = PyImport_Import(pName);
  pDict = PyModule_GetDict(pModule);
  pClass = PyDict_GetItemString(pDict, "IntCodeComputer");

  if (PyCallable_Check(pClass)){
      pInstance = PyObject_CallObject(pClass, NULL);
  }else{
      std::cout << "Cannot instantiate IntCodeComputer" << std::endl;
  }

  Py_DECREF(pModule);
  Py_DECREF(pName);
  Py_DECREF(pValue);

  presult = PyObject_CallMethod(pInstance, "load_intcode", "input.txt");
  if (presult)
      Py_DECREF(presult);
  else
      PyErr_Print();


  printf("output: %ld\n", PyUnicode_FromObject(presult));

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
