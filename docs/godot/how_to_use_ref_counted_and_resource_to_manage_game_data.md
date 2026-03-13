## Recommendation

Using a **`Resource` for static authored item data** and a **`RefCounted` (or other non-Resource class) for per-save runtime state** is aligned with Godot’s documented best practices:

- **Make `ItemData` and its subtypes (`ItemTreasureData`, `ItemConsumableData`, `ItemWeaponData`) custom `Resource` scripts**, saved as `.tres` files, with nested `Resource` subtypes for `SellEntryData`, `WeaponUpgradeData`, and `StatEntryData`.
- **Keep `ShopItemState` as a `RefCounted` (or similar) object that references an `ItemData`** instance and holds mutable, per-save data such as counts, level, tags, ownership, etc.
- **Let the ER-structure drive availability instead of boolean flags**: derive `can_buy`, `can_sell`, `can_upgrade` from data structure (e.g. non-empty `sell` array, non-empty `upgrades` array, non-zero `buy_price`) rather than duplicating that as explicit flags on `ItemData`.

This matches how Godot separates **serializable, inspector-authored data** (`Resource`) from **lightweight runtime-only containers** (`RefCounted`).

## Why

- **Resources are data containers, serializable, and nestable**  
  The docs define `Resource` as a base for “serializable objects” and stress that **Resources are data containers** that can be saved, loaded, and nested. This is a direct fit for your authored item definitions (`ItemData` hierarchy and its sub-resources like `SellEntryData`, `WeaponUpgradeData`, `StatEntryData`) stored as `.tres` files. Having a polymorphic `ItemData : Resource` base with specialized subtypes is exactly how the docs expect complex authored data to be modeled.

- **RefCounted is recommended for custom runtime data classes**  
  The “node alternatives” doc describes `RefCounted` as the go-to for **most cases where you need data in a custom class** but don’t need the extra serialization/inspector machinery of `Resource`. Using a `RefCounted`-based `ShopItemState` that simply *points* to an immutable `ItemData` resource and tracks dynamic, per-save values (quantities, state flags, tags) matches this guideline well.

- **Resources can serialize sub-resources recursively**  
  The resources tutorial explicitly calls out that Resources can serialize **sub-Resources recursively**, which maps neatly to your ER design of having `ItemData` own arrays of `SellEntryData`, `WeaponUpgradeData`, with `WeaponUpgradeData` containing a `StatEntryData`. Making those authored, nested `Resource` types is not just allowed, it’s a documented feature.

- **Avoid redundant flags when structure already encodes the concept**  
  While the docs don’t talk about `can_buy`/`can_sell` flags specifically, they emphasize Resources as **well-defined, structured data** with properties that can be relied upon. If your structure already encodes availability (e.g. “weapon has non-empty `upgrades` → it is upgradable”), then deriving those gameplay booleans from the existing Resource data keeps things consistent with the idea that Resources are the authoritative data container. It avoids desync between duplicated flags and the underlying arrays, which is generally better design.

## Citation

From `classes/class_resource.rst`:

> “**Base class for serializable objects.** … **Resource is the base class for all Godot-specific resource types, serving primarily as **data containers**. Since they inherit from :ref:`RefCounted<class_RefCounted>`, resources are reference-counted and freed when no longer in use. **They can also be nested within other resources, and saved on disk.**”

From `tutorials/scripting/resources.rst`:

> “**Resources are data containers. They don't do anything on their own: instead, nodes use the data contained in resources.** …  
> “Resource scripts inherit the ability to freely translate between object properties and serialized text or binary data (\*.tres, \*.res). They also inherit the reference-counting memory management from the RefCounted type. … **Resources can even serialize sub-Resources recursively, meaning users can design even more sophisticated data structures.**”

From `tutorials/best_practices/node_alternatives.rst`:

> “2. :ref:`RefCounted <class_RefCounted>`: Only a little more complex than Object. **They track references to themselves, only deleting loaded memory when no further references to themselves exist. These are useful in the majority of cases where one needs data in a custom class.**  
> …  
> “3. :ref:`Resource <class_Resource>`: Only slightly more complex than RefCounted. **They have the innate ability to serialize/deserialize (i.e. save and load) their object properties to/from Godot resource files.** … While nearly as lightweight as Object/RefCounted, **they can still display and export properties in the Inspector.**”
