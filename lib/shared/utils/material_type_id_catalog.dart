class MaterialTypeIdCatalog {
  static const Map<String, String> _names = {
    'e78a20e5-a69d-4edb-bf50-33831f9aae6e': 'Aluminio',
    '2e532ca8-c6de-465d-af27-c2465b74f14c': 'Aceite',
    '1be3bf83-8b1a-421c-8474-a72785bf80b5': 'Papel/Cartón',
    'caa8cf7a-d5f6-4ae6-a9aa-ea92bdf4b334': 'Plástico',
    '918a523e-655b-4f53-bd86-2d43c2618be5': 'Metal',
    '37962e6b-8f0a-4dd7-9e5d-0db74d021313': 'Pila/Batería',
  };

  static String nameOf(String materialTypeId) =>
      _names[materialTypeId] ?? 'Material';
}
