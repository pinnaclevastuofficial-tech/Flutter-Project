import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';

import 'ai_hub_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Brand (logo-inspired)
  static const Color brandBlue = Color(0xFF1F6FEB);
  static const Color brandOrange = Color(0xFFFF8A2A);

  static const Color textDark = Color(0xFF101828);
  static const Color textMuted = Color(0xFF667085);

  final PageController _page = PageController(viewportFraction: 0.90);

  // Put your promo videos here (mp4 links)
  final List<String> promoVideos = const [
    // Replace with your real video URLs
    "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
    "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4",
  ];

  late final List<VideoPlayerController> _vControllers;
  int _activeIndex = 0;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _initVideos();

    _page.addListener(() {
      final p = _page.page;
      if (p == null) return;
      final idx = p.round().clamp(0, promoVideos.length - 1);
      if (idx != _activeIndex) {
        _setActive(idx);
      }
    });
  }

  Future<void> _initVideos() async {
    _vControllers = promoVideos
        .map((url) => VideoPlayerController.networkUrl(Uri.parse(url)))
        .toList();

    // Initialize all (small list). If you have many, we can lazy-load.
    await Future.wait(_vControllers.map((c) => c.initialize()));
    for (final c in _vControllers) {
      c.setLooping(true);
      c.setVolume(0.0); // muted looks more premium
    }

    _setActive(0, play: true);
    if (mounted) setState(() => _ready = true);
  }

  void _setActive(int index, {bool play = true}) {
    _activeIndex = index;
    for (int i = 0; i < _vControllers.length; i++) {
      if (i == index) {
        if (play) _vControllers[i].play();
      } else {
        _vControllers[i].pause();
      }
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _page.dispose();
    for (final c in _vControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FF),
      body: Stack(
        children: [
          const _PremiumBackground(),

          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                    child: _TopBar(
                      title: "Pinnacle Vastu",
                      subtitle: user?.email ?? "Modern Vastu • Courses • Remedies",
                      onMenu: () {},
                      onLogout: () async =>
                          Supabase.instance.client.auth.signOut(),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
                    child: _SearchBar(
                      hint: "Search: courses, remedies, consultants, reports...",
                      onTap: () {},
                    ),
                  ),
                ),

                // VIDEO CAROUSEL (Premium)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 4, 0, 14),
                    child: SizedBox(
                      height: 210,
                      child: _ready
                          ? PageView.builder(
                              controller: _page,
                              itemCount: promoVideos.length,
                              itemBuilder: (context, index) {
                                final active = index == _activeIndex;
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 6),
                                  child: _VideoHeroCard(
                                    controller: _vControllers[index],
                                    active: active,
                                    badge: index == 0 ? "UPCOMING COURSE" : "FEATURED",
                                    title: index == 0
                                        ? "Advance Vastu Course"
                                        : "All Vastu Solutions in One App",
                                    subtitle: index == 0
                                        ? "45 Devtas • Business Vastu • Industrial"
                                        : "Courses • Consultations • Remedies • Reports",
                                    accent: index == 0 ? brandOrange : brandBlue,
                                    onPrimary: () {
                                      if (index == 0) {
                                        // TODO: open course page
                                      } else {
                                        // TODO: open services page
                                      }
                                    },
                                  ),
                                );
                              },
                            )
                          : const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: _SkeletonHero(),
                            ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                    child: _QuickRow(
                      items: [
                        _QuickItem("45 Devtas", Icons.grid_view_rounded, brandBlue),
                        _QuickItem("Industrial", Icons.factory_outlined, brandOrange),
                        _QuickItem("Daily Tips", Icons.lightbulb_outline, const Color(0xFF7C3AED)),
                        _QuickItem("Reports", Icons.description_outlined, const Color(0xFF0E9384)),
                      ],
                      onTap: (label) {
                        // TODO: route
                      },
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: const _SectionTitle(
                    title: "Services",
                    subtitle: "Premium modules designed beautifully",
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  sliver: SliverGrid(
                    delegate: SliverChildListDelegate(
                      [
                        _ServiceCard(
                          title: "Courses",
                          subtitle: "Learn from experts",
                          icon: Icons.school_outlined,
                          tint: brandBlue,
                          onTap: () {},
                        ),
                        _ServiceCard(
                          title: "Remedies",
                          subtitle: "Easy solutions",
                          icon: Icons.healing_outlined,
                          tint: brandOrange,
                          onTap: () {},
                        ),
                        _ServiceCard(
                          title: "Consultants",
                          subtitle: "Book guidance",
                          icon: Icons.support_agent_outlined,
                          tint: const Color(0xFF7C3AED),
                          onTap: () {},
                        ),
                        _ServiceCard(
                          title: "Reports",
                          subtitle: "Premium analysis",
                          icon: Icons.assessment_outlined,
                          tint: const Color(0xFF0E9384),
                          onTap: () {},
                        ),
                      ],
                    ),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.10,
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: const _SectionTitle(
                    title: "Free Tools",
                    subtitle: "Quick & useful utilities",
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _MiniTool(
                                title: "Kundli",
                                subtitle: "Generate instantly",
                                icon: Icons.auto_awesome_outlined,
                                tint: brandOrange,
                                onTap: () {},
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _MiniTool(
                                title: "KP Kundli",
                                subtitle: "KP system",
                                icon: Icons.track_changes_outlined,
                                tint: brandBlue,
                                onTap: () {},
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        _WideCTA(
                          title: "Start a New Project",
                          subtitle: "Create House/Office case & analyze step-by-step",
                          left: brandBlue,
                          right: brandOrange,
                          icon: Icons.home_work_outlined,
                          onTap: () {},
                        ),

                        const SizedBox(height: 110),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // AI Button (Premium)
          Positioned(
            right: 16,
            bottom: 22,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AiHubScreen()),
                );
              },
              child: Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    colors: [brandBlue, brandOrange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.20),
                      blurRadius: 26,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: const Icon(Icons.smart_toy_outlined,
                    color: Colors.white, size: 30),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ---------------------------- Background ---------------------------- */

class _PremiumBackground extends StatelessWidget {
  const _PremiumBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Soft gradient base (less white, more premium)
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFF3F6FF),
                  Color(0xFFFFF5EC),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        // Blobs
        const _Blob(left: -90, top: -70, size: 240, color: Color(0x221F6FEB)),
        const _Blob(right: -90, top: 90, size: 260, color: Color(0x22FF8A2A)),
        const _Blob(left: -60, bottom: 40, size: 220, color: Color(0x187C3AED)),
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  final double? left, right, top, bottom;
  final double size;
  final Color color;

  const _Blob({
    this.left,
    this.right,
    this.top,
    this.bottom,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

/* ---------------------------- Top Bar ---------------------------- */

class _TopBar extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onMenu;
  final VoidCallback onLogout;

  const _TopBar({
    required this.title,
    required this.subtitle,
    required this.onMenu,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _IconPill(icon: Icons.menu_rounded, onTap: onMenu),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16.8,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF101828))),
              const SizedBox(height: 3),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 12.6,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF667085)),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _IconPill(icon: Icons.logout_rounded, onTap: onLogout),
      ],
    );
  }
}

class _IconPill extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconPill({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE7EEFF)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 18,
              offset: const Offset(0, 12),
            )
          ],
        ),
        child: Icon(icon, color: const Color(0xFF1D2939)),
      ),
    );
  }
}

