// import 'package:flutter/material.dart';
// import 'package:myflutter/api/db_op.dart';
// import 'package:myflutter/models/peak.dart';

// class PopularPeaksPage extends StatefulWidget {
//   const PopularPeaksPage({Key? key}) : super(key: key);

//   @override
//   State<PopularPeaksPage> createState() => _PopularPeaksPageState();
// }

// class _PopularPeaksPageState extends State<PopularPeaksPage> {
//   List<Peak> popularPeaks = [];
//   final dbOperations = DbOperations.fromSettings();
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     loadPopularPeaks();
//   }

//   Future<void> loadPopularPeaks() async {
//     List<Map<String, dynamic>> data = await dbOperations.loadByPopularTag();
//     List<Peak> loadedPeaks = data.map((map) => Peak.fromMap(map)).toList();
//     setState(() {
//       popularPeaks = loadedPeaks;
//       isLoading = false;
//     });
//   }

//   void removePeak(Peak peak) async {
//     await dbOperations.removeElement(peak.key!);
//     setState(() {
//       popularPeaks.remove(peak);
//     });
//   }

//   void navigateToAddPage() async {
//     var result = await Navigator.pushNamed(context, '/add');
//     if (result is bool && result == true) {
//       loadPopularPeaks();
//     }
//   }

//   void navigateToEditPage(Peak peak) async {
//     var result = await Navigator.pushNamed(context, '/edit', arguments: peak);
//     if (result is bool && result == true) {
//       loadPopularPeaks();
//     }
//   }

//   void navigateToViewPage(Peak peak) async {
//     var result = await Navigator.pushNamed(context, '/view', arguments: peak);
//     if (result is bool && result == true) {
//       loadPopularPeaks();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Popular Peaks'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.add),
//             onPressed: () {
//               navigateToAddPage();
//             },
//           ),
//         ],
//       ),
//       body: Center(
//         child:
//             isLoading
//                 ? CircularProgressIndicator()
//                 : ListView.builder(
//                   itemCount: popularPeaks.length,
//                   itemBuilder: (context, index) {
//                     Peak peak = popularPeaks[index];
//                     return Dismissible(
//                       key: Key(peak.key!),
//                       onDismissed: (direction) {
//                         removePeak(peak);
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text('Peak removed')),
//                         );
//                       },
//                       child: ListTile(
//                         leading:
//                             peak.imagePath != null && peak.imagePath!.isNotEmpty
//                                 ? Image.network(peak.imagePath!)
//                                 : Image.asset('assets/default.png'),
//                         title: Text(peak.name),
//                         subtitle: Text('${peak.elevation} m, ${peak.location}'),
//                         onTap: () {
//                           navigateToViewPage(peak);
//                         },

//                         trailing: Row(
//                           // Wrap trailing widgets in a Row
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             if (peak
//                                 .isPopular) // Conditionally show the yellow box
//                               Container(
//                                 padding: EdgeInsets.symmetric(
//                                   horizontal: 8,
//                                   vertical: 4,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: Colors.yellow,
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                                 child: Text("Popular"),
//                               ),
//                             IconButton(
//                               icon: Icon(Icons.edit),
//                               onPressed: () {
//                                 navigateToEditPage(peak);
//                               },
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//       ),
//     );
//   }
// }
