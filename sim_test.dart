void main() {
  var deutan = [
    0.367322, 0.860646, -0.227968,
    0.280085, 0.672501, 0.047413,
    -0.011820, 0.042940, 0.968881,
  ];
  
  var rgb = [255, 0, 0];
  print("Red to Deutan: ${deutan[0]*rgb[0] + deutan[1]*rgb[1] + deutan[2]*rgb[2]}, ${deutan[3]*rgb[0] + deutan[4]*rgb[1] + deutan[5]*rgb[2]}, ${deutan[6]*rgb[0] + deutan[7]*rgb[1] + deutan[8]*rgb[2]}");

  rgb = [0, 255, 0];
  print("Green to Deutan: ${deutan[0]*rgb[0] + deutan[1]*rgb[1] + deutan[2]*rgb[2]}, ${deutan[3]*rgb[0] + deutan[4]*rgb[1] + deutan[5]*rgb[2]}, ${deutan[6]*rgb[0] + deutan[7]*rgb[1] + deutan[8]*rgb[2]}");
}
