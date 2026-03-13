import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:login/form_styles.dart';

class MedicamentosMascota extends StatefulWidget {
  final String clienteId;
  final String mascotaId;

  const MedicamentosMascota({
    super.key,
    required this.clienteId,
    required this.mascotaId,
  });

  @override
  State<MedicamentosMascota> createState() => _MedicamentosMascotaState();
}

class _MedicamentosMascotaState extends State<MedicamentosMascota> {

  String filtro = "Hoy";

  final Map<int,bool> administrados = {};

  DateTime hoy = DateTime.now();

  bool _matchFecha(String fecha) {

    DateTime date = DateFormat('dd/MM/yyyy').parse(fecha);

    if(filtro == "Hoy"){
      return DateUtils.isSameDay(date,hoy);
    }

    if(filtro == "Mañana"){
      return DateUtils.isSameDay(
          date,
          hoy.add(const Duration(days:1))
      );
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {

    final consultasRef = FirebaseFirestore.instance
        .collection('clientes')
        .doc(widget.clienteId)
        .collection('mascotas')
        .doc(widget.mascotaId)
        .collection('consultas')
        .orderBy('timestamp', descending: true);

    return Scaffold(

      appBar: AppBar(

        leading: IconButton(
          icon: const Icon(Icons.arrow_back,color: Colors.white),
          onPressed: (){
            Navigator.pop(context);
          },
        ),

        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pets,color: Colors.white),
            SizedBox(width:8),
            Text("Medicamentos",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600)),
          ],
        ),

        centerTitle: true,
        elevation: 0,

        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3E6FB6),Color(0xFF1E3A6D)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),

      body: Container(

        decoration: const BoxDecoration(
          gradient: FormStyles.backgroundGradient,
        ),

        child: Column(
          children: [

            const SizedBox(height:10),

            /// FILTROS
            _filtros(),

            const SizedBox(height:10),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: consultasRef.snapshots(),
                builder: (context,snapshot){

                  if(!snapshot.hasData){
                    return const Center(child:CircularProgressIndicator());
                  }

                  List medicamentos = [];

                  for(var doc in snapshot.data!.docs){

                    final data = doc.data() as Map<String,dynamic>;

                    if(data['medicaciones']!=null){

                      for(var med in data['medicaciones']){

                        if(_matchFecha(data['fechaStr'])){

                          medicamentos.add({
                            "nombre": med['nombre'],
                            "dosis": med['dosis'],
                            "frecuencia": med['frecuencia'],
                            "fecha": data['fechaStr']
                          });

                        }

                      }

                    }

                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: medicamentos.length,
                    itemBuilder:(context,index){

                      final med = medicamentos[index];

                      return _medCard(index,med);

                    },
                  );

                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// FILTROS
  Widget _filtros(){

    return Container(

      margin: const EdgeInsets.symmetric(horizontal:16),
      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),

      child: Row(
        children: [

          const Icon(Icons.calendar_today,color:Colors.blue),

          const SizedBox(width:10),

          _filtroBtn("Hoy"),
          const SizedBox(width:8),
          _filtroBtn("Mañana"),

        ],
      ),
    );
  }

  Widget _filtroBtn(String text){

    bool active = filtro == text;

    return GestureDetector(

      onTap: (){
        setState(() {
          filtro = text;
        });
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds:300),
        padding: const EdgeInsets.symmetric(horizontal:14,vertical:6),

        decoration: BoxDecoration(
          color: active ? Colors.blue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),

        child: Text(
          text,
          style: TextStyle(
            color: active ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// CARD MEDICAMENTO
  Widget _medCard(int index,Map med){

    bool administrado = administrados[index] ?? false;

    return AnimatedContainer(

      duration: const Duration(milliseconds:400),

      margin: const EdgeInsets.only(bottom:18),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(
          color: administrado
              ? Colors.green
              : const Color(0xFF2A74D9),
          width: 1.5,
        ),

        boxShadow:[
          BoxShadow(
            blurRadius:12,
            color:Colors.black.withOpacity(.05),
            offset: const Offset(0,5),
          )
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              Row(
                children: [

                  const CircleAvatar(
                    radius:18,
                    backgroundColor:Color(0xFF2A74D9),
                    child:Icon(Icons.medication,color:Colors.white,size:18),
                  ),

                  const SizedBox(width:10),

                  Text(
                    med["frecuencia"],
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),

                ],
              ),

              _estadoChip(administrado),

            ],
          ),

          const SizedBox(height:14),

          Text(
            med["nombre"],
            style: const TextStyle(
                fontSize:16,
                fontWeight:FontWeight.w700),
          ),

          const SizedBox(height:4),

          Text(
            "Dosis: ${med["dosis"]}",
            style: const TextStyle(color:Colors.black54),
          ),

          const SizedBox(height:10),

          Row(
            children:[
              const Icon(Icons.access_time,size:18,color:Color(0xFF2A74D9)),
              const SizedBox(width:6),
              Text(med["fecha"])
            ],
          ),

          const SizedBox(height:14),

          AnimatedSwitcher(
            duration: const Duration(milliseconds:400),

            child: administrado
                ? Container(

                    key: const ValueKey("done"),

                    padding: const EdgeInsets.all(12),

                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(.1),
                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: const Row(
                      children:[
                        Icon(Icons.check,color:Colors.blue),
                        SizedBox(width:8),
                        Text("Administrado"),
                      ],
                    ),
                  )
                : SizedBox(

                    key: const ValueKey("btn"),

                    width: double.infinity,

                    child: ElevatedButton.icon(

                      icon: const Icon(Icons.check),

                      style: ElevatedButton.styleFrom(

                        padding: const EdgeInsets.symmetric(vertical:14),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),

                        backgroundColor: const Color(0xFF2A74D9),
                      ),

                      onPressed: (){
                        setState(() {
                          administrados[index] = true;
                        });
                      },

                      label: const Text(
                        "Marcar como administrado",
                        style: TextStyle(fontWeight:FontWeight.w600),
                      ),
                    ),
                  ),
          )
        ],
      ),
    );
  }

  Widget _estadoChip(bool administrado){

    if(administrado){

      return Container(
        padding: const EdgeInsets.symmetric(horizontal:10,vertical:4),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          "completada",
          style: TextStyle(
              color: Colors.blue,
              fontSize:12,
              fontWeight: FontWeight.w600),
        ),
      );

    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal:10,vertical:4),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text(
        "pendiente",
        style: TextStyle(
            color: Colors.orange,
            fontSize:12,
            fontWeight: FontWeight.w600),
      ),
    );
  }
}