// ignore_for_file: unused_field, prefer_final_fields, deprecated_member_use

import 'package:flutter/material.dart';

class MinistriesScreen extends StatefulWidget {
  const MinistriesScreen({super.key});

  @override
  State<MinistriesScreen> createState() => _MinistriesScreenState();
}

class _MinistriesScreenState extends State<MinistriesScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _allMinistries = [
    {
      'name': 'وزارة الصحة',
      'logo':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuB1Fb7A838AtMBGBMtmgY-rCryICqb74Zv3biLMQ0ifUIRo9dDFm8IgzkcyYA11FikQtVvYYaIwbsHGOoy3lab5MkQ46qNbLgHvF6yMqGzMpbpwQopf2Is3GmaLFd-gTdR1qK0zAUq8-NfCn6WInB1Fgnz91ASt5fltLtXmCvTolssO43n1RvvCTny7-Ytpn7A0YXL6tTL8uNYgPZJoBUjsuV9OK4_mA4gKx_eAeyBKQLqjg2LbBy0pUnpzg5Uv3UISYvFi7fAgUZVM',
    },
    {
      'name': 'وزارة التربية',
      'logo':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDtf-mDjg4E87bmdgjXmjedX70qzoXOf90Dcs7POXOqjSIvNfdu52eOdvrtF9S3y0gP7h_B2p40z-_x1ilRrBGcADDeMDA4u_JdeXbn4BgzU5RfhPvq5rufPgRGaoLVYzmg2PIiTzHrRNZvv9KGuTRa1N8B-XnaAJWSm1H9F0tds-rQfZXszn44GvmahyjerjTkRMb0q3ByBUiK4LBwCEKcTULII24R5PiIFfq1Clv1Qt5T4Du1CSpK9oW3-Tg0U86HF2c0KkYsamoz',
    },
    {
      'name': 'وزارة الداخلية',
      'logo':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCHn2yh6McMadnV-2UuGblTp1V0pMSBagBPp2b8RQjqkLLih8Nxuh1xCTS_Xe_gTjhqbkGzqyMbhluYu-MFEERzKURtCemhO-6SsFC9Fr8QzqwZ7uMGFXyRKHyJMsXujytuw9vXUJ_XaGBUI6e0SpVXp_DsBy0j1Sp5ReoyL6LP7iD6CxvrF_GyUVx2kXDcxSno2oNMEsF-F5fOemN59TyERPmyNn_Dj9J50FSCwCRx_3feZQR1EUvHzZ6fMszcRoOaad4LgjCEelaG',
    },
    {
      'name': 'وزارة الخارجية',
      'logo':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAuXqcse4eAxKuPuBERtyW7A-OcFkX4SmJbE9IWAAlcjEqalS7z155ji8JWy85e-KHQ_qO3c-vVOpH3POciuUkU7qYEW3erpKjIYI4T9txoEreG_I0EEC0pSB9Fc_FezaziVL-6tD7QUHM-Q20_fn1_q2Mixf-N_8OVw00SG1GLIejJrnngHIHc9Gim816d9u7tISVeiTiZiuzjKwHBgHyY6rcfntJkUzChG-66TEW9sTByKaUj0PgEhGudnywB-F11WAAis_zkTpCa',
    },
    {
      'name': 'وزارة المالية',
      'logo':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDhlyEclJM70U4M6hPZDzr1hJSD0P6vUgd7wnY3yHE_awYGlJ8bVPxvEawBNiF1P-9IhXdE7E9HfNmA3r7wr4VwRfS2c35wmVxk_fk25cHptbDVlt4UIWyORJQItpgeRBEtb_7gSaVRRxWUr-uoRISV0CJlW0c3nSgDmHql9k1v0qcHNAJ7sdTlbKanyUDCNqmB3vmallYShSuuLXxuF6bJ_CwgTM3o9PGqDWWBHpSWOlH9ChaoCbm2Tv5HghEm9VFsuDvYj6iOMc5N',
    },
    {
      'name': 'وزارة النفط',
      'logo':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBvx8oxLZxcsJWEMNNRHe3bMLTDeuNJbnKpwYnDofjo0uGIEBA-w-mHAj0Hqdg3pWWkJxVQX6K82rWw_tZzDgI0qZCGRbRR9CknxrkQnpKdYFmsoEkytK2mSf2iRo2otlVJcZFhOdsrhCFicGDHLIUzwLri9bI9yRfuZpZnDUh-shE4qnM5lgltKre31yGhnpIgF_LTf0WT9JDD6OXcI8XNjROurr28dFbJCavvNUOPr1wyik6WmQFp96WAIkWbiSePmF1FiIib7N5c',
    },
    {
      'name': 'وزارة الدفاع',
      'logo':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuA_zMHXvCt80uBXia8zNtiSqFnkQ6v-BfSgVoe9boxC_OlqN7egx6740X-YOgivJyO-bpoHEt5Qc9DG8wHAD1dRJ8P1LXS_UGmLDAhE_HoNXcscAuKH5Pdoi8mQTcJopDtM8FuqrqKaJH4PTuzCehcOMdTVpNdhZy7tA3nlieGjSpBrIAGk75ISP0hAsM8_GRGYoacLlmqRJZuSUpL2TKChn5Ku-TZyqTxoHaov_Z_1RQkH_RPJ4D9Mwk0-E5_dNJw1NNirdRBGTRSA',
    },
  ];

  List<Map<String, String>> _filteredMinistries = [];
  int _currentIndex = 2;

  @override
  void initState() {
    super.initState();
    _filteredMinistries = List<Map<String, String>>.from(_allMinistries);
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _filteredMinistries =
            List<Map<String, String>>.from(_allMinistries);
      });
    } else {
      setState(() {
        _filteredMinistries = _allMinistries
            .where((m) => m['name']!.contains(query))
            .toList();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        body: SafeArea(
          child: Column(
            children: [
              // AppBar
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9F9).withOpacity(0.9),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      height: 48,
                      width: 48,
                      child: IconButton(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/main-shell',
                            (route) => false,
                          );
                        },
                        style: IconButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: const CircleBorder(),
                          backgroundColor: Colors.transparent,
                        ),
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 20,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'الوزارات والهيئات',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 48,
                      width: 48,
                      child: IconButton(
                        onPressed: () {
                          // لاحقاً: صفحة مساعدة
                        },
                        style: IconButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: const CircleBorder(),
                          backgroundColor: Colors.transparent,
                        ),
                        icon: const Icon(
                          Icons.help_outline,
                          size: 24,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // حقل البحث
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFe5e7eb),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.search,
                        color: Color(0xFF6B7280),
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'بحث عن وزارة أو هيئة...',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),

              // قائمة الوزارات
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFe5e7eb),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      itemCount: _filteredMinistries.length,
                      separatorBuilder: (context, index) =>
                          const Divider(
                        indent: 64,
                        height: 1,
                        color: Color(0xFFE5E7EB),
                      ),
                      itemBuilder: (context, index) {
                        final ministry = _filteredMinistries[index];
                        return InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/complaint',
                              arguments: {
                                'ministry': ministry['name']!,
                                'logoUrl': ministry['logo'],
                                'icon': Icons.account_balance,
                              },
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor:
                                      const Color(0xFFE0E0E0),
                                  backgroundImage: NetworkImage(
                                    ministry['logo']!,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    ministry['name']!,
                                    maxLines: 1,
                                    overflow:
                                        TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight:
                                          FontWeight.w500,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}