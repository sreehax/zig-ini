const std = @import("std");
const ini = @import("ini.zig");
const file = @embedFile("test.ini");

pub fn main() !void {
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
    const TestingConfig = struct {
        core: struct {
            foo: []const u8,
            goo: isize,
            cool: bool
        }
    };
    const lol = TestingConfig {
        .core = .{
            .foo = "bar",
            .goo = 32,
            .cool = true
        }
    };
    try ini.writeStruct(lol, std.io.getStdErr().writer());
    const NewConfig = struct {
        core: struct {
            repositoryformatversion: isize,
            filemode: bool,
            bare: bool,
            logallrefupdates: bool
        }
    };
    const str = try ini.readToStruct(NewConfig, file);
    std.debug.print("core.repositoryformatversion: {}\n", .{str.core.repositoryformatversion});
    std.debug.print("core.filemode: {}\n", .{str.core.filemode});
    std.debug.print("core.bare: {}\n", .{str.core.bare});
    std.debug.print("core.logallrefupdates: {}\n", .{str.core.logallrefupdates});
}
