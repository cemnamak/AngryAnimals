extends Area2D
@onready var splash = $Splash

func _on_body_entered(body:Node2D):
	splash.play()


