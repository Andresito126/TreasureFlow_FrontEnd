class MaterialTypeTranslator {
  static const Map<String, String> _translations = {
    'aluminum': 'Aluminio',
    'oil': 'Aceite',
    'paper': 'Papel/Cartón',
    'cardboard': 'Papel/Cartón',
    'plastic': 'Plástico',
    'metal': 'Metal',
    'battery': 'Pila/Batería',
  };

  static String translate(String materialName) {
    return _translations[materialName.toLowerCase()] ?? materialName;
  }
}
