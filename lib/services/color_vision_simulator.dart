class ColorVisionSimulator {
  // Identity matrix
  static const List<double> identity = [
    1, 0, 0, 0, 0,
    0, 1, 0, 0, 0,
    0, 0, 1, 0, 0,
    0, 0, 0, 1, 0,
  ];

  // Protanopia matrix (Red-blind)
  static const List<double> protanopia = [
    0.567, 0.433, 0.000, 0, 0,
    0.558, 0.442, 0.000, 0, 0,
    0.000, 0.242, 0.758, 0, 0,
    0, 0, 0, 1, 0,
  ];

  // Deuteranopia matrix (Green-blind)
  static const List<double> deuteranopia = [
    0.625, 0.375, 0.000, 0, 0,
    0.700, 0.300, 0.000, 0, 0,
    0.000, 0.300, 0.700, 0, 0,
    0, 0, 0, 1, 0,
  ];

  // Tritanopia matrix (Blue-blind)
  static const List<double> tritanopia = [
    0.950, 0.050, 0.000, 0, 0,
    0.000, 0.433, 0.567, 0, 0,
    0.000, 0.475, 0.525, 0, 0,
    0, 0, 0, 1, 0,
  ];

  static List<double> interpolateMatrix(List<double> m1, List<double> m2, double t) {
    assert(m1.length == 20 && m2.length == 20);
    List<double> result = List.filled(20, 0.0);
    for (int i = 0; i < 20; i++) {
      result[i] = m1[i] + (m2[i] - m1[i]) * t;
    }
    return result;
  }

  static List<double> multiplyMatrices(List<double> a, List<double> b) {
    List<double> result = List.filled(20, 0.0);
    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 5; col++) {
        double sum = 0;
        for (int i = 0; i < 4; i++) {
          sum += a[row * 5 + i] * b[i * 5 + col];
        }
        if (col == 4) {
          sum += a[row * 5 + 4];
        }
        result[row * 5 + col] = sum;
      }
    }
    return result;
  }

  static List<double> calculateSimulationMatrix({
    required double redSensitivity,
    required double greenSensitivity,
    required double blueSensitivity,
  }) {
    // 1.0 sensitivity = Normal vision (strength 0.0)
    // 0.0 sensitivity = Full deficiency (strength 1.0)
    double protanStrength = 1.0 - redSensitivity;
    double deutanStrength = 1.0 - greenSensitivity;
    double tritanStrength = 1.0 - blueSensitivity;

    List<double> m1 = interpolateMatrix(identity, protanopia, protanStrength);
    List<double> m2 = interpolateMatrix(identity, deuteranopia, deutanStrength);
    List<double> m3 = interpolateMatrix(identity, tritanopia, tritanStrength);

    // Combine the matrices by multiplication
    List<double> combined = multiplyMatrices(m1, m2);
    combined = multiplyMatrices(combined, m3);

    return combined;
  }

  // Vision Correction (Daltonization approximate matrices)
  // These matrices enhance colors that are difficult to distinguish.
  // For simplicity, we apply an inverse-like boost based on the sensitivities.
  static List<double> calculateCorrectionMatrix({
    required double redSensitivity,
    required double greenSensitivity,
    required double blueSensitivity,
  }) {
    double protanStrength = 1.0 - redSensitivity;
    double deutanStrength = 1.0 - greenSensitivity;
    double tritanStrength = 1.0 - blueSensitivity;

    // A simple color enhancement approach: boost the channel that is deficient.
    // In a real daltonization algorithm, we'd shift colors from the invisible spectrum 
    // to the visible spectrum. Here we boost the deficient color contrast.
    List<double> result = List.from(identity);
    
    if (protanStrength > 0) {
      // Shift some red to green/blue to make it visible
      result[0] = 1.0; 
      result[1] = 0.5 * protanStrength; 
      result[2] = 0.5 * protanStrength;
    }
    if (deutanStrength > 0) {
      // Shift some green to red/blue
      result[5] = 0.5 * deutanStrength; 
      result[6] = 1.0; 
      result[7] = 0.5 * deutanStrength;
    }
    if (tritanStrength > 0) {
      // Shift some blue to red/green
      result[10] = 0.5 * tritanStrength; 
      result[11] = 0.5 * tritanStrength; 
      result[12] = 1.0;
    }

    return result;
  }
}
