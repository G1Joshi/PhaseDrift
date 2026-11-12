import 'package:flame/game.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
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

  // Configure native mobile immersive landscape mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

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
  double _touchOpacity = 0.85;
  double _touchScale = 1.0;
  bool _southpaw = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _reduceMotion = PersistenceService.instance.getReduceMotion();
    final (opacity, scale, southpaw) = PersistenceService.instance
        .getTouchSettings();
    _touchOpacity = opacity;
    _touchScale = scale;
    _southpaw = southpaw;
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

  void _openSettingsFromPause() {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 180),
        reverseTransitionDuration: const Duration(milliseconds: 180),
        pageBuilder: (ctx, _, _) => SettingsScreen(
          reduceMotion: _reduceMotion,
          onReduceMotionChanged: (val) => setState(() => _reduceMotion = val),
          touchOpacity: _touchOpacity,
          onTouchOpacityChanged: (val) => setState(() => _touchOpacity = val),
          touchScale: _touchScale,
          onTouchScaleChanged: (val) => setState(() => _touchScale = val),
          southpaw: _southpaw,
          onSouthpawChanged: (val) => setState(() => _southpaw = val),
          onBack: () => Navigator.of(ctx).pop(),
        ),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: KeyedSubtree(
        key: ValueKey(_currentRoute),
        child: switch (_currentRoute) {
          AppRoute.title => TitleScreen(
            onStartGame: () => _startChamber(ChamberRegistry.getChamber(1)),
            onOpenChamberSelect: () => _navigateTo(AppRoute.chamberSelect),
            onOpenSettings: () => _navigateTo(AppRoute.settings),
          ),
          AppRoute.chamberSelect => PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) _navigateTo(AppRoute.title);
            },
            child: ChamberSelectScreen(
              onSelectChamber: _startChamber,
              onBack: () => _navigateTo(AppRoute.title),
            ),
          ),
          AppRoute.settings => PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) _navigateTo(AppRoute.title);
            },
            child: SettingsScreen(
              reduceMotion: _reduceMotion,
              onReduceMotionChanged: (val) =>
                  setState(() => _reduceMotion = val),
              touchOpacity: _touchOpacity,
              onTouchOpacityChanged: (val) =>
                  setState(() => _touchOpacity = val),
              touchScale: _touchScale,
              onTouchScaleChanged: (val) => setState(() => _touchScale = val),
              southpaw: _southpaw,
              onSouthpawChanged: (val) => setState(() => _southpaw = val),
              onBack: () => _navigateTo(AppRoute.title),
            ),
          ),
          AppRoute.gameplay => GameSessionView(
            chamber: _activeChamber,
            reduceMotion: _reduceMotion,
            touchOpacity: _touchOpacity,
            touchScale: _touchScale,
            southpaw: _southpaw,
            onOpenSettings: _openSettingsFromPause,
            onExitToMenu: () => _navigateTo(AppRoute.chamberSelect),
            onLoadChamber: _startChamber,
          ),
        },
      ),
    );
  }
}

class GameSessionView extends StatefulWidget {
  const GameSessionView({
    super.key,
    required this.chamber,
    required this.reduceMotion,
    this.touchOpacity = 0.85,
    this.touchScale = 1.0,
    this.southpaw = false,
    required this.onOpenSettings,
    required this.onExitToMenu,
    required this.onLoadChamber,
  });

  final ChamberDefinition chamber;
  final bool reduceMotion;
  final double touchOpacity;
  final double touchScale;
  final bool southpaw;
  final VoidCallback onOpenSettings;
  final VoidCallback onExitToMenu;
  final ValueChanged<ChamberDefinition> onLoadChamber;

  @override
  State<GameSessionView> createState() => _GameSessionViewState();
}

