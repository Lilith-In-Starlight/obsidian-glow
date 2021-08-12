extends Node2D


var Player
var timer := -1.0
var HUD
var ongoing := false # Is the cutscene ongoing?
var do := [false, false, false, false]

func _ready():
	Player = get_tree().get_nodes_in_group("player")[0]
	HUD = get_tree().get_nodes_in_group("hud")[0]


func _process(delta):
	for i in $Gardeners.get_children():
		if i.global_position.x < Player.position.x:
			i.scale.x = -1
		else:
			i.scale.x = 1
		
		if not ongoing:
			if i.global_position.distance_to(Player.position) < 50:
				i.play("near")
			else:
				i.play("default")
	
	if not Persistent.met_the_gardeners:
		if HUD.dialogue.empty():
			if ongoing:
				timer += delta
				
				if timer > 0.0 and not do[0]:
					HUD.dialogue = ["HALT. WHO CREEPS IN THE SHADOWS OF OUR GARDEN?",
					"WE WILL NOT TOLERATE YOUR PRESENCE."]
					do[0] = true
				
				elif timer > 1.0 and timer < 1.1 and do[0]:
					$Gardeners/Gardener1.play("lookback")
					
				elif timer > 1.1 and timer < 2.0 and do[0]:
					$Gardeners/Gardener1.play("nod")
					$Gardeners/Gardener3.play("lookback")
					
				elif timer > 2.0 and timer < 2.2 and do[0]:
					$Gardeners/Gardener1.play("lookback")
				
				elif timer > 2.2 and not do[1]:
					$Gardeners/Gardener1.play("default")
					$Gardeners/Gardener3.play("default")
					HUD.dialogue = ["Wait...",
					"There is darkness within you. Strange.",
					"And your burnt scars... your skin refuses to be ashen. You must be who Aesya told us about."]
					do[1] = true
					
				elif timer > 3.5 and not do[2]:
					HUD.dialogue = ["You may stay. Apologies for the inconvenience.",
					"But we will not take comfort in your presence so easily.",
					"You might be strong and fated, but we will not take you seriously unless you prove your honor in combat.",
					"Please, enjoy your stay in our safe haven."]
					do[2] = true
				
				elif timer > 4.0:
					ongoing = false
					Persistent.met_the_gardeners = true
					Persistent.player_cutscene = "no"
		
		if ongoing:
			Persistent.player_cutscene = "nomove"


func _on_body_entered(body):
	if body == Player and not Persistent.met_the_gardeners:
		Persistent.player_cutscene = "nomove"
		ongoing = true
