import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Simulamos una lista con mensajes para este ejemplo
    final List<String> messages = ['Mensaje 1', 'Mensaje 2', 'Mensaje 3'];
    final bool isEmpty = messages.isEmpty;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          // Barra superior fija
          Container(
            width: double.infinity,
            height: size.height * 0.2,
            color: Colors.amber,
            child: Center(
              child: Text(
                "Chat App",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // Lista con scroll que se ajusta automáticamente
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.blue,
              child:
                  isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 80,
                              color: Colors.white,
                            ),
                            SizedBox(height: 16),
                            Text(
                              "No hay mensajes aún",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Escribe tu primer mensaje abajo",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      )
                      : Column(
                        children: [
                          // Lista de mensajes con scroll
                          Expanded(
                            child: ListView.builder(
                              itemCount: messages.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text('Mensaje ${index + 1}'),
                                  subtitle: Text(
                                    'Detalles del mensaje ${index + 1}',
                                  ),
                                );
                              },
                            ),
                          ),

                          // Mensaje fijo en la parte inferior de la lista
                          Container(
                            width: double.infinity,
                            height: size.height * 0.07,
                            color: Colors.lightBlue,
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(
                                  Icons.volunteer_activism,
                                  color: Colors.white,
                                ),
                                Text(
                                  "¡Tenga un buen día!",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(Icons.emoji_emotions, color: Colors.white),
                              ],
                            ),
                          ),
                        ],
                      ),
            ),
          ),

          // Área de entrada fija
          Container(
            height: size.height * 0.2,
            width: double.infinity,
            padding: EdgeInsets.all(8),
            color: Colors.amber,
            child: TextFormField(
              decoration: InputDecoration(
                hintText: "Escribe un mensaje...",
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: Icon(Icons.send),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
