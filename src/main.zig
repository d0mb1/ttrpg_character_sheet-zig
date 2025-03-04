const std = @import("std");
const ch = @import("character.zig");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    try stdout.print("\n", .{});

    const allocator = gpa.allocator();

    var hero = try ch.Character.init(allocator);
    defer hero.deinit();
    hero.characteristics.name = "Bob";
    hero.characteristics.backstory = "No backstory. He was just born. Although he managed to slay a dragon in that short time which is no short task. Bob even 5 minutes after his birth was very capable.No backstory. He was just born. Although he managed to slay a dragon in that short time which is no short task. Bob even 5 minutes after his birth was very capable.";
    hero.characteristics.gender = "Male";
    hero.characteristics.race = "Dwarf";
    hero.characteristics.visual_description = "Smol";
    try hero.addSkill("Bowling", 3);
    try hero.addSkill("Archery", 12);
    try hero.addSkill("Sneaking", 5);
    try hero.addSkill("Bakery", 9);

    // Add a weapon
    try hero.addItem(ch.Item{
        .name = "Battle Axe",
        .amount = 1,
        .item_type = .Weapon,
        .data = .{
            .Weapon = ch.Weapon{
                .damage = 8,
                .range = 1,
                .attribute = .strength,
                .usage = .two_hands,
                .weight = 7,
            },
        },
    });

    // Add armor
    try hero.addItem(ch.Item{
        .name = "Chain Mail",
        .amount = 1,
        .item_type = .Armor,
        .data = .{
            .Armor = ch.Armor{
                .defense = 15,
                .weight = 20,
            },
        },
    });

    // Add a consumable
    try hero.addItem(ch.Item{
        .name = "Health Potion",
        .amount = 10,
        .item_type = .Consumable,
        .data = .{
            .Consumable = ch.Consumable{
                .effect = "Restores 20 HP",
                .duration = 0,
            },
        },
    });

    hero.calculateSecondaryAbilities();
    hero.secondary_abilities.max_health.chest -= 20;
    try hero.print();

    try hero.removeItem("Health Potion");
    try hero.print();
    try hero.saveToJson("character.json");

    var loaded_hero = try ch.Character.loadFromJson(allocator, "character.json");
    defer loaded_hero.deinit();

    // Print loaded character
    try loaded_hero.print();
}
