const std = @import("std");
const ini = @import("ini.zig");
const file = @embedFile("test.ini");

pub fn main() void {
    var pos: usize = 0;
    var state = ini.State.normal;
    while (ini.getTok(file, &pos, &state)) |tok| {
        switch(tok) {
            .section => |section| std.debug.print("section `{s}`\n", .{section}),
            .key => |key| std.debug.print("key `{s}`\n", .{key}),
            .value => |value| std.debug.print("value `{s}`\n", .{value}),
            .comment => std.debug.print("comment\n", .{}),
        }
    }
}
