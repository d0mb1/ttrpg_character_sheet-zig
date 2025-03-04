const std = @import("std");
const fns = @import("fns.zig");

pub const Character = struct {
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
            .skills = &[_]Skill{},
            .gold = 0,
            .experience = 0,
            .inventory = &[_]Item{},
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
        try fns.printWrappedText(stdout, self.characteristics.visual_description, 2, 76);
        try stdout.print(
            \\  BACKSTORY
            \\
        , .{});
        try fns.printWrappedText(stdout, self.characteristics.backstory, 2, 76);
        try stdout.print(
            \\
            \\--------------------------------------------------------------------------------
            \\
        , .{});

        // Ability Scores section
        try stdout.print(
            \\  ABILITY SCORES                          SECONDARY ABILITIES
            \\  --------------                          -------------------
            \\  Strength:     {:>3} {s}         Carry Capacity: {:>3}
            \\  Dexterity:    {:>3} {s}         Speed:          {:>3}
            \\  Constitution: {:>3} {s}         Luck:           {:>3}
            \\  Intelligence: {:>3} {s}         Magical Power:  {:>3}
            \\  Wisdom:       {:>3} {s}         Physical Power: {:>3}
            \\  Charisma:     {:>3} {s}
            \\
            \\--------------------------------------------------------------------------------
            \\
        , .{
            self.ability_scores.strength,                           fns.diceAttrNotation(self.ability_scores.strength),
            self.secondary_abilities.carry_capacity,                self.ability_scores.dexterity,
            fns.diceAttrNotation(self.ability_scores.dexterity),    self.secondary_abilities.speed,
            self.ability_scores.constitution,                       fns.diceAttrNotation(self.ability_scores.constitution),
            self.secondary_abilities.luck,                          self.ability_scores.intelligence,
            fns.diceAttrNotation(self.ability_scores.intelligence), self.secondary_abilities.magical_power,
            self.ability_scores.wisdom,                             fns.diceAttrNotation(self.ability_scores.wisdom),
            self.secondary_abilities.physical_power,                self.ability_scores.charisma,
            fns.diceAttrNotation(self.ability_scores.charisma),
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
            try stdout.print("  {s:<20} Level: {: >3} {s}\n", .{ skill.name, skill.level, fns.diceSkillNotation(skill.level) });
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
            try stdout.print("  {s} - {}x\n", .{ item.name, item.amount });
            switch (item.data) {
                .Weapon => |weapon| {
                    try stdout.print("      Type: Weapon    Damage: {:>2}  Range: {:>2}  Weight: {:>2}\n", .{
                        weapon.damage,
                        weapon.range,
                        weapon.weight,
                    });
                    try stdout.print("      Usage: {s}  Attribute: {s}\n", .{
                        @tagName(weapon.usage),
                        @tagName(weapon.attribute),
                    });
                },
                .Armor => |armor| {
                    try stdout.print("      Type: Armor    Defense: {:>2}  Weight: {:>2}\n", .{
                        armor.defense,
                        armor.weight,
                    });
                },
                .Consumable => |consumable| {
                    try stdout.print("      Type: Consumable    Effect: {s}\n", .{consumable.effect});
                    try stdout.print("      Duration: {}\n", .{consumable.duration});
                },
            }
            try stdout.print("\n", .{});
        }

        try stdout.print("--------------------------------------------------------------------------------\n", .{});
    }

    pub fn deinit(self: *Character) void {
        // Free characteristics strings
        self.allocator.free(self.characteristics.name);
        self.allocator.free(self.characteristics.race);
        self.allocator.free(self.characteristics.gender);
        self.allocator.free(self.characteristics.visual_description);
        self.allocator.free(self.characteristics.backstory);
        // Free skills
        for (self.skills) |skill| {
            self.allocator.free(skill.name);
        }
        if (self.skills.len > 0) {
            self.allocator.free(self.skills);
        }

        // Free inventory
        for (self.inventory) |item| {
            self.allocator.free(item.name);
            if (item.data == .Consumable) {
                self.allocator.free(item.data.Consumable.effect);
            }
        }
        if (self.inventory.len > 0) {
            self.allocator.free(self.inventory);
        }
    }

    pub fn addItem(self: *Character, item: Item) !void {
        // First check if the item already exists
        for (self.inventory) |*existing_item| {
            if (std.mem.eql(u8, existing_item.name, item.name) and
                existing_item.item_type == item.item_type)
            {
                // If item exists, just increase the amount
                existing_item.amount += item.amount;
                return;
            }
        }

        // If item doesn't exist, create a new array with space for one more item
        var new_inventory = try self.allocator.alloc(Item, self.inventory.len + 1);
        errdefer self.allocator.free(new_inventory);

        // Copy all existing items
        for (self.inventory, 0..) |existing_item, i| {
            // Duplicate the name for each existing item
            const item_name = try self.allocator.dupe(u8, existing_item.name);
            errdefer self.allocator.free(item_name);

            new_inventory[i] = Item{
                .name = item_name,
                .amount = existing_item.amount,
                .item_type = existing_item.item_type,
                .data = switch (existing_item.data) {
                    .Weapon => |weapon| ItemData{ .Weapon = weapon },
                    .Armor => |armor| ItemData{ .Armor = armor },
                    .Consumable => |consumable| ItemData{
                        .Consumable = Consumable{
                            .effect = try self.allocator.dupe(u8, consumable.effect),
                            .duration = consumable.duration,
                        },
                    },
                },
            };
        }

        // Add the new item
        const new_item_name = try self.allocator.dupe(u8, item.name);
        errdefer self.allocator.free(new_item_name);

        new_inventory[self.inventory.len] = Item{
            .name = new_item_name,
            .amount = item.amount,
            .item_type = item.item_type,
            .data = switch (item.data) {
                .Weapon => |weapon| ItemData{ .Weapon = weapon },
                .Armor => |armor| ItemData{ .Armor = armor },
                .Consumable => |consumable| ItemData{
                    .Consumable = Consumable{
                        .effect = try self.allocator.dupe(u8, consumable.effect),
                        .duration = consumable.duration,
                    },
                },
            },
        };

        // Free old inventory array and its contents
        for (self.inventory) |old_item| {
            self.allocator.free(old_item.name);
            if (old_item.data == .Consumable) {
                self.allocator.free(old_item.data.Consumable.effect);
            }
        }
        if (self.inventory.len > 0) {
            self.allocator.free(self.inventory);
        }

        // Update the inventory slice
        self.inventory = new_inventory;
    }

    pub fn removeItem(self: *Character, item_name: []const u8) !void {
        // Validate input
        if (item_name.len == 0) {
            return error.EmptyItemName;
        }

        // Find the item
        for (self.inventory, 0..) |item, index| {
            if (std.mem.eql(u8, item.name, item_name)) {
                // Create new inventory with one less item
                var new_inventory = try self.allocator.alloc(Item, self.inventory.len - 1);
                errdefer self.allocator.free(new_inventory);

                // Copy items before the removed one
                for (self.inventory[0..index], 0..) |existing_item, i| {
                    const item_name_copy = try self.allocator.dupe(u8, existing_item.name);
                    errdefer self.allocator.free(item_name_copy);

                    new_inventory[i] = Item{
                        .name = item_name_copy,
                        .amount = existing_item.amount,
                        .item_type = existing_item.item_type,
                        .data = switch (existing_item.data) {
                            .Weapon => |weapon| ItemData{ .Weapon = weapon },
                            .Armor => |armor| ItemData{ .Armor = armor },
                            .Consumable => |consumable| ItemData{
                                .Consumable = Consumable{
                                    .effect = try self.allocator.dupe(u8, consumable.effect),
                                    .duration = consumable.duration,
                                },
                            },
                        },
                    };
                }

                // Copy items after the removed one
                for (self.inventory[index + 1 ..], 0..) |existing_item, i| {
                    const item_name_copy = try self.allocator.dupe(u8, existing_item.name);
                    errdefer self.allocator.free(item_name_copy);

                    new_inventory[i] = Item{
                        .name = item_name_copy,
                        .amount = existing_item.amount,
                        .item_type = existing_item.item_type,
                        .data = switch (existing_item.data) {
                            .Weapon => |weapon| ItemData{ .Weapon = weapon },
                            .Armor => |armor| ItemData{ .Armor = armor },
                            .Consumable => |consumable| ItemData{
                                .Consumable = Consumable{
                                    .effect = try self.allocator.dupe(u8, consumable.effect),
                                    .duration = consumable.duration,
                                },
                            },
                        },
                    };
                }

                // Free the old inventory
                for (self.inventory) |old_item| {
                    self.allocator.free(old_item.name);
                    if (old_item.data == .Consumable) {
                        self.allocator.free(old_item.data.Consumable.effect);
                    }
                }
                self.allocator.free(self.inventory);

                // Update inventory
                self.inventory = new_inventory;
                return;
            }
        }

        return error.ItemNotFound;
    }

    pub fn addSkill(self: *Character, name: []const u8, level: i64) !void {
        // Validate inputs
        if (name.len == 0) {
            return error.EmptySkillName;
        }

        // Check if skill already exists
        for (self.skills) |skill| {
            if (std.mem.eql(u8, skill.name, name)) {
                return error.SkillAlreadyExists;
            }
        }

        // Create a new array with space for one more skill
        var new_skills = try self.allocator.alloc(Skill, self.skills.len + 1);
        errdefer self.allocator.free(new_skills);

        // Copy all existing skills
        for (self.skills, 0..) |skill, i| {
            // Duplicate the name for each existing skill
            const skill_name = try self.allocator.dupe(u8, skill.name);
            errdefer self.allocator.free(skill_name);

            new_skills[i] = Skill{
                .name = skill_name,
                .level = skill.level,
            };
        }

        // Create and add the new skill
        const new_skill_name = try self.allocator.dupe(u8, name);
        errdefer self.allocator.free(new_skill_name);

        new_skills[self.skills.len] = Skill{
            .name = new_skill_name,
            .level = level,
        };

        // Free old skills array and its contents
        for (self.skills) |skill| {
            self.allocator.free(skill.name);
        }
        if (self.skills.len > 0) {
            self.allocator.free(self.skills);
        }

        // Update the skills slice
        self.skills = new_skills;
    }

    pub fn saveToJson(self: Character, file_path: []const u8) !void {
        // Create a JSON string
        var string = std.ArrayList(u8).init(self.allocator);
        defer string.deinit();

        try std.json.stringify(.{
            .characteristics = .{
                .name = self.characteristics.name,
                .race = self.characteristics.race,
                .gender = self.characteristics.gender,
                .visual_description = self.characteristics.visual_description,
                .backstory = self.characteristics.backstory,
            },
            .ability_scores = .{
                .strength = self.ability_scores.strength,
                .dexterity = self.ability_scores.dexterity,
                .constitution = self.ability_scores.constitution,
                .intelligence = self.ability_scores.intelligence,
                .wisdom = self.ability_scores.wisdom,
                .charisma = self.ability_scores.charisma,
            },
            .secondary_abilities = .{
                .max_health = .{
                    .head = self.secondary_abilities.max_health.head,
                    .chest = self.secondary_abilities.max_health.chest,
                    .stomach = self.secondary_abilities.max_health.stomach,
                    .arms = self.secondary_abilities.max_health.arms,
                    .legs = self.secondary_abilities.max_health.legs,
                },
                .luck = self.secondary_abilities.luck,
                .carry_capacity = self.secondary_abilities.carry_capacity,
                .speed = self.secondary_abilities.speed,
                .magical_power = self.secondary_abilities.magical_power,
                .physical_power = self.secondary_abilities.physical_power,
            },
            .skills = self.skills,
            .gold = self.gold,
            .experience = self.experience,
            .inventory = @as([]const Item, self.inventory),
        }, .{ .whitespace = .indent_4 }, string.writer());

        // Write to file
        const file = try std.fs.cwd().createFile(file_path, .{});
        defer file.close();

        try file.writeAll(string.items);
    }

    pub fn loadFromJson(allocator: std.mem.Allocator, file_path: []const u8) !Character {
        // Read the file
        const file = try std.fs.cwd().openFile(file_path, .{});
        defer file.close();

        const file_size = try file.getEndPos();
        const buffer = try allocator.alloc(u8, file_size);
        defer allocator.free(buffer);
        _ = try file.readAll(buffer);

        // Parse JSON
        var json = try std.json.parseFromSlice(
            std.json.Value,
            allocator,
            buffer,
            .{},
        );
        defer json.deinit();

        const root = json.value;

        // Create character from parsed data
        var character = Character{
            .allocator = allocator,
            .characteristics = .{
                .name = try allocator.dupe(u8, root.object.get("characteristics").?.object.get("name").?.string),
                .race = try allocator.dupe(u8, root.object.get("characteristics").?.object.get("race").?.string),
                .gender = try allocator.dupe(u8, root.object.get("characteristics").?.object.get("gender").?.string),
                .visual_description = try allocator.dupe(u8, root.object.get("characteristics").?.object.get("visual_description").?.string),
                .backstory = try allocator.dupe(u8, root.object.get("characteristics").?.object.get("backstory").?.string),
            },
            .ability_scores = .{
                .strength = @as(i64, @intCast(root.object.get("ability_scores").?.object.get("strength").?.integer)),
                .dexterity = @as(i64, @intCast(root.object.get("ability_scores").?.object.get("dexterity").?.integer)),
                .constitution = @as(i64, @intCast(root.object.get("ability_scores").?.object.get("constitution").?.integer)),
                .intelligence = @as(i64, @intCast(root.object.get("ability_scores").?.object.get("intelligence").?.integer)),
                .wisdom = @as(i64, @intCast(root.object.get("ability_scores").?.object.get("wisdom").?.integer)),
                .charisma = @as(i64, @intCast(root.object.get("ability_scores").?.object.get("charisma").?.integer)),
            },
            .secondary_abilities = .{
                .max_health = .{
                    .head = @as(i64, @intCast(root.object.get("secondary_abilities").?.object.get("max_health").?.object.get("head").?.integer)),
                    .chest = @as(i64, @intCast(root.object.get("secondary_abilities").?.object.get("max_health").?.object.get("chest").?.integer)),
                    .stomach = @as(i64, @intCast(root.object.get("secondary_abilities").?.object.get("max_health").?.object.get("stomach").?.integer)),
                    .arms = @as(i64, @intCast(root.object.get("secondary_abilities").?.object.get("max_health").?.object.get("arms").?.integer)),
                    .legs = @as(i64, @intCast(root.object.get("secondary_abilities").?.object.get("max_health").?.object.get("legs").?.integer)),
                },
                .luck = @as(i64, @intCast(root.object.get("secondary_abilities").?.object.get("luck").?.integer)),
                .carry_capacity = @as(i64, @intCast(root.object.get("secondary_abilities").?.object.get("carry_capacity").?.integer)),
                .speed = @as(i64, @intCast(root.object.get("secondary_abilities").?.object.get("speed").?.integer)),
                .magical_power = @as(i64, @intCast(root.object.get("secondary_abilities").?.object.get("magical_power").?.integer)),
                .physical_power = @as(i64, @intCast(root.object.get("secondary_abilities").?.object.get("physical_power").?.integer)),
            },
            .gold = @as(i64, @intCast(root.object.get("gold").?.integer)),
            .experience = @as(i64, @intCast(root.object.get("experience").?.integer)),
            .skills = &[_]Skill{},
            .inventory = &[_]Item{},
        };

        // Load skills
        const skills = root.object.get("skills").?.array;
        var character_skills = try allocator.alloc(Skill, skills.items.len);
        for (skills.items, 0..) |skill, i| {
            character_skills[i] = .{
                .name = try allocator.dupe(u8, skill.object.get("name").?.string),
                .level = @as(i64, @intCast(skill.object.get("level").?.integer)),
            };
        }
        character.skills = character_skills;

        // Load inventory
        const inventory = root.object.get("inventory").?.array;
        var character_inventory = try allocator.alloc(Item, inventory.items.len);
        for (inventory.items, 0..) |item, i| {
            const item_type_str = item.object.get("item_type").?.string;
            const item_type = std.meta.stringToEnum(ItemType, item_type_str) orelse return error.InvalidItemType;
            const item_data = item.object.get("data").?.object;

            character_inventory[i] = .{
                .name = try allocator.dupe(u8, item.object.get("name").?.string),
                .amount = @as(i64, @intCast(item.object.get("amount").?.integer)),
                .item_type = item_type,
                .data = switch (item_type) {
                    .Weapon => .{
                        .Weapon = .{
                            .damage = @as(i64, @intCast(item_data.get("Weapon").?.object.get("damage").?.integer)),
                            .range = @as(i64, @intCast(item_data.get("Weapon").?.object.get("range").?.integer)),
                            .weight = @as(i64, @intCast(item_data.get("Weapon").?.object.get("weight").?.integer)),
                            .usage = std.meta.stringToEnum(WeaponUsage, item_data.get("Weapon").?.object.get("usage").?.string) orelse return error.InvalidWeaponUsage,
                            .attribute = std.meta.stringToEnum(WeaponAtribute, item_data.get("Weapon").?.object.get("attribute").?.string) orelse return error.InvalidWeaponAttribute,
                        },
                    },
                    .Armor => .{
                        .Armor = .{
                            .defense = @as(i64, @intCast(item_data.get("Armor").?.object.get("defense").?.integer)),
                            .weight = @as(i64, @intCast(item_data.get("Armor").?.object.get("weight").?.integer)),
                        },
                    },
                    .Consumable => .{
                        .Consumable = .{
                            .effect = try allocator.dupe(u8, item_data.get("Consumable").?.object.get("effect").?.string),
                            .duration = @as(i64, @intCast(item_data.get("Consumable").?.object.get("duration").?.integer)),
                        },
                    },
                },
            };
        }
        character.inventory = character_inventory;

        return character;
    }
    // pub fn loadFromJson(allocator: std.mem.Allocator, file_path: []const u8) !Character {
    //     // Read the file
    //     const file = try std.fs.cwd().openFile(file_path, .{});
    //     defer file.close();
    //
    //     const file_size = try file.getEndPos();
    //     const buffer = try allocator.alloc(u8, file_size);
    //     defer allocator.free(buffer);
    //     _ = try file.readAll(buffer);
    //
    //     // Parse JSON
    //     var parser = std.json.Parser.init(allocator, false);
    //     defer parser.deinit();
    //
    //     var tree = try parser.parse(buffer);
    //     defer tree.deinit();
    //
    //     const root = tree.root;
    //
    //     // Create character from parsed data
    //     var character = Character{
    //         .allocator = allocator,
    //         .characteristics = Characteristics{
    //             .name = try allocator.dupe(u8, root.Object.get("characteristics").?.Object.get("name").?.String),
    //             .race = try allocator.dupe(u8, root.Object.get("characteristics").?.Object.get("race").?.String),
    //             .gender = try allocator.dupe(u8, root.Object.get("characteristics").?.Object.get("gender").?.String),
    //             .visual_description = try allocator.dupe(u8, root.Object.get("characteristics").?.Object.get("visual_description").?.String),
    //             .backstory = try allocator.dupe(u8, root.Object.get("characteristics").?.Object.get("backstory").?.String),
    //         },
    //         .ability_scores = AbilityScores{
    //             .strength = root.Object.get("ability_scores").?.Object.get("strength").?.Integer,
    //             .dexterity = root.Object.get("ability_scores").?.Object.get("dexterity").?.Integer,
    //             .constitution = root.Object.get("ability_scores").?.Object.get("constitution").?.Integer,
    //             .intelligence = root.Object.get("ability_scores").?.Object.get("intelligence").?.Integer,
    //             .wisdom = root.Object.get("ability_scores").?.Object.get("wisdom").?.Integer,
    //             .charisma = root.Object.get("ability_scores").?.Object.get("charisma").?.Integer,
    //         },
    //         .secondary_abilities = SecondaryAbilities{
    //             .max_health = Health{
    //                 .head = root.Object.get("secondary_abilities").?.Object.get("max_health").?.Object.get("head").?.Integer,
    //                 .chest = root.Object.get("secondary_abilities").?.Object.get("max_health").?.Object.get("chest").?.Integer,
    //                 .stomach = root.Object.get("secondary_abilities").?.Object.get("max_health").?.Object.get("stomach").?.Integer,
    //                 .arms = root.Object.get("secondary_abilities").?.Object.get("max_health").?.Object.get("arms").?.Integer,
    //                 .legs = root.Object.get("secondary_abilities").?.Object.get("max_health").?.Object.get("legs").?.Integer,
    //             },
    //             .luck = root.Object.get("secondary_abilities").?.Object.get("luck").?.Integer,
    //             .carry_capacity = root.Object.get("secondary_abilities").?.Object.get("carry_capacity").?.Integer,
    //             .speed = root.Object.get("secondary_abilities").?.Object.get("speed").?.Integer,
    //             .magical_power = root.Object.get("secondary_abilities").?.Object.get("magical_power").?.Integer,
    //             .physical_power = root.Object.get("secondary_abilities").?.Object.get("physical_power").?.Integer,
    //         },
    //         .gold = root.Object.get("gold").?.Integer,
    //         .experience = root.Object.get("experience").?.Integer,
    //         .skills = &[_]Skill{},
    //         .inventory = &[_]Item{},
    //     };
    //
    //     // Load skills
    //     const skills_array = root.Object.get("skills").?.Array;
    //     var skills = try allocator.alloc(Skill, skills_array.items.len);
    //     for (skills_array.items, 0..) |skill, i| {
    //         skills[i] = Skill{
    //             .name = try allocator.dupe(u8, skill.Object.get("name").?.String),
    //             .level = skill.Object.get("level").?.Integer,
    //         };
    //     }
    //     character.skills = skills;
    //
    //     // Load inventory
    //     const inventory_array = root.Object.get("inventory").?.Array;
    //     var inventory = try allocator.alloc(Item, inventory_array.items.len);
    //     for (inventory_array.items, 0..) |item, i| {
    //         const item_type_str = item.Object.get("item_type").?.String;
    //         const item_type = std.meta.stringToEnum(ItemType, item_type_str) orelse return error.InvalidItemType;
    //
    //         inventory[i] = Item{
    //             .name = try allocator.dupe(u8, item.Object.get("name").?.String),
    //             .amount = item.Object.get("amount").?.Integer,
    //             .item_type = item_type,
    //             .data = switch (item_type) {
    //                 .Weapon => ItemData{
    //                     .Weapon = Weapon{
    //                         .damage = item.Object.get("data").?.Object.get("damage").?.Integer,
    //                         .range = item.Object.get("data").?.Object.get("range").?.Integer,
    //                         .weight = item.Object.get("data").?.Object.get("weight").?.Integer,
    //                         .usage = std.meta.stringToEnum(WeaponUsage, item.Object.get("data").?.Object.get("usage").?.String) orelse return error.InvalidWeaponUsage,
    //                         .attribute = std.meta.stringToEnum(WeaponAtribute, item.Object.get("data").?.Object.get("attribute").?.String) orelse return error.InvalidWeaponAttribute,
    //                     },
    //                 },
    //                 .Armor => ItemData{
    //                     .Armor = Armor{
    //                         .defense = item.Object.get("data").?.Object.get("defense").?.Integer,
    //                         .weight = item.Object.get("data").?.Object.get("weight").?.Integer,
    //                     },
    //                 },
    //                 .Consumable => ItemData{
    //                     .Consumable = Consumable{
    //                         .effect = try allocator.dupe(u8, item.Object.get("data").?.Object.get("effect").?.String),
    //                         .duration = item.Object.get("data").?.Object.get("duration").?.Integer,
    //                     },
    //                 },
    //             },
    //         };
    //     }
    //     character.inventory = inventory;
    //
    //     return character;
    // }
    //
    // pub fn loadFromJson(allocator: std.mem.Allocator, file_path: []const u8) !Character {
    //     // Read the file
    //     const file = try std.fs.cwd().openFile(file_path, .{});
    //     defer file.close();
    //
    //     const file_size = try file.getEndPos();
    //     const buffer = try allocator.alloc(u8, file_size);
    //     defer allocator.free(buffer);
    //     _ = try file.readAll(buffer);
    //
    //     // Parse JSON
    //     var stream = std.json.TokenStream.init(buffer);
    //     const options = std.json.ParseOptions{
    //         .allocator = allocator,
    //         .ignore_unknown_fields = true,
    //     };
    //
    //     const CharacterJson = struct {
    //         characteristics: Characteristics,
    //         ability_scores: AbilityScores,
    //         secondary_abilities: SecondaryAbilities,
    //         skills: []Skill,
    //         gold: i64,
    //         experience: i64,
    //         inventory: []Item,
    //     };
    //
    //     const parsed = try std.json.parse(CharacterJson, &stream, options);
    //     defer std.json.parseFree(CharacterJson, parsed, options);
    //
    //     // Create character from parsed data
    //     var character = Character{
    //         .allocator = allocator,
    //         .characteristics = Characteristics{
    //             .name = try allocator.dupe(u8, parsed.characteristics.name),
    //             .race = try allocator.dupe(u8, parsed.characteristics.race),
    //             .gender = try allocator.dupe(u8, parsed.characteristics.gender),
    //             .visual_description = try allocator.dupe(u8, parsed.characteristics.visual_description),
    //             .backstory = try allocator.dupe(u8, parsed.characteristics.backstory),
    //         },
    //         .ability_scores = parsed.ability_scores,
    //         .secondary_abilities = parsed.secondary_abilities,
    //         .skills = try allocator.alloc(Skill, parsed.skills.len),
    //         .gold = parsed.gold,
    //         .experience = parsed.experience,
    //         .inventory = try allocator.alloc(Item, parsed.inventory.len),
    //     };
    //
    //     // Copy skills
    //     for (parsed.skills, 0..) |skill, i| {
    //         character.skills[i] = Skill{
    //             .name = try allocator.dupe(u8, skill.name),
    //             .level = skill.level,
    //         };
    //     }
    //
    //     // Copy inventory
    //     for (parsed.inventory, 0..) |item, i| {
    //         character.inventory[i] = Item{
    //             .name = try allocator.dupe(u8, item.name),
    //             .amount = item.amount,
    //             .item_type = item.item_type,
    //             .data = switch (item.data) {
    //                 .Weapon => |weapon| ItemData{ .Weapon = weapon },
    //                 .Armor => |armor| ItemData{ .Armor = armor },
    //                 .Consumable => |consumable| ItemData{
    //                     .Consumable = Consumable{
    //                         .effect = try allocator.dupe(u8, consumable.effect),
    //                         .duration = consumable.duration,
    //                     },
    //                 },
    //             },
    //         };
    //     }
    //
    //     return character;
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

pub const Item = struct {
    name: []const u8,
    amount: i64,
    item_type: ItemType,
    data: ItemData,
};

const ItemData = union(ItemType) {
    Weapon: Weapon,
    Armor: Armor,
    Consumable: Consumable,
};

pub const Weapon = struct {
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

pub const Armor = struct {
    defense: i64,
    weight: i64,
};

pub const Consumable = struct {
    effect: []const u8,
    duration: i64,
};
