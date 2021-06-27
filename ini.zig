const std = @import("std");

// we ignore whitespace and comments
pub const Token = union(enum) {
    comment,
    section: []const u8,
    key: []const u8,
    value: []const u8
};

pub const State = enum {
    normal, section, key, value, comment
};

pub fn getTok(data: []const u8, pos: *usize, state: *State) ?Token {
    // if the position advances to the end of the data, there's no more tokens for us
    if (pos.* >= data.len) return null;
    var cur: u8 = 0;
    // used for slicing
    var start = pos.*;
    var end = start;

    while (cur != '\n') {
        cur = data[ pos.* ];
        pos.* += 1;
        switch (state.*) {
            .normal => {
                switch (cur) {
                    '[' => {
                        state.* = .section;
                        start = pos.*;
                        end = start;
                    },
                    '=' => {
                        state.* = .value;
                        start = pos.*;
                        if (std.ascii.isSpace(data[start])) start += 1;
                        end = start;
                    },
                    ';' => {
                        state.* = .comment;
                    },
                    // if it is whitespace itgets skipped over anyways
                    else => if (!std.ascii.isSpace(cur)) {
                        state.* = .key;
                        start = pos.* - 1;
                        end = start;
                    }
                }
            },
            .section => {
                end += 1;
                switch (cur) {
                    ']' => {
                        state.* = .normal;
                        pos.* += 1;
                        return Token { .section = data[start..end - 1] };
                    },
                    else => {}
                }
            },
            .value => {
                switch (cur) {
                    ';' => {
                        state.* = .comment;
                        return Token { .value = data[start..end - 2] };
                    },
                    else => {
                        end += 1;
                        switch (cur) {
                            '\n' => {
                                state.* = .normal;
                                return Token { .value = data[start..end - 2] };
                            },
                            else => {}
                        }
                    }
                }
            },
            .comment => {
                end += 1;
                switch (cur) {
                    '\n' => {
                        state.* = .normal;
                        return Token.comment;
                    },
                    else => {}
                }
            },
            .key => {
                end += 1;
                if (!(std.ascii.isAlNum(cur) or cur == '_')) {
                    state.* = .normal;
                    return Token { .key = data[start..end] };
                }
            }
        }
    }
    return null;
}
