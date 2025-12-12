// lib/models/filter_config_model.dart

class FilterConfig {
  static final List<String> filtros = [
    "ninguno",
    "emboss",
    "sobel",
    "gauss",
    "sharpen",
    "sombras_epico",
    "resaltado_frio",
    "marco"
  ];

  static final Map<String, List<String>> filtrosParametros = {
    "emboss": ["offset", "factor"],
    "sobel": ["factor"],
    "gauss": ["sigma"],
    "sharpen": ["sharp_factor"],
    "sombras_epico": ["highlight_boost", "vignette_strength"],
    "resaltado_frio": ["blue_boost", "contrast"],
    "marco": [],
  };

  static final Map<String, Map<String, List<double>>> rangosParametros = {
    "emboss": {
      "offset": [0.0, 255.0],
      "factor": [1.0, 5.0],
    },
    "sobel": {
      "factor": [1.0, 5.0],
    },
    "gauss": {
      "sigma": [1.0, 200.0],
    },
    "sharpen": {
      "sharp_factor": [1.0, 50.0],
    },
    "sombras_epico": {
      "highlight_boost": [0.1, 3.0],
      "vignette_strength": [0.0, 1.0],
    },
    "resaltado_frio": {
      "blue_boost": [0.0, 3.0],
      "contrast": [0.5, 3.0],
    },
  };

  static final Map<String, Map<String, double>> valoresDefecto = {
    "emboss": {"offset": 128.0, "factor": 2.0},
    "sobel": {"factor": 2.0},
    "gauss": {"sigma": 90.0},
    "sharpen": {"sharp_factor": 20.0},
    "sombras_epico": {"highlight_boost": 1.1, "vignette_strength": 0.5},
    "resaltado_frio": {"blue_boost": 1.2, "contrast": 1.3},
    "marco": {},
  };
}
