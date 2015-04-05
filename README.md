# HackerBooks

Repositorio de la practica del curso AGBO Fundamentos iOS

**Procesado de JSON**

diferencias entre isKindOfClass y isMemberOfClass

*isKindOfClass*: Devuelve YES si recive una instancia de la clase especificada o bien de alguna clase que herede de la clase especificada.

*isMemberOfClass*: Devuelve YES unicamente si recive una instancia de de la clase especificada.


**Modelo**

Los datos descargados de portada y PDF los guardo en el directorio de cache de la aplicacion, ya que si por cualquier motivo el iDevice considera que deber borrarlos, se descargan de nuevo automaticamente.


**Tabla de libros**

*Como almaceno los libros favoritos:* Los almaceno en un diccionario que guardo en NSDefauts, dicho diccionario se va actualizando cada vez que hay algun cambio

*¿Se me ocurre mas de una forma de hacerlo?* si, se podria hacer tambien almacenandolo usando bases de datos 

 *El aviso desde AGTBook a un AGTLibraryTableViewController:*Solo mediante notificaciones pues en este caso el delegado no podría ser.

*¿Es una aberracion cargar los libros de nuevo?* No porque solo carga lo que se está utilizando.

**Controlador de PDF**

¿como se cuando el usuario cambia de libro? Mediante una notificacion  