class _GameSessionViewState extends State<GameSessionView>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late PhaseDriftGame _game;
  late final Ticker _ticker;
  final ValueNotifier<int> _hudTicker = ValueNotifier<int>(0);
  final ValueNotifier<bool> _gameplayReady = ValueNotifier<bool>(false);
  final FocusNode _gameFocusNode = FocusNode();
  int? _personalBestMs;
  bool _lastHudActive = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initGame();
    _loadPersonalBest();
    _ticker = createTicker((_) {
      final isActive = _game.isLoaded && !_game.isPaused && !_game.isCompleted;
      if (_gameplayReady.value != isActive) {
        _gameplayReady.value = isActive;
      }
      if (isActive || _lastHudActive) {
        _lastHudActive = isActive;
        _hudTicker.value++;
      }
    })..start();
    _restoreGameFocus();
  }

  void _restoreGameFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _gameFocusNode.requestFocus();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if ((state == AppLifecycleState.paused ||
            state == AppLifecycleState.inactive ||
            state == AppLifecycleState.hidden) &&
        _game.isLoaded &&
        !_game.isPaused &&
        !_game.isCompleted) {
      _game.pauseGame();
      if (mounted) setState(() {});
    }
  }

  void _loadPersonalBest() async {
    final record = await ProgressionService.instance.loadRecord(
      widget.chamber.chamberId,
    );
    if (mounted) {
      setState(() {
        _personalBestMs = record.bestTimeMs ?? widget.chamber.parTimeMs;
      });
    }
  }

  void _initGame() {
    _gameplayReady.value = false;
    _lastHudActive = true;
    _game = PhaseDriftGame(chamber: widget.chamber);
    _game.setReduceMotion(widget.reduceMotion);
    AudioEngine.instance.crossfadeToPhase(const SolarPhase());
    AudioEngine.instance.startMusic();
  }

  @override
  void didUpdateWidget(covariant GameSessionView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final isNewRandomAnomaly =
        widget.chamber.chamberId == 999 &&
        !identical(oldWidget.chamber, widget.chamber);
    if (oldWidget.chamber.chamberId != widget.chamber.chamberId ||
        oldWidget.chamber.name != widget.chamber.name ||
        isNewRandomAnomaly) {
      _initGame();
      _loadPersonalBest();
      _restoreGameFocus();
    }
    _game.setReduceMotion(widget.reduceMotion);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AudioEngine.instance.pauseMusic();
    _gameFocusNode.dispose();
    _gameplayReady.dispose();
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
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) return;
            if (!_game.isPaused && !_game.isCompleted) {
              _game.pauseGame();
              setState(() {});
            } else {
              widget.onExitToMenu();
            }
          },
          child: AnimatedTheme(
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
                  onTap: () {
                    if (!_game.isPaused && !_game.isCompleted) {
                      _gameFocusNode.requestFocus();
                    }
                  },
                  child: Stack(
                    children: [
                      // 1. Flame Game Engine Viewport
                      GameWidget<PhaseDriftGame>(
                        key: ValueKey(
                          'game_${widget.chamber.chamberId}_${widget.chamber.name}_${identityHashCode(widget.chamber)}',
                        ),
                        game: _game,
                        focusNode: _gameFocusNode,
                        autofocus: true,
                        overlayBuilderMap: {
                          'PauseMenu': (context, game) => PauseMenu(
                            onResume: () {
                              game.resumeGame();
                              _restoreGameFocus();
                              setState(() {});
                            },
                            onRestart: () {
                              game.restartChamber();
                              _restoreGameFocus();
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
                                _loadPersonalBest();
                                _restoreGameFocus();
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
                            bestTimeMs:
                                _personalBestMs ?? widget.chamber.parTimeMs,
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
                      ValueListenableBuilder<bool>(
                        valueListenable: _gameplayReady,
                        builder: (context, isReady, child) {
                          if (!isReady || !AppPlatform.isTouchDevice(context)) {
                            return const SizedBox.shrink();
                          }
                          return VirtualDpad(
                            phase: activePhase,
                            opacity: widget.touchOpacity,
                            scale: widget.touchScale,
                            southpaw: widget.southpaw,
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
                        key: ValueKey(
                          'intro_${widget.chamber.chamberId}_${widget.chamber.name}_${identityHashCode(widget.chamber)}',
                        ),
                        chamber: widget.chamber,
                      ),

                      // 6. Reality Warp Radial Flash Overlay
                      RealityWarpFlash(phase: activePhase),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
