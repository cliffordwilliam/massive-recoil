# massive-recoil

## TODO
- Make ammo drops
- Weapon upgrade props are ready, but missing FE interface (just show buttons to upgrade any props)
- Switch room
- Add new prop so weapons/upgrades can be hidden from shop (reveal on certain events)
- Save point

## ANIMATION PIPELINE
Use aseprite to make animations:
- Set tags, each tag name has to be unique
- On a tag optionally tick repeat and set value to 1 if you do not want to loop
- Export one layer at a time
- Export settings
	- Output File: ../projects/massive-recoil/assets/sprites/wooden_crate.png
	- JSON Data: ../projects/massive-recoil/assets/sprites/wooden_crate.json
	- Array
	- Meta: Tags
	- Item Filename: {tag}-{tagframe}
	- Item Tagname: {tag}

Go to Godot
- Pick one script to be active in the engine window
- Press (CTRL + SHIFT + I) to auto create resource
- Auto create means (wooden_crate.png + wooden_crate.json = wooden_crate.tres)
- Use it in AnimatedSprite2D
- This is hot reloaded too, can repeat from step 1 again as Engine is running
