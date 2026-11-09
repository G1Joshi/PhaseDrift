import 'package:flame/game.dart';
import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';

import 'core/audio/audio.dart';
import 'core/domain/domain.dart';
import 'core/services/services.dart';
import 'core/theme/theme.dart';
import 'game/game.dart';
import 'ui/ui.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PersistenceService.instance.init();

  // Restore persistent audio and tactile settings
  final (master, music, sfx, muted) = PersistenceService.instance
      .getAudioSettings();
  AudioEngine.instance.setMasterVolume(master);
  AudioEngine.instance.setMusicVolume(music);
  AudioEngine.instance.setSfxVolume(sfx);
  if (muted && !AudioEngine.instance.isMuted) {
    AudioEngine.instance.toggleMute();
  }
  HapticsService.instance.isEnabled = PersistenceService.instance
      .getHapticsEnabled();

  runApp(const PhaseDriftApp());
}

typedef MyApp = PhaseDriftApp;

class PhaseDriftApp extends StatelessWidget {
  const PhaseDriftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PhaseDrift',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.solarTheme,
      home: const MainNavigationHarness(),
    );
  }
}

enum AppRoute { title, chamberSelect, settings, gameplay }

class MainNavigationHarness extends StatefulWidget {
  const MainNavigationHarness({super.key});

  @override
  State<MainNavigationHarness> createState() => _MainNavigationHarnessState();
}

class _MainNavigationHarnessState extends State<MainNavigationHarness>
    with WidgetsBindingObserver {
  AppRoute _currentRoute = AppRoute.title;
  ChamberDefinition _activeChamber = ChamberRegistry.getChamber(1);
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _reduceMotion = PersistenceService.instance.getReduceMotion();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      AudioEngine.instance.pauseMusic();
    } else if (state == AppLifecycleState.resumed &&
        _currentRoute == AppRoute.gameplay) {
      AudioEngine.instance.resumeMusic();
    }
  }

  void _navigateTo(AppRoute route) {
    setState(() => _currentRoute = route);
  }

  void _startChamber(ChamberDefinition chamber) {
    setState(() {
      _activeChamber = chamber;
      _currentRoute = AppRoute.gameplay;
    });
  }

  @override
  Widget build(BuildContext context) {
    return switch (_currentRoute) {
      AppRoute.title => TitleScreen(
        onStartGame: () => _startChamber(ChamberRegistry.getChamber(1)),
        onOpenChamberSelect: () => _navigateTo(AppRoute.chamberSelect),
        onOpenSettings: () => _navigateTo(AppRoute.settings),
      ),
      AppRoute.chamberSelect => ChamberSelectScreen(
        onSelectChamber: _startChamber,
        onBack: () => _navigateTo(AppRoute.title),
      ),
      AppRoute.settings => SettingsScreen(
        reduceMotion: _reduceMotion,
        onReduceMotionChanged: (val) => setState(() => _reduceMotion = val),
        onBack: () => _navigateTo(AppRoute.title),
      ),
      AppRoute.gameplay => GameSessionView(
        chamber: _activeChamber,
        reduceMotion: _reduceMotion,
        onOpenSettings: () => _navigateTo(AppRoute.settings),
        onExitToMenu: () => _navigateTo(AppRoute.chamberSelect),
        onLoadChamber: _startChamber,
      ),
    };
  }
}

class GameSessionView extends StatefulWidget {
  const GameSessionView({
    super.key,
    required this.chamber,
    required this.reduceMotion,
    required this.onOpenSettings,
    required this.onExitToMenu,
    required this.onLoadChamber,
  });

  final ChamberDefinition chamber;
  final bool reduceMotion;
  final VoidCallback onOpenSettings;
  final VoidCallback onExitToMenu;
  final ValueChanged<ChamberDefinition> onLoadChamber;

  @override
  State<GameSessionView> createState() => _GameSessionViewState();
}

