import 'package:Wspend/getData/getDataRiwayat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String bulan = DateFormat.MMMM().format(DateTime.now());
  String tahun = DateFormat.y().format(DateTime.now());

  // Include 0 in the list
  num saldo = 0;
  num pengeluaran = 0;

  final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');
  List<int> angkaList = [];
  List<int> riwayatList = [];
  int visibleRiwayatCount = 5;

  Future<QuerySnapshot<Object?>> getData2() async {
    QuerySnapshot<Object?> incomeSnapshot =
        await getDataRiwayat('income', angkaList, riwayatList);
    QuerySnapshot<Object?> expendsSnapshot =
        await getDataRiwayat('expends', angkaList, riwayatList);

    if (incomeSnapshot.docs.isNotEmpty) {
      return incomeSnapshot;
    } else {
      return expendsSnapshot;
    }
  }

  void sumsaldo() async {
    num income = await sumSaldo('income');
    num expends = await sumSaldo('expends');
    num p = await sumSaldoByMoth(bulan, 'expends', tahun);

    num total = income - expends;

    if (mounted) {
      setState(() {
        saldo = total;
        pengeluaran = p;
      });
    }
  }

  void loadMoreRiwayat() {
    setState(() {
      if (visibleRiwayatCount + 10 <= riwayatList.length) {
        visibleRiwayatCount += 10;
      } else {
        visibleRiwayatCount = riwayatList.length;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    sumsaldo();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.yellow[600], // Set full background color to yellow
        child: Scaffold(
          body: SafeArea(
              child: SingleChildScrollView(
            child: Container(
              height: 1000,
              color: Colors.yellow[600],
              child: Padding(
                padding: const EdgeInsets.only(
                    bottom: 30, left: 16, right: 16, top: 18),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Selamat bergabung dengan WeSpend",
                        style: GoogleFonts.roboto(
                          textStyle: const TextStyle(
                            fontSize: 20,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                    const SizedBox(height: 30),
                    Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(
                            143, 119, 119, 119), // Warna kotak
                        borderRadius: BorderRadius.circular(
                            10), // Melengkungkan sudut kotak
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Pengeluaran di bulan $bulan, $tahun",
                                style: GoogleFonts.roboto(
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 8, top: 20),
                                child: Text(formatCurrency.format(pengeluaran),
                                    style: GoogleFonts.roboto(
                                      textStyle: const TextStyle(
                                        fontSize: 20,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(
                            143, 119, 119, 119), // Warna kotak
                        borderRadius: BorderRadius.circular(
                            10), // Melengkungkan sudut kotak
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Saldo",
                              style: GoogleFonts.roboto(
                                  textStyle: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              )),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              width: double.infinity,
                              height: 50,
                              decoration: BoxDecoration(
                                color:
                                    Colors.transparent, // Latar belakang putih
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Text(formatCurrency.format(saldo),
                                    style: GoogleFonts.roboto(
                                      textStyle: const TextStyle(
                                        fontSize: 20,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      width: double.infinity,
                      height: 250,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(143, 119, 119, 119),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Riwayat",
                                style: GoogleFonts.roboto(
                                  textStyle: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )),
                            const SizedBox(height: 30),
                            Expanded(
                              child: FutureBuilder<void>(
                                future: getData2(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  } else if (snapshot.hasError) {
                                    return Center(
                                      child: Text('Error: ${snapshot.error}'),
                                    );
                                  } else {
                                    return riwayatList.isEmpty
                                        ? const Center(
                                            child: Text('No history available'),
                                          )
                                        : ListView.builder(
                                            itemCount: visibleRiwayatCount,
                                            itemBuilder: (context, index) {
                                              if (index < riwayatList.length) {
                                                String pemasukanText =
                                                    riwayatList[index] > 0
                                                        ? 'Pemasukan '
                                                        : 'Pengeluaran ';

                                                return Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      pemasukanText,
                                                      style: GoogleFonts.roboto(
                                                        textStyle:
                                                            const TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.black87,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          formatCurrency.format(
                                                              angkaList[index]),
                                                          style: GoogleFonts
                                                              .roboto(
                                                            textStyle:
                                                                const TextStyle(
                                                              fontSize: 16,
                                                              color: Colors
                                                                  .black87,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                );
                                              } else {
                                                // Display empty row
                                                return const SizedBox
                                                    .shrink(); // Mengembalikan widget kosong
                                              }
                                            },
                                          );
                                  }
                                },
                              ),
                            ),
                            if (visibleRiwayatCount < riwayatList.length)
                              TextButton(
                                onPressed: loadMoreRiwayat,
                                child: Text(
                                  'Load More',
                                  style: GoogleFonts.roboto(
                                    textStyle: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )),
        ));
  }
}
