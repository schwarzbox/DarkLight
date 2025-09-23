extends Node

func _ready() -> void:
	prints(name, "ready")

const UI_DELAY: float = 1.0

const CURSOR_ARROW_ICON: Texture2D = preload("res://shared/icons/cursor_arrow_icon.png")
const CURSOR_POINTING_HAND_ICON: Texture2D = preload("res://shared/icons/cursor_pointing_hand_icon.png")

const SHOOT_ICON_1: Texture2D = preload("res://scenes/views/game/shoot_icon_1.png")
const SHOOT_ICON_2: Texture2D = preload("res://scenes/views/game/shoot_icon_2.png")
const SHOOT_ICON_3: Texture2D = preload("res://scenes/views/game/shoot_icon_3.png")
const STRIKE_ICON_1: Texture2D = preload("res://scenes/views/game/strike_icon_1.png")
const STRIKE_ICON_2: Texture2D = preload("res://scenes/views/game/strike_icon_2.png")
const STRIKE_ICON_3: Texture2D = preload("res://scenes/views/game/strike_icon_3.png")
const SHIELD_ICON_1: Texture2D = preload("res://scenes/views/game/shield_icon_1.png")
const SHIELD_ICON_2: Texture2D = preload("res://scenes/views/game/shield_icon_2.png")
const SHIELD_ICON_3: Texture2D = preload("res://scenes/views/game/shield_icon_3.png")

const PLAYER_SCENE: PackedScene = preload("res://scenes/models/player/player.tscn")
const ENEMY_SCENE: PackedScene = preload("res://scenes/models/enemy/enemy.tscn")
const BULLET_SCENE: PackedScene = preload("res://scenes/models/bullet/bullet.tscn")
const ORB_SCENE: PackedScene = preload("res://scenes/models/orb/orb.tscn")
const ENTER_SCENE: PackedScene = preload("res://scenes/models/enter/enter.tscn")
const EXIT_SCENE: PackedScene = preload("res://scenes/models/exit/exit.tscn")
const WALL_SCENE: PackedScene = preload("res://scenes/models/wall/wall.tscn")
const TRAP_SCENE: PackedScene = preload("res://scenes/models/trap/trap.tscn")

const GAME_SCENE: PackedScene = preload("res://scenes/views/game/game.tscn")
const SCORE_SCENE: PackedScene = preload("res://scenes/views/score/score.tscn")
const LABIRINTH_SCENE: PackedScene = preload("res://scenes/views/game/labirinth/labirinth.tscn")

const FIXED_FPS: int = 60

enum Models {
	PLAYER,
	ENEMY,
	BULLET,
	ORB,
	WALL,
	EMPTY,
	ENTER,
	EXIT,
	TRAP,
}

const PLAYER_SHOOT_DELAY: float = 0.24
const PLAYER_SHIELD_DELAY: float = 0.4
const PLAYER_WIN_DELAY: float = 0.8
const PLAYER_DIED_DELAY: float = 4.2
const PLAYER_SCALE_DELAY: float = 0.4
const PLAYER_HIT_DELAY: float = 0.4
const PLAYER_ALARM_BEAT_DELAY: float = 0.2
const PLAYER_ALARM_HP: int = 120
const PLAYER_MAX_SHOOT_KICK_FORCE: float = 256.0
const PLAYER_MAX_HIT_KICK_FORCE: float = 36.0
const PLAYER_SHIELD_FORCE_MULTIPLIER: float = 42.0
const PLAYER_ORB_FORCE_MULTIPLIER: float = 8.0
const ENEMY_SCALE_DELAY: float = 0.8
const ENEMY_CATCH_PLAYER_SQUARED_DISTANCE: float = 16384.0
const ENEMY_SHOOT_PLAYER_SQUARED_DISTANCE: float = 131072.0
const ENEMY_CHANCE_TO_SHOOT: float = 0.12
const ENEMY_AVOID_LIGHT_FORCE_MULTIPLIER: float = 2.2
const FLOCK_STEER_FORCE: float = 20.0
const FLOCK_ALIGNMENT_FORCE: float = 40.0
const FLOCK_COHESION_FORCE: float = 30.0
const FLOCK_SEPARATION_FORCE: float = 45.0
const BULLET_SCALE_DELAY: float = 0.4
const BULLET_BLAST_DELAY: float = 0.1
const BULLET_BLAST_RADIUS: float = 68.0
const BULLET_MIN_FORCE_SQUARED: float = 393216.0
const BULLET_STRIKE_FORCE_SQUARED: float = 1280000.0
const BULLET_DISPERSION: float = 0.12
const BULLET_DISPERSIONS: Dictionary = {
	1: [[-BULLET_DISPERSION, BULLET_DISPERSION]],
	2: [[-BULLET_DISPERSION, 0.04], [0.04, BULLET_DISPERSION]],
	3: [[-BULLET_DISPERSION, 0.06], [0, 0], [0.06, BULLET_DISPERSION]],
}
const ORB_SCALE_DELAY: float = 0.4
const ORB_DIED_DELAY: float = 10.0
const ORB_CHANCE_TO_CREATE: float = 0.2