/* ---------------------------- Search ---------------------------- */

class _SearchBar extends StatelessWidget {
  final String hint;
  final VoidCallback onTap;

  const _SearchBar({required this.hint, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE7EEFF)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 18,
              offset: const Offset(0, 12),
            )
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: Color(0xFF667085)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                hint,
                style: const TextStyle(
                    color: Color(0xFF667085),
                    fontWeight: FontWeight.w600),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  colors: [
                    _HomeScreenState.brandBlue.withOpacity(0.92),
                    _HomeScreenState.brandOrange.withOpacity(0.92),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Text(
                "Search",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 12),
              ),
            )
          ],
        ),
      ),
    );
  }
}

/* ---------------------------- Video Hero ---------------------------- */

class _VideoHeroCard extends StatelessWidget {
  final VideoPlayerController controller;
  final bool active;
  final String badge;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onPrimary;

  const _VideoHeroCard({
    required this.controller,
    required this.active,
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 260),
      scale: active ? 1.0 : 0.97,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(active ? 0.18 : 0.10),
              blurRadius: active ? 28 : 20,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Stack(
            children: [
              // Video
              Positioned.fill(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: controller.value.size.width,
                    height: controller.value.size.height,
                    child: VideoPlayer(controller),
                  ),
                ),
              ),

              // Dark overlay for text readability (premium)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.55),
                        Colors.black.withOpacity(0.10),
                        Colors.black.withOpacity(0.50),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),

