extends Node


var lang := "en"

var lines := {
	"en": {
		"diary_opening" : "So that old lady gave me this. Uh...\n\n  Dear diary? I have no idea what to write about here, but she asked me to, so here I am. She said she wanted knowledge, so I'll write about things I see",
		"diary_angel" : "Angels:\n\n  These guys are everywhere. They prepare to shoot way before they actually do it, which makes them extremely annoying. The only reason this thing killed  me is that I was stabbed.",
		"diary_angel_ball" : "Ball Angels:\n\n  These ones bounce around mindlessly. Once they see a target, they lit themselves on fire and charge towards them.",
		"diary_gate_outskirts" : "Oh right. I saw this weird... wall? thing near the outskirts of the city. The symbols in it were incomprehensible, I wonder what it is or what it's behind.\n\nit calls to me...",
	},
}

func line(line):
	if lines[lang].has(line):
		return lines[lang][line]
	return "null"
