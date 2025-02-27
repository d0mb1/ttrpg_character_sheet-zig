const std = @import("std");

const Character = struct {
    allocator: std.mem.Allocator,
    characteristics: Characteristics,
    ability_scores: AbilityScores,
    secondary_abilities: SecondaryAbilities,
    skills: []Skill,
    gold: i64,
    experience: i64,
    inventory: []Item,

    pub fn init(allocator: std.mem.Allocator) !Character {
        return Character{
            .allocator = allocator,
            .characteristics = Characteristics{
                .name = "",
                .race = "",
                .gender = "",
                .visual_description = "",
                .backstory = "",
            },
            .ability_scores = AbilityScores{
                .strength = 1,
                .dexterity = 1,
                .constitution = 1,
                .intelligence = 1,
                .wisdom = 1,
                .charisma = 1,
            },
            .secondary_abilities = SecondaryAbilities{
                // Initialize secondary abilities
                .max_health = .{
                    .head = 0,
                    .chest = 0,
                    .stomach = 0,
                    .arms = 0,
                    .legs = 0,
                },
                .luck = 0,
                .carry_capacity = 0,
                .speed = 0,
                .magical_power = 0,
                .physical_power = 0,
            },
            .skills = &[_]Skill{}, // Empty slice for now
            .gold = 0,
            .experience = 0,
            .inventory = &[_]Item{}, // Empty slice for now
        };
    }
    pub fn calculateSecondaryAbilities(self: *Character) void {
        self.secondary_abilities.carry_capacity = @intCast(self.ability_scores.strength * 10);
        self.secondary_abilities.luck = self.ability_scores.charisma;
        self.secondary_abilities.magical_power = @intCast(self.ability_scores.intelligence + @as(i64, @intFromFloat(std.math.ceil(@as(f64, @floatFromInt(self.ability_scores.wisdom)) / 2.0))));
        self.secondary_abilities.physical_power = @intCast(self.ability_scores.strength + @as(i64, @intFromFloat(std.math.ceil(@as(f64, @floatFromInt(self.ability_scores.dexterity)) / 2.0))));
        self.secondary_abilities.speed = @intCast(@as(i64, @intFromFloat(std.math.ceil(@as(f64, @floatFromInt(self.ability_scores.dexterity + self.ability_scores.wisdom)) / 2.0))));
        self.secondary_abilities.max_health.arms = 4 + self.ability_scores.constitution;
        self.secondary_abilities.max_health.chest = 10 + self.ability_scores.constitution * 2;
        self.secondary_abilities.max_health.head = 5 + self.ability_scores.constitution;
        self.secondary_abilities.max_health.legs = @intCast(6 + @as(i64, @intFromFloat(std.math.ceil(@as(f64, @floatFromInt(self.ability_scores.constitution)) * 1.5))));
        self.secondary_abilities.max_health.stomach = 5 + self.ability_scores.constitution;
    }
    pub fn print(self: Character) !void {
        const stdout = std.io.getStdOut().writer();

        // Header section with character basics
        try stdout.print(
            \\.------------------------------------------------------------------------------.
            \\|                              CHARACTER SHEET                                 |
            \\|------------------------------------------------------------------------------|
            \\
            \\  Name: {s}
            \\  Race: {s}                                Gender: {s}
            \\
            \\--------------------------------------------------------------------------------
            \\  DESCRIPTION
            \\  {s}
            \\
            \\  BACKSTORY
            \\  {s}
            \\
            \\--------------------------------------------------------------------------------
            \\
        , .{
            self.characteristics.name,
            self.characteristics.race,
            self.characteristics.gender,
            self.characteristics.visual_description,
            self.characteristics.backstory,
        });

        // Ability Scores section
        try stdout.print(
            \\  ABILITY SCORES                 SECONDARY ABILITIES
            \\  --------------                 -------------------
            \\  Strength:     {:>2}               Carry Capacity:  {:>3}
            \\  Dexterity:    {:>2}               Speed:          {:>3}
            \\  Constitution: {:>2}               Luck:           {:>3}
            \\  Intelligence: {:>2}               Magical Power:  {:>3}
            \\  Wisdom:       {:>2}               Physical Power: {:>3}
            \\  Charisma:     {:>2}
            \\
            \\--------------------------------------------------------------------------------
            \\
        , .{
            self.ability_scores.strength,
            self.secondary_abilities.carry_capacity,
            self.ability_scores.dexterity,
            self.secondary_abilities.speed,
            self.ability_scores.constitution,
            self.secondary_abilities.luck,
            self.ability_scores.intelligence,
            self.secondary_abilities.magical_power,
            self.ability_scores.wisdom,
            self.secondary_abilities.physical_power,
            self.ability_scores.charisma,
        });

        // Health section
        try stdout.print(
            \\  HEALTH POINTS                   RESOURCES
            \\  -------------                   ---------
            \\  Head:     {:>3}                   Gold:       {:>6}
            \\  Chest:    {:>3}                   Experience: {:>6}
            \\  Stomach:  {:>3}
            \\  Arms:     {:>3}
            \\  Legs:     {:>3}
            \\
            \\--------------------------------------------------------------------------------
            \\
        , .{
            self.secondary_abilities.max_health.head,
            self.gold,
            self.secondary_abilities.max_health.chest,
            self.experience,
            self.secondary_abilities.max_health.stomach,
            self.secondary_abilities.max_health.arms,
            self.secondary_abilities.max_health.legs,
        });

        // Skills section
        try stdout.print(
            \\  SKILLS
            \\  ------
            \\
        , .{});

        for (self.skills) |skill| {
            try stdout.print("  {s:<20} Level: {}\n", .{ skill.name, skill.level });
        }

        // Inventory section
        try stdout.print(
            \\
            \\--------------------------------------------------------------------------------
            \\  INVENTORY
            \\  ---------
            \\
        , .{});

        for (self.inventory) |item| {
            try stdout.print("  {s}\n", .{item.name});
            switch (item.data) {
                .Weapon => |weapon| {
                    try stdout.print("    Type: Weapon    Damage: {:>2}  Range: {:>2}  Weight: {:>2}\n", .{
                        weapon.damage,
                        weapon.range,
                        weapon.weight,
                    });
                    try stdout.print("    Usage: {s}  Attribute: {s}\n", .{
                        @tagName(weapon.usage),
                        @tagName(weapon.attribute),
                    });
                },
                .Armor => |armor| {
                    try stdout.print("    Type: Armor    Defense: {:>2}  Weight: {:>2}\n", .{
                        armor.defense,
                        armor.weight,
                    });
                },
                .Consumable => |consumable| {
                    try stdout.print("    Type: Consumable    Effect: {s}\n", .{consumable.effect});
                    try stdout.print("    Duration: {}\n", .{consumable.duration});
                },
            }
            try stdout.print("\n", .{});
        }

        try stdout.print("--------------------------------------------------------------------------------\n", .{});
    }
    // pub fn print(self: Character) !void {
    //     const stdout = std.io.getStdOut().writer();
    //     try stdout.print("Name: {s}  Race: {s}  Gender: {s}\nVisual description: {s}\nBackstory: {s}\n\n", .{
    //         self.characteristics.name,
    //         self.characteristics.race,
    //         self.characteristics.gender,
    //         self.characteristics.visual_description,
    //         self.characteristics.backstory,
    //     });
    //     try stdout.print("Strength: {}\nDexterity: {}\nConstitution: {}\nIntelligence: {}\nWisdom: {}\nCharisma: {}\n\n", .{
    //         self.ability_scores.strength,
    //         self.ability_scores.dexterity,
    //         self.ability_scores.constitution,
    //         self.ability_scores.intelligence,
    //         self.ability_scores.wisdom,
    //         self.ability_scores.charisma,
    //     });
    //     try stdout.print("Carry capacity: {}\nLuck: {}\nMagical power: {}\nPhysical power: {}\nSpeed: {}\n\n", .{
    //         self.secondary_abilities.carry_capacity,
    //         self.secondary_abilities.luck,
    //         self.secondary_abilities.magical_power,
    //         self.secondary_abilities.physical_power,
    //         self.secondary_abilities.speed,
    //     });
    // }

    pub fn deinit(self: *Character) void {
        self.allocator.free(self.skills);
        self.allocator.free(self.inventory);
    }
};

