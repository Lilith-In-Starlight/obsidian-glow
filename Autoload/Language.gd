extends Node


var lang := "en"

var lines := {
	"en": {
		"diary_opening" : "So that old lady gave me this. Uh...\n\n  Dear diary? I have no idea what to write about here, but she asked me to, so here I am. She said she wanted knowledge, so I'll write about things I see",
		"diary_angel" : "Angels:\n\n  These guys are everywhere. They prepare to shoot way before they actually do it, which makes them extremely annoying. The only reason this thing killed  me is that I was stabbed.",
		"diary_angel_ball" : "Ball Angels:\n\n  These ones bounce around mindlessly. Once they see a target, they lit themselves on fire and charge towards them.",
		"diary_gate_outskirts" : "Oh right. I saw this weird... wall? thing near the outskirts of the city. The symbols in it were incomprehensible, I wonder what it is or what it's behind.\n\nit calls to me...",
		"diary_spike_guardian": "Spike Guardians:\n\n  These people seem to be hunters. They look like the Librarian, so I assume they are Spike Gardeners. This must be their garden. I didn't expect 'gardeners' to be more like hunters. They are also less mindless than angels, which is fun.",
		"diary_spike_guardian_magic": "Spike Guardians 2:\n\n Yep. They are magicians. I have to be careful with how often I attack, or they'll use their magic against me, so that's good to know.",
		
		"desc_mask_survivor" : "Mask Of The Survivor\n\nOnce belonging to a hunter who left his identity behind, this activated mask will give strength to those who are in extreme danger.",
		"desc_mask_none" : "",
	},
}

func line(line):
	if lines[lang].has(line):
		return lines[lang][line]
	return "null"

func not_in_diary(line):
	if not Persistent.diary.has(line) and not Persistent.recently_collected.has(line):
		return true
	return false