class _GameSessionViewState extends State<GameSessionView>
    with SingleTickerProviderStateMixin {
  late PhaseDriftGame _game;
  late final Ticker _ticker;
  final ValueNotifier<int> _hudTicker = ValueNotifier<int>(0);
  final FocusNode _gameFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initGame();
    _ticker = createTicker((_) {
      _hudTicker.value++;
    })..start();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _gameFocusNode.requestFocus();
    });
  }

  void _initGame() {
    _game = PhaseDriftGame(chamber: widget.chamber);
    _game.setReduceMotion(widget.reduceMotion);
    AudioEngine.instance.startMusic();
  }

  @override
  void didUpdateWidget(covariant GameSessionView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chamber.chamberId != widget.chamber.chamberId) {
      _initGame();
    }
    _game.setReduceMotion(widget.reduceMotion);
  }

  @override
  void dispose() {
    AudioEngine.instance.pauseMusic();
    _gameFocusNode.dispose();
    _ticker.dispose();
    _hudTicker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<GamePhase>(
      valueListenable: _game.phaseNotifier,
      builder: (context, activePhase, _) {
        final isSolar = activePhase is SolarPhase;
        return AnimatedTheme(
          data: isSolar ? AppTheme.solarTheme : AppTheme.voidTheme,
          duration: const Duration(milliseconds: 250),
          child: Scaffold(
            backgroundColor: isSolar
                ? const Color(0xFF090704)
                : const Color(0xFF03070C),
            body: MouseRegion(
              cursor: SystemMouseCursors.basic,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => _gameFocusNode.requestFocus(),
                child: Stack(
                  children: [
                    // 1. Flame Game Engine Viewport
                    GameWidget<PhaseDriftGame>(
                      key: ValueKey('game_${widget.chamber.chamberId}'),
                      game: _game,
                      focusNode: _gameFocusNode,
                      autofocus: true,
                      overlayBuilderMap: {
                        'PauseMenu': (context, game) => PauseMenu(
                          onResume: () {
                            game.resumeGame();
                            setState(() {});
                          },
                          onRestart: () {
                            game.restartChamber();
                            setState(() {});
                          },
                          onSettings: widget.onOpenSettings,
                          onQuit: widget.onExitToMenu,
                          phase: game.player.kinematics.phase,
                          chamberName: widget.chamber.name,
                          chamberNumber: widget.chamber.chamberId,
                        ),
                        'VictoryScreen': (context, game) {
                          final nextChamber = ChamberRegistry.getNextChamber(
                            widget.chamber.chamberId,
                            allowEndless: true,
                          );
                          return VictoryScreen(
                            chamberId: widget.chamber.chamberId,
                            chamberName: widget.chamber.name,
                            clearTimeMs: game.elapsedMs,
                            parTimeMs: widget.chamber.parTimeMs,
                            shardsMask: game.shardsCollectedMask,
                            nextChamberName: nextChamber?.name,
                            nextParTimeMs: nextChamber?.parTimeMs,
                            nextChamberTier: nextChamber?.tier.label,
                            nextChamberTierColor: nextChamber?.tier.color,
                            onRetry: () {
                              game.restartChamber();
                              setState(() {});
                            },
                            onNextChamber: nextChamber != null
                                ? () => widget.onLoadChamber(nextChamber)
                                : null,
                            onChamberSelect: widget.onExitToMenu,
                          );
                        },
                      },
                    ),

                    // 2. Telemetry HUD Overlay
                    ValueListenableBuilder<int>(
                      valueListenable: _hudTicker,
                      builder: (context, _, child) {
                        if (!_game.isLoaded || _game.isCompleted) {
                          return const SizedBox.shrink();
                        }
                        final activePhase = _game.player.kinematics.phase;
                        final currentVx = _game.player.kinematics.vx;
                        return TelemetryHud(
                          chamberName: widget.chamber.name,
                          chamberNumber: widget.chamber.chamberId,
                          phase: activePhase,
                          elapsedMs: _game.elapsedMs,
                          bestTimeMs: widget.chamber.parTimeMs,
                          shardsMask: _game.shardsCollectedMask,
                          velocity: currentVx,
                          maxVelocity: KinematicConstants.runSpeed,
                          onPause: () {
                            _game.pauseGame();
                            setState(() {});
                          },
                        );
                      },
                    ),

                    // 3. Virtual Mobile / Touch D-pad
                    ValueListenableBuilder<int>(
                      valueListenable: _hudTicker,
                      builder: (context, _, child) {
                        if (!_game.isLoaded ||
                            _game.isPaused ||
                            _game.isCompleted) {
                          return const SizedBox.shrink();
                        }
                        final activePhase = _game.player.kinematics.phase;
                        return VirtualDpad(
                          phase: activePhase,
                          onMove: (axis) =>
                              _game.inputController.setMoveAxis(axis),
                          onJumpPressed: () =>
                              _game.inputController.pressJump(),
                          onJumpReleased: () =>
                              _game.inputController.releaseJump(),
                          onShiftPressed: () {
                            _game.inputController.triggerShift();
                          },
                        );
                      },
                    ),

                    // 4. Tactical Milestone Toast Overlay
                    const MilestoneToastOverlay(),

                    // 5. Arcade Chamber Intro Telemetry Splash
                    ChamberIntroOverlay(
                      key: ValueKey('intro_${widget.chamber.chamberId}'),
                      chamber: widget.chamber,
                    ),

                    // 6. Reality Warp Radial Flash Overlay
                    RealityWarpFlash(phase: activePhase),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
