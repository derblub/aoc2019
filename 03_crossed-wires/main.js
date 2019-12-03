// https://adventofcode.com/2019/day/3

const fs = require('fs');


let input = fs.readFileSync('input.txt').toString().split('\n');
let getSegments = (start, dir, count) => {
  let segs = [];
  let current = start.slice();
  for (let i=0; i<count; i++){
    current[2]++;
    switch (dir){
      case 'R':
        current[0]++;
        segs.push(current.slice());
        break;
      case 'L':
        current[0]--;
        segs.push(current.slice());
        break;
      case 'U':
        current[1]++;
        segs.push(current.slice());
        break;
      case 'D':
        current[1]--;
        segs.push(current.slice());
        break;
      }
  }
  return segs;
}

let paths = [];
for (let p=0; p<input.length; p++){
  paths.push(
    input[p].split(',').map(
      x => [x.substring(0,1), x.substring(1)]
    )
  )
}

let wires = [];
for (let x=0; x<paths.length; x++){
  wires.push([[0,0,0]]);
  for (let y=0; y<paths[x].length; y++){
    wires[x].push(
      ... getSegments(
        wires[x][wires[x].length-1],
        paths[x][y][0],
        paths[x][y][1]
      )
    );
  }
}

let intersections = [];
for (let x=0; x<wires[0].length; x++){
  for (let y=0; y<wires[1].length; y++){
    if (wires[0][x][0] === wires[1][y][0] && wires[0][x][1] === wires[1][y][1]){
      intersections.push({
        location: wires[0][x],
        distance: Math.abs(0-wires[0][x][0]) + Math.abs(wires[0][x][1]-0),
        steps: wires[0][x][2] + wires[1][y][2]
      });

    }
  }
}

// manhattan distance to closest intersection
intersections.sort((a,b) => (a.distance > b.distance) ? 1 : -1);
console.log(`output: ${intersections[1].distance}`);

// fewest steps to intersection
intersections.sort((a,b) => (a.steps > b.steps) ? 1 : -1);
console.log(`output p2: ${intersections[1].steps}`);
