extends RayCast3D

@export var bump_force := 200.0
@export var bump_particles : Array[GPUParticles3D]
@onready var bike : RigidBody3D = $"../.."
#@onready var hurt_audio : AudioStreamPlayer3D = $"../HurtAudio"
#@onready var splatter_audio : AudioStreamPlayer3D = $"../SplatterAudio"

@onready var engineSanity = get_node("/root/FinalMainScene/UserInterface/EngineSanity")

var crashDamage: float = 350.0 #NEW
var can_hit := true #NEW

func _process(delta: float) -> void:
	if is_colliding():
		bike.apply_impulse(bike.global_basis.z * bump_force)
		for particle in bump_particles:
			particle.restart()
		#AudioManager.play_audio("Hurt")
		if engineSanity and can_hit: #NEW
			can_hit = false #NEW
			engineSanity.takeDamage(crashDamage * delta) #NEW
			print("bump crash for"+str(crashDamage * delta))
				# reset after short delay
		if get_node("/root/FinalMainScene/Bike") != null:
			await get_tree().create_timer(0.5).timeout #NEW
		can_hit = true #NEW
