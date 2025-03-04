const std = @import("std");

pub fn printWrappedText(writer: anytype, text: []const u8, indent: usize, max_width: usize) !void {
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

pub fn diceSkillNotation(level: i64) []const u8 {
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
pub fn diceAttrNotation(level: i64) []const u8 {
    return switch (level) {
        1 => "[3D4]        ",
        2 => "[2D4 + 1D6]  ",
        3 => "[1D4 + 2D6]  ",
        4 => "[3D6]        ",
        5 => "[2D6 + 1D8]  ",
        6 => "[1D6 + 2D8]  ",
        7 => "[3D8]        ",
        8 => "[2D8 + 1D10] ",
        9 => "[1D8 + 2D10] ",
        10 => "[3D10]       ",
        11 => "[2D10 + 1D12]",
        12 => "[1D10 + 2D12]",
        13 => "[3D12]       ",
        else => "[invalid]    ",
    };
}
