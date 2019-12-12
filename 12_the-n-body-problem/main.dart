
 // https://adventofcode.com/2019/day/12

 //    dart main.dart

import 'dart:io';


var steps = 1000;


class Moon{
  int x, y, z;
  int vel_x = 0, vel_y = 0, vel_z = 0;

  Moon(this.x, this.y, this.z);

  apply_gravity(Moon a){
    if (x<a.x){ vel_x++; a.vel_x--; }
    if (x>a.x){ vel_x--; a.vel_x++; }
    if (y<a.y){ vel_y++; a.vel_y--; }
    if (y>a.y){ vel_y--; a.vel_y++; }
    if (z<a.z){ vel_z++; a.vel_z--; }
    if (z>a.z){ vel_z--; a.vel_z++; }
  }

  void apply_velocity(){
    x += vel_x;
    y += vel_y;
    z += vel_z;
  }

  int get total_energy{
    return (x.abs() + y.abs() + z.abs()) * (vel_x.abs() + vel_y.abs() + vel_z.abs());
  }
}


void simulate_path(List<Moon> moons){
  for (var i=0; i<moons.length; i++){
    for (var j=i+1; j<moons.length; j++){
      moons[i].apply_gravity(moons[j]);
    }
  }
  for (var moon in moons){
    moon.apply_velocity();
  }
}


int find_period(List<int> vector){
  var start = vector.toString();
  var it = 0;
  do {
    for (var i=0; i<4; i++){
      for (var j=i+1; j<4; j++){
        if (vector[i+4] < vector[j+4]){ vector[i]++; vector[j]--; }
        if (vector[i+4] > vector[j+4]){ vector[i]--; vector[j]++; }
      }
    }
    for (var i=0; i<4; i++){ vector[i+4] += vector[i]; }
    it++;
    if (vector.toString() == start){
      return it;
    }

  } while (true);
}


Future<void> main() async {
  var input = File('input.txt');
  if (await input.exists()){
    var data = await input.readAsLines();
    var moons = List<Moon>();
    var xs = [0,0,0,0], ys = [0,0,0,0], zs = [0,0,0,0];
    for (var position in data){
      var matches = RegExp('(-?[0-9]+)').allMatches(position);
      var coo = matches.map((m) => int.parse(m.group(0))).toList();
      moons.add(Moon(coo[0], coo[1], coo[2]));
      xs.add(coo[0]);
      ys.add(coo[1]);
      zs.add(coo[2]);
    }
    for (var i=0; i<steps; i++){
      simulate_path(moons);
    }
    var output = moons.fold(0, (a, b) => a + b.total_energy);
    print('output: $output');

    var period_x = find_period(xs);
    var period_y = find_period(ys);
    var period_z = find_period(zs);
    var period_xy = period_x * period_y ~/ period_x.gcd(period_y);
    var period_xyz = period_xy * period_z ~/ period_xy.gcd(period_z);
    print('output p2: $period_xyz');
  }
}
