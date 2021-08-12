extends Node


var lang := "en"

var lines := {
	"en": {
		"diary_opening" : "That old lady gave me this. I have no idea what to write about here. I'll write about things I see and then bring it back to her. It'll be useful, anyways.",
		"diary_angel" : "Angels:\n\n  These guys are everywhere. They prepare to shoot way before they actually do it, which makes them extremely annoying. The only reason this thing killed  me is that I was stabbed.",
		"diary_angel_ball" : "Ball Angels:\n\n  These ones bounce around mindlessly. Once they see a target, they lit themselves on fire and charge towards them.",
		"diary_gate_outskirts" : "Oh right. I saw this weird... wall? thing near the outskirts of the city. The symbols in it were incomprehensible, I wonder what it is or what it's behind.\n\nit calls to me...",
		"diary_spike_guardian": "Spike Guardians:\n\n  These people seem to be hunters. They look like the Librarian, so I assume they are Spike Gardeners. This must be their garden. I didn't expect 'gardeners' to be more like hunters. They are also less mindless than angels, which is fun.",
		"diary_spike_guardian_magic": "Spike Guardians 2:\n\n Yep. They are magicians. I have to be careful with how often I attack, or they'll use their magic against me, so that's good to know.",
		
		"desc_mask_survivor" : "Mask Of The Survivor\n\nOnce belonging to a hunter who left his identity behind, this activated mask will give strength to those who are in extreme danger.",
		"desc_mask_beauty" : "Mask Of Striking B eauty\n\nOnce belonging to an artist who tried to capture attraction, some of those who hurt the wearer of this mask will feel immediate regret.",
		"desc_mask_maskmaker" : "Mask Of The Maskmaker\n\nA thousand lifetimes compressed into one. Any who wears this masks on their body will be able to wear deactivated masks.",
		"desc_mask_brittle" : "Mask Of The Brittle Hollow\n\nOnce belonging to a young woman whose identity was her lack thereof, this mask will absorb the life any who get too close to its wearer.",
		"desc_mask_none" : "",
		
		"dia_sgc1_1" : ["I think there were some people waiting for you to the west of here. Something about a notebook?"],
		"dia_sgc1_2" : ["We'll tell the rest of us to not attack you on sight.", "Be careful to not get pierced by randomly placed spikes."],
		"dia_sgc1_3" : ["I'm watching you."],
		"dia_sgc1_4" : ["Every outsider who comes here finds themselves confused by how things work around here.", "I wonder what you'll think."],
		"dia_sgc1_5" : ["Are you used to getting in trouble with angels? You're burnt all over!", "I'm actually surprised your skin is still.. well... skin.", "Does it hurt?"],
		"dia_sgc1_6" : ["Those holes in your shirt... were you hurt? Do you need to treat those wounds?", "I'm surprised they missed any vital organs. Who did this?"],
		"dia_sgc1_7" : ["I sincerely hope you are who we think you are.", "It's foolish, but it's all we have left.", "...", "Sorry, this is your journey alone."],
		
		"dia_gardener_bench" : ["Oh, hello. I hope you feel somewhat welcome.", "The going is very tough, so we keep trying to be tougher. I hope we didn't cause you too much trouble.", "Sit on the bench! Its design may be unorthodox for you, but I think it's good enough for a quick rest. To collect your thoughts and all that."],
		"dia_gardener_tieaja" : ["We've been six years without someone being taken by the angels.", "On one hand, I'm glad no one's died in so long", "On the other hand... wow, I'm really glad for that, huh?"],
		"dia_gardener_kasta" : ["I still don't know why everyone agreed to trust you.", "The last few years have been a bit too much for me to keep up with.", "Every other cluster unanimously decided that if you ever showed up, we should let you in.", "Mine decided to keep an eye on you in case you did something wrong, but that's only because I'm part of it.", "If I'm being honest, I just don't understand. I just hope they know what they're doing."],
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
