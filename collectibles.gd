extends Area2D

var DefaultScale;

func _ready():
	DefaultScale = scale

func DivideSizeBy(Size: int ):
	scale -= Vector2(Size, Size);
	
func SetPos():
	pass


func _on_body_entered(body):
	DivideSizeBy(2)
	