const SHOOT_COUNT_DIFF: int = 1
const MIN_SHOOT_COUNT: int = 1
const MAX_SHOOT_COUNT: int = 3
const STRIKE_FORCE_STEP_DIFF: int = 8
const MIN_STRIKE_FORCE_STEP: int = 16
const MAX_STRIKE_FORCE_STEP: int = 32
const MAX_STRIKE_FORCE_DIFF: int = 128
const MIN_MAX_STRIKE_FORCE: int = 1024
const MAX_MAX_STRIKE_FORCE: int = 1280
const SHIELD_COUNT_DIFF: int = 8
const MIN_SHIELD_COUNT: int = 0
const MAX_SHIELD_COUNT: int = 16
const UPGRADE_ICONS: Dictionary = {
	"shoot": {
		1: SHOOT_ICON_1,
		2: SHOOT_ICON_2,
		3: SHOOT_ICON_3,
	},
	"strike": {
		16: STRIKE_ICON_1,
		24: STRIKE_ICON_2,
		32: STRIKE_ICON_3,
	},
	"shield": {
		0: SHIELD_ICON_1,
		8: SHIELD_ICON_2,
		16: SHIELD_ICON_3,
	}
}


# labirinth related constants
const LEVEL_COUNT: int = 5
const ENEMY_COUNT: int = 24
const LABIRINTH_TILE_SIZE: Vector2 = Vector2(128, 128)
const LABIRINTH_TRAP_PROBABILITY: float = 0.1
const LABIRINTH_TRAP_COUNT: int = 8
const LABIRINTH_TRAP_MULTIPLIER: int = 2
# world
const LABIRINTH_ENEMY_REGENERATION_DELAY: int = 4
const LABIRINTH_DIMENSIONS: Dictionary = {
	1: Vector2i(12, 12),
	2: Vector2i(13, 13),
	3: Vector2i(14, 14),
	4: Vector2i(15, 15),
	5: Vector2i(16, 16),
}
# enemy
const CATCH_FORCE_MULTIPLIERS: Dictionary = {
	1: 1.6,
	2: 1.7,
	3: 1.8,
	4: 1.9,
	5: 2.0
}
const SHOOT_FORCE_MULTIPLIERS: Dictionary = {
	1: 6,
	2: 12,
	3: 24,
	4: 48,
	5: 64
}
const TARGET_SHAPE_RADIUS: Dictionary = {
	1: 512.0,
	2: 544.0,
	3: 576.0,
	4: 608.0,
	5: 640.0
}
# flock
var SEPARATION_FORCES: Dictionary = {
	1: FLOCK_SEPARATION_FORCE,
	2: 47.0,
	3: 49.0,
	4: 51.0,
	5: 52.0
}

const FONTS: Dictionary = {
	SMALL_FONT_SIZE = 32,
	MEDIUM_FONT_SIZE = 64,
	LARGE_FONT_SIZE = 128,
}

const COLORS: Dictionary = {
	DEFAULT_WHITE = Color(1.0, 1.0, 1.0, 1.0),
	DEFAULT_BLACK = Color(0.0, 0.0, 0.0, 1.0),
	ALARM_BEAT_WHITE = Color(1.0, 1.0, 1.0, 0.2)
}

const GLOW_COLORS: Dictionary = {
	HIGH = Color(1.8, 1.8, 1.8, 1.0),
	MIDDLE = Color(1.5, 1.5, 1.5, 1.0),
	LOW = Color(1.2, 1.2, 1.2, 1.0),
}

# Save scores
const SCORES_FILE_PATH: String = "user://scores.tres"
var SCORES: Resource = preload("res://utils/scores.tres")
