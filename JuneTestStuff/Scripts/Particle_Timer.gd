extends Node3D

@export var particles : Array[GPUParticles3D]

func _ready() -> void:
	for particle in particles:
		particle.emitting=true

func _on_Timer_timeout():
	for particle in particles:
		particle.emitting=true