              // Content
              Positioned(
                left: 14,
                right: 14,
                top: 14,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.25)),
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 11.5,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.25)),
                      ),
                      child: Icon(Icons.play_arrow_rounded,
                          color: Colors.white.withOpacity(0.95)),
                    ),
                  ],
                ),
              ),

              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.88),
                        fontWeight: FontWeight.w600,
                        fontSize: 12.8,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: onPrimary,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: accent.withOpacity(0.35),
                              blurRadius: 18,
                              offset: const Offset(0, 12),
                            )
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              "Open",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 12.8,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded,
                                color: Colors.white, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkeletonHero extends StatelessWidget {
  const _SkeletonHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 210,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE7EEFF)),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

/* ---------------------------- Quick Row ---------------------------- */

class _QuickItem {
  final String label;
  final IconData icon;
  final Color color;
  _QuickItem(this.label, this.icon, this.color);
}

class _QuickRow extends StatelessWidget {
  final List<_QuickItem> items;
  final void Function(String label) onTap;

  const _QuickRow({required this.items, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        padding: const EdgeInsets.only(right: 6),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final it = items[i];
          return InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () => onTap(it.label),
            child: Container(
              width: 150,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.90),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE7EEFF)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 14),
                  )
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: it.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: it.color.withOpacity(0.18)),
                    ),
                    child: Icon(it.icon, color: it.color),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      it.label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF101828),
                        fontSize: 13,
                        height: 1.1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/* ---------------------------- Section Title ---------------------------- */

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16.6,
                  fontWeight: FontWeight.w900,
                  color: _HomeScreenState.textDark)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: const TextStyle(
                  fontSize: 12.6,
                  fontWeight: FontWeight.w600,
                  color: _HomeScreenState.textMuted)),
        ],
      ),
    );
  }
}

/* ---------------------------- Service Cards ---------------------------- */

class _ServiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color tint;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.92),
              tint.withOpacity(0.06),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: const Color(0xFFE7EEFF)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: tint.withOpacity(0.14),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: tint.withOpacity(0.18)),
              ),
              child: Icon(icon, color: tint),
            ),
            const Spacer(),
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14.8,
                    color: _HomeScreenState.textDark)),
            const SizedBox(height: 4),
            Text(subtitle,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                    color: _HomeScreenState.textMuted)),
          ],
        ),
      ),
    );
  }
}

/* ---------------------------- Mini Tools + CTA ---------------------------- */

class _MiniTool extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color tint;
  final VoidCallback onTap;

  const _MiniTool({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE7EEFF)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: tint.withOpacity(0.12),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: tint.withOpacity(0.18)),
              ),
              child: Icon(icon, color: tint),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color: _HomeScreenState.textDark)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5,
                          color: _HomeScreenState.textMuted)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: _HomeScreenState.textMuted),
          ],
        ),
      ),
    );
  }
}

class _WideCTA extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color left;
  final Color right;
  final VoidCallback onTap;

  const _WideCTA({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.left,
    required this.right,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(26),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: LinearGradient(
            colors: [left.withOpacity(0.92), right.withOpacity(0.92)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.16),
              blurRadius: 26,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.25)),
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 15.5)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.88),
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5,
                          height: 1.25)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.arrow_forward_rounded,
                  color: Color(0xFF101828)),
            ),
          ],
        ),
      ),
    );
  }
}
