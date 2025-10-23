class_name FakeTarget extends Marker2D

var following_stars: Array[Star]
var is_used: bool = false


func followed_by(star: Star) -> void:
	if star.targets.size() <= 1:
		star.targets.push_front(self)
	else:
		star.targets.insert(star.targets.size()-1, self)
	following_stars.push_back(star)
	is_used = true

func unfollowed(star: Star) -> void:
	following_stars.erase(star)
	if following_stars.size() == 0:
		is_used = false
