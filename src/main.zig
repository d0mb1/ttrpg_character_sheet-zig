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
                .strength = 6,
                .dexterity = 1,
                .constitution = 3,
                .intelligence = 12,
                .wisdom = 8,
                .charisma = 13,
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
            \\
        , .{
            self.characteristics.name,
            self.characteristics.race,
            self.characteristics.gender,
        });
        try stdout.print(
            \\--------------------------------------------------------------------------------
            \\  DESCRIPTION
            \\
        , .{});
        try printWrappedText(stdout, self.characteristics.visual_description, 2, 76);
        try stdout.print(
            \\  BACKSTORY
            \\
        , .{});
        try printWrappedText(stdout, self.characteristics.backstory, 2, 76);
        try stdout.print(
            \\
            \\--------------------------------------------------------------------------------
            \\
        , .{});

        // Ability Scores section
        try stdout.print(
            \\  ABILITY SCORES                 SECONDARY ABILITIES
            \\  --------------                 -------------------
            \\  Strength:     {:>3} {s}              Carry Capacity:  {:>3}
            \\  Dexterity:    {:>3} {s}              Speed:          {:>3}
            \\  Constitution: {:>3} {s}              Luck:           {:>3}
            \\  Intelligence: {:>3} {s}              Magical Power:  {:>3}
            \\  Wisdom:       {:>3} {s}              Physical Power: {:>3}
            \\  Charisma:     {:>3} {s}
            \\
            \\--------------------------------------------------------------------------------
            \\
        , .{
            self.ability_scores.strength,                   diceNotation(self.ability_scores.strength),
            self.secondary_abilities.carry_capacity,        self.ability_scores.dexterity,
            diceNotation(self.ability_scores.dexterity),    self.secondary_abilities.speed,
            self.ability_scores.constitution,               diceNotation(self.ability_scores.constitution),
            self.secondary_abilities.luck,                  self.ability_scores.intelligence,
            diceNotation(self.ability_scores.intelligence), self.secondary_abilities.magical_power,
            self.ability_scores.wisdom,                     diceNotation(self.ability_scores.wisdom),
            self.secondary_abilities.physical_power,        self.ability_scores.charisma,
            diceNotation(self.ability_scores.charisma),
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

    pub fn deinit(self: *Character) void {
        self.allocator.free(self.skills);
        self.allocator.free(self.inventory);
    }

    pub fn addSkill(self: *Character, name: []const u8, level: i64) !void {
        // Validate inputs
        if (name.len == 0) {
            return error.EmptySkillName;
        }
        if (level < 0 or level > 12) {
            return error.InvalidSkillLevel;
        }

        // Check if skill already exists
        for (self.skills) |skill| {
            if (std.mem.eql(u8, skill.name, name)) {
                return error.SkillAlreadyExists;
            }
        }

        // Create a new array with space for one more skill
        var new_skills = try self.allocator.alloc(Skill, self.skills.len + 1);
        errdefer self.allocator.free(new_skills); // Free new_skills if anything fails after this

        // Create the new skill name
        const skill_name = try self.allocator.dupe(u8, name);
        errdefer self.allocator.free(skill_name); // Free skill_name if anything fails after this

        // Copy existing skills and their names to the new array
        for (self.skills, 0..) |skill, i| {
            const copied_name = try self.allocator.dupe(u8, skill.name);
            errdefer {
                // If we fail after copying some names, free the ones we've copied
                for (new_skills[0..i]) |s| {
                    self.allocator.free(s.name);
                }
                self.allocator.free(copied_name);
            }
            new_skills[i] = Skill{
                .name = copied_name,
                .level = skill.level,
            };
        }

        // Add the new skill at the end
        new_skills[self.skills.len] = Skill{
            .name = skill_name,
            .level = level,
        };

        // Free the old skills array and its contents
        for (self.skills) |skill| {
            self.allocator.free(skill.name);
        }
        if (self.skills.len > 0) {
            self.allocator.free(self.skills);
        }

        // Update the skills slice to point to the new array
        self.skills = new_skills;
    }
    // pub fn addSkill(self: *Character, name: []const u8, level: i64) !void {
    //     var new_skills = try self.allocator.alloc(Skill, self.skills.len + 1);
    //
    //     @memcpy(new_skills[0..self.skills.len], self.skills);
    //
    //     const skill_name = try self.allocator.dupe(u8, name);
    //
    //     new_skills[self.skills.len] = Skill{
    //         .name = skill_name,
    //         .level = level,
    //     };
    //
    //     if (self.skills.len > 0) {
    //         for (self.skills) |skill| {
    //             self.allocator.free(skill.name);
    //         }
    //         self.allocator.free(self.skills);
    //     }
    //
    //     self.skills = new_skills;
    // }
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
    hero.characteristics.name = "Bob";
    hero.characteristics.backstory = "No backstory. He was just born. Although he managed to slay a dragon in that short time which is no short task. Bob even 5 minutes after his birth was very capable.No backstory. He was just born. Although he managed to slay a dragon in that short time which is no short task. Bob even 5 minutes after his birth was very capable.";
    hero.characteristics.gender = "Male";
    hero.characteristics.race = "Dwarf";
    hero.characteristics.visual_description = "Smol";
    try hero.addSkill("Bowling", 3);

    hero.calculateSecondaryAbilities();
    hero.secondary_abilities.max_health.chest -= 20;
    try hero.print();
}

fn printWrappedText(writer: anytype, text: []const u8, indent: usize, max_width: usize) !void {
    var line_start: usize = 0;
    var last_space: ?usize = null;
    var current_width: usize = 0;

    try writer.writeByteNTimes(' ', indent);

    for (text, 0..) |char, i| {
        if (char == ' ') {
            last_space = i;
        }

        current_width += 1;

        if (current_width >= max_width or i == text.len - 1) {
            if (last_space) |space| {
                if (i == text.len - 1 and char != ' ') {
                    try writer.print("{s}", .{text[line_start..]});
                } else {
                    try writer.print("{s}\n", .{text[line_start..space]});
                    try writer.writeByteNTimes(' ', indent);
                    line_start = space + 1;
                    current_width = i - space;
                }
            } else {
                try writer.print("{s}\n", .{text[line_start .. i + 1]});
                try writer.writeByteNTimes(' ', indent);
                line_start = i + 1;
                current_width = 0;
            }
            last_space = null;
        }
    }
    try writer.print("\n", .{});
}

fn diceNotation(level: i64) []const u8 {
    return switch (level) {
        1 => "[1D4]        ",
        2 => "[1D6]        ",
        3 => "[1D8]        ",
        4 => "[1D10]       ",
        5 => "[1D12]       ",
        6 => "[1D20]       ",
        7 => "[1D20 + 1D4] ",
        8 => "[1D20 + 1D6] ",
        9 => "[1D20 + 1D8] ",
        10 => "[1D20 + 1D10]",
        11 => "[1D20 + 1D12]",
        12 => "[2D20]       ",
        else => "[invalid]    ",
    };
}