const Health = struct {
    head: i64,
    chest: i64,
    stomach: i64,
    arms: i64,
    legs: i64,
};

const Characteristics = struct {
    name: []const u8,
    race: []const u8,
    gender: []const u8,
    visual_description: []const u8,
    backstory: []const u8,
};

const AbilityScores = struct {
    strength: i64,
    dexterity: i64,
    constitution: i64,
    intelligence: i64,
    wisdom: i64,
    charisma: i64,
};

const SecondaryAbilities = struct {
    max_health: Health,
    luck: i64,
    carry_capacity: i64,
    speed: i64,
    magical_power: i64,
    physical_power: i64,
};

const Skill = struct {
    name: []const u8,
    level: i64,
};

const ItemType = enum {
    Weapon,
    Armor,
    Consumable,
};

const Item = struct {
    name: []const u8,
    item_type: ItemType,
    data: ItemData,
};

const ItemData = union(ItemType) {
    Weapon: Weapon,
    Armor: Armor,
    Consumable: Consumable,
};

const Weapon = struct {
    damage: i64,
    usage: WeaponUsage,
    attribute: WeaponAtribute,
    range: i64,
    weight: i64,
};

const WeaponAtribute = enum {
    strength,
    dexterity,
    constitution,
    inteligence,
    wisdom,
    charisma,
};

const WeaponUsage = enum {
    one_hand,
    two_hands,
};

const Armor = struct {
    defense: i64,
    weight: i64,
};

const Consumable = struct {
    effect: []const u8,
    duration: i64,
};

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    try stdout.print("\n", .{});

    const allocator = gpa.allocator();

    var hero = try Character.init(allocator);
    defer hero.deinit();

    hero.calculateSecondaryAbilities();
    hero.secondary_abilities.max_health.chest -= 20;
    try hero.print();
}
