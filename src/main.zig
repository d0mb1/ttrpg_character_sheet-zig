const std = @import("std");

const Character = struct {
    characteristics: Characteristics,
    ability_scores: AbilityScores,
    secundary_abilities: SecundaryAbilities,
    skills: []Skill,
    gold: i64,
    experience: i64,
    inventory: []Item,

    pub fn calculateSecondaryAbilities(self: *Character) void {
        self.secundary_abilities.carry_capacity = self.ability_scores.strength * 10;
        self.secundary_abilities.luck = self.ability_scores.charisma;
        self.secundary_abilities.magical_power = self.ability_scores.inteligence + std.math.ceil(self.ability_scores.wisdom / 2.0);
        self.secundary_abilities.physical_power = self.ability_scores.strength + std.math.ceil(self.ability_scores.dexterity / 2.0);
        self.secundary_abilities.speed = std.math.ceil((self.ability_scores.dexterity + self.ability_scores.wisdom) / 2.0);
        self.secundary_abilities.max_health.arms = 4 + self.ability_scores.constitution * 1;
        self.secundary_abilities.max_health.chest = 10 + self.ability_scores.constitution * 2;
        self.secundary_abilities.max_health.head = 5 + self.ability_scores.constitution * 1;
        self.secundary_abilities.max_health.legs = 6 + std.math.ceil(self.ability_scores.constitution * 1.5);
        self.secundary_abilities.max_health.stomach = 5 + self.ability_scores.constitution * 1;
    }

    pub fn print(self: Character) !void {
        const stdout = std.io.getStdOut().writer();
        try stdout.print("Name: {s}  Race: {s}  Gender: {s}\nVisual description: {s}\nBackstory: {s}\n", .{
            self.characteristics.name,
            self.characteristics.race,
            self.characteristics.gender,
            self.characteristics.visual_discription,
            self.characteristics.backstory,
        });
        try stdout.print("Strength: {}\nDexterity: {}\nConstitution: {}\nInteligence: {}\nWisdom: {}\nCharisma: {}\n", .{
            self.ability_scores.strength,
            self.ability_scores.dexterity,
            self.ability_scores.constitution,
            self.ability_scores.inteligence,
            self.ability_scores.wisdom,
            self.ability_scores.charisma,
        });
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
    visual_discription: []const u8,
    backstory: []const u8,
};

const AbilityScores = struct {
    strength: i64,
    dexterity: i64,
    constitution: i64,
    inteligence: i64,
    wisdom: i64,
    charisma: i64,
};

const SecundaryAbilities = struct {
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
    atribute: WeaponAtribute,
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
    try stdout.print("\n", .{});

    var hero: Character = .{
        .characteristics = .{
            .name = "Gimly",
            .gender = "Male",
            .race = "Dwarf",
            .backstory = "He was just born",
            .visual_discription = "smol",
        },
        .ability_scores = .{
            .strength = 1,
            .dexterity = 1,
            .constitution = 1,
            .inteligence = 1,
            .wisdom = 1,
            .charisma = 1,
        },
        .experience = 0,
        .gold = 0,
        .secundary_abilities = .{
            .luck = 1,
            .carry_capacity = 10,
            .magical_power = 1,
            .max_health = .{
                .arms = 1,
                .chest = 1,
                .head = 1,
                .legs = 1,
                .stomach = 1,
            },
            .physical_power = 1,
            .speed = 1,
        },
        .skills = &[_]Skill{
            Skill{ .name = "Swordsmanship", .level = 1 },
            Skill{ .name = "Tracking", .level = 1 },
        },
        .inventory = &[_]Item{
            Item{
                .name = "Long Sword",
                .item_type = ItemType.Weapon,
                .data = ItemData{
                    .Weapon = Weapon{
                        .damage = 2,
                        .range = 1,
                        .atribute = .strength,
                        .usage = .two_hands,
                        .weight = 10,
                    },
                },
            },
            Item{
                .name = "Ranger's Cloak",
                .item_type = ItemType.Armor,
                .data = ItemData{
                    .Armor = Armor{
                        .defense = 5,
                        .weight = 3,
                    },
                },
            },
            Item{
                .name = "Healing Potion",
                .item_type = ItemType.Consumable,
                .data = ItemData{
                    .Consumable = Consumable{
                        .effect = "Restores 20 HP",
                        .duration = 0,
                    },
                },
            },
        },
    };
    hero.calculateSecondaryAbilities();
    try hero.print();
}
