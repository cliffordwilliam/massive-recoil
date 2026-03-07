# massive-recoil

## ENABLE FORMAT ON SAVE
The most common way to use the formatter is to have it automatically format your code every time you save:
1. Go to `Editor -> Editor Settings...`
2. Scroll down to the `GDQuest GDScript Formatter` section.
3. Enable the `Format On Save` checkbox.
4. Enable the `Reorder Code` checkbox.
5. Disable the `Safe Mode` checkbox.
6. Enable the `Lint on Safe` checkbox.
Now, every time you save a GDScript file with , the formatter will format your code. 

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

## FONT
The font being used for the FE pages pre rendered images is this

```text
# CREDITS

Monogram is a free and Creative Commons Zero pixel font,
made by Vinícius Menézio (@vmenezio).

https://datagoblin.itch.io/monogram


# SPECIAL THANKS

thanks to Ateş Göral (@atesgoral) for creating the bitmap font converter:
https://codepen.io/atesgoral/details/RwGOvPZ

thanks to Éric Araujo (@merwok_) for the inital port of monogram to PICO-8:
https://itch.io/post/2625522
```
