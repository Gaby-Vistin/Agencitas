import 'package:flutter/material.dart';

// Importar las provincias desde appointment_scheduling_screen
class Province {
  final String name;
  final String capital;
  final String code;

  const Province({
    required this.name,
    required this.capital,
    required this.code,
  });

  String get displayName => '$name: $capital';

  @override
  String toString() => displayName;
}

// Lista de provincias del Ecuador
const List<Province> ecuadorianProvinces = [
  Province(name: 'El Oro', capital: 'Machala', code: 'EL_ORO'),
  Province(name: 'Esmeraldas', capital: 'Esmeraldas', code: 'ESMERALDAS'),
  Province(name: 'Guayas', capital: 'Guayaquil', code: 'GUAYAS'),
  Province(name: 'Los Ríos', capital: 'Babahoyo', code: 'LOS_RIOS'),
  Province(name: 'Manabí', capital: 'Portoviejo', code: 'MANABI'),
  Province(name: 'Santa Elena', capital: 'Santa Elena', code: 'SANTA_ELENA'),
  Province(name: 'Santo Domingo de los Tsáchilas', capital: 'Santo Domingo', code: 'SANTO_DOMINGO'),
  Province(name: 'Azuay', capital: 'Cuenca', code: 'AZUAY'),
  Province(name: 'Bolívar', capital: 'Guaranda', code: 'BOLIVAR'),
  Province(name: 'Cañar', capital: 'Azogues', code: 'CANAR'),
  Province(name: 'Carchi', capital: 'Tulcán', code: 'CARCHI'),
  Province(name: 'Chimborazo', capital: 'Riobamba', code: 'CHIMBORAZO'),
  Province(name: 'Cotopaxi', capital: 'Latacunga', code: 'COTOPAXI'),
  Province(name: 'Imbabura', capital: 'Ibarra', code: 'IMBABURA'),
  Province(name: 'Loja', capital: 'Loja', code: 'LOJA'),
  Province(name: 'Pichincha', capital: 'Quito', code: 'PICHINCHA'),
  Province(name: 'Tungurahua', capital: 'Ambato', code: 'TUNGURAHUA'),
  Province(name: 'Sucumbíos', capital: 'Nueva Loja', code: 'SUCUMBIOS'),
  Province(name: 'Napo', capital: 'Tena', code: 'NAPO'),
  Province(name: 'Orellana', capital: 'Francisco de Orellana', code: 'ORELLANA'),
  Province(name: 'Pastaza', capital: 'Puyo', code: 'PASTAZA'),
  Province(name: 'Morona Santiago', capital: 'Macas', code: 'MORONA_SANTIAGO'),
  Province(name: 'Zamora Chinchipe', capital: 'Zamora', code: 'ZAMORA_CHINCHIPE'),
  Province(name: 'Provincia de Galápagos', capital: 'Puerto Baquerizo Moreno', code: 'GALAPAGOS'),
];

class ProvinceListScreen extends StatefulWidget {
  final Function(Province)? onProvinceSelected;

  const ProvinceListScreen({super.key, this.onProvinceSelected});

  @override
  State<ProvinceListScreen> createState() => _ProvinceListScreenState();
}

class _ProvinceListScreenState extends State<ProvinceListScreen> {
  List<Province> _filteredProvinces = ecuadorianProvinces;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterProvinces);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterProvinces);
    _searchController.dispose();
    super.dispose();
  }

  void _filterProvinces() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProvinces = ecuadorianProvinces.where((province) {
        return province.name.toLowerCase().contains(query) ||
               province.capital.toLowerCase().contains(query) ||
               province.code.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Provincia'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar provincia',
                hintText: 'Escriba el nombre de la provincia...',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
              ),
            ),
          ),
          
          // Lista de provincias
          Expanded(
            child: _filteredProvinces.isEmpty
                ? const Center(
                    child: Text(
                      'No se encontraron provincias',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredProvinces.length,
                    itemBuilder: (context, index) {
                      final province = _filteredProvinces[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Icon(
                              Icons.location_on,
                              color: Theme.of(context).colorScheme.primary,
                              size: 24,
                            ),
                          ),
                          title: Text(
                            province.displayName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            'Código: ${province.code}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey[400],
                          ),
                          onTap: () {
                            if (widget.onProvinceSelected != null) {
                              widget.onProvinceSelected!(province);
                            } else {
                              Navigator.of(context).pop(province);
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}