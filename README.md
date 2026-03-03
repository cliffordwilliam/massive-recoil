# massive-recoil

## NOTE
- This game does not support dropping item, its forward filling, iventory has no max limit

## TODO
- [ ] Make ammo drops
- [ ] Make effect when weapon hit enemy and solids
- [ ] Weapon upgrade
- [ ] Switch room
- [ ] Add new prop so weapons can be hidden from shop (reveal on certain events)
- [ ] Save point

## STRUCTURE (Bound to changes)

- PageRouter (autoload)
	- Pause page
	- Game over page
	- Inventory page
	- Buy page
	- Sell page
	- Upgrade page
	- Map page
	- Tutorial page
	- Collectibles page
	- Logs page
	- Option page (This is both an overlay on Room current scene and Screen current scene)

- Game State (autoload) = Manages states like money, handgun stats, etc

- BaseRoom (current scene)
	- Player
	- Enemies
	- Shop
	- Door = Player use door to change current scene to another room
	- ...

- Screen (current scene) = for non gameplay like splash screen, main menu, etc
	- Title screen
	- Load screen
	- Main menu screen

# ANIMATION PIPELINE
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
