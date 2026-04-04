class_name TrackData
extends Resource
## Static definition of a 0–100 weapon stat track.
##
## Defines the usable range ([member range_min] to [member range_max]) and how far the pointer
## moves per upgrade ([member step]). The live pointer is a plain [code]int[/code]
## on [WeaponPointer].

@export_range(0, 100) var range_min: int = 0
@export_range(0, 100) var range_max: int = 100
@export_range(0, 100) var step: int = 0
