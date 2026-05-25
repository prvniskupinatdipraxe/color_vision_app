class ColorVisionSimulator {
  // Identity matrix
  static const List<double> identity = [
    1, 0, 0, 0, 0,
    0, 1, 0, 0, 0,
    0, 0, 1, 0, 0,
    0, 0, 0, 1, 0,
  ];

  // Scientifically accurate matrices for sRGB simulation (Machado et al. 2009)
  // These matrices simulate how dichromatic vision affects color perception in the sRGB space.
  
  // Protanopia matrix (Red-blind / Red cones missing)
  static const List<double> protanopia = [
    0.152286, 1.052583, -0.204868, 0, 0,
    0.114503, 0.786281, 0.099216, 0, 0,
    -0.003882, -0.048116, 1.051998, 0, 0,
    0, 0, 0, 1, 0,
  ];

  // Deuteranopia matrix (Green-blind / Green cones missing)
  static const List<double> deuteranopia = [
    0.625, 0.375, 0.0, 0, 0,
    0.700, 0.300, 0.0, 0, 0,
    0.000, 0.300, 0.700, 0, 0,
    0, 0, 0, 1, 0,
  ];

  // Tritanopia matrix (Blue-blind / Blue cones missing)
  static const List<double> tritanopia = [
    0.950, 0.050, 0.000, 0, 0,
    0.000, 0.43333, 0.56667, 0, 0,
    0.000, 0.475, 0.525, 0, 0,
    0, 0, 0, 1, 0,
  ];

  /// Interpolates between two color matrices based on [t] (0.0 to 1.0).
  static List<double> interpolateMatrix(List<double> m1, List<double> m2, double t) {
    assert(m1.length == 20 && m2.length == 20);
    List<double> result = List.filled(20, 0.0);
    for (int i = 0; i < 20; i++) {
      result[i] = m1[i] + (m2[i] - m1[i]) * t;
    }
    return result;
  }

  /// Multiplies two 4x5 color matrices.
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

  /// Calculates a combined simulation matrix for anomalous trichromacy and dichromacy.
  static List<double> calculateSimulationMatrix({
    required double redSensitivity,
    required double greenSensitivity,
    required double blueSensitivity,
  }) {
    // 1.0 sensitivity = Normal vision (strength 0.0)
    // 0.0 sensitivity = Full deficiency (strength 1.0)
    double protanStrength = (1.0 - redSensitivity).clamp(0.0, 1.0);
    double deutanStrength = (1.0 - greenSensitivity).clamp(0.0, 1.0);
    double tritanStrength = (1.0 - blueSensitivity).clamp(0.0, 1.0);

    List<double> m1 = interpolateMatrix(identity, protanopia, protanStrength);
    List<double> m2 = interpolateMatrix(identity, deuteranopia, deutanStrength);
    List<double> m3 = interpolateMatrix(identity, tritanopia, tritanStrength);

    // Combine the matrices by multiplication to allow multi-deficiency simulation
    List<double> combined = multiplyMatrices(m1, m2);
    combined = multiplyMatrices(combined, m3);

    return combined;
  }

  /// Calculates a correction matrix (Daltonization) to enhance contrast.
  static List<double> calculateCorrectionMatrix({
    required double redSensitivity,
    required double greenSensitivity,
    required double blueSensitivity,
  }) {
    double protanStrength = (1.0 - redSensitivity).clamp(0.0, 1.0);
    double deutanStrength = (1.0 - greenSensitivity).clamp(0.0, 1.0);
    double tritanStrength = (1.0 - blueSensitivity).clamp(0.0, 1.0);

    // Simplified Daltonization matrix logic:
    // This shifts colors from the problematic spectrum into the visible spectrum
    // based on the specific type of deficiency.
    List<double> result = List.from(identity);
    
    if (protanStrength > 0) {
      // Protan correction: Boost green and blue to compensate for red loss
      result[0] = 1.0; 
      result[1] = 0.7 * protanStrength; 
      result[2] = 0.7 * protanStrength;
    }
    if (deutanStrength > 0) {
      // Deutan correction: Boost red and blue to compensate for green loss
      result[5] = 0.7 * deutanStrength; 
      result[6] = 1.0; 
      result[7] = 0.7 * deutanStrength;
    }
    if (tritanStrength > 0) {
      // Tritan correction: Boost red and green to compensate for blue loss
      result[10] = 0.7 * tritanStrength; 
      result[11] = 0.7 * tritanStrength; 
      result[12] = 1.0;
    }

    return result;
  }
}
