extends Node

var debug = false
var players_count = 1
var race_time = 60 # seconds
var multilplayer = false
var scores = []




func _ready() -> void:
	for i in range(4):
		scores.append({"id":i, "laps":0, "created":false})
