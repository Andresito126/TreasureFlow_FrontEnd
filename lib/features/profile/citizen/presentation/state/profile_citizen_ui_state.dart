/// Enums de estado presentacional de la feature `profile/citizen`, centralizados
/// aquí para que el provider no los declare sueltos. `ProfilePostsProvider`
/// los reexporta con `export`, así que las pantallas que ya los importaban a
/// través del provider no necesitan cambiar nada.
library;

enum MyPostsStatus { idle, loading, success, error }

enum DeletePostStatus { idle, deleting, done, error }
