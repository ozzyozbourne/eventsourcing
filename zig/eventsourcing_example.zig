const std = @import("std");

const MAX_STATE_VALUE: f64 = 10_000;
const MIN_STATE_VALUE: f64 = 0;

const State = struct { value: f64 };
const Command = union(enum) {
    add: f64, 
    sub: f64, 
    mul: f64, 
    div: f64
};

const Event = union(enum) {
    value_added: f64, 
    value_subtracted: f64,
    value_multiplied: f64, 
    value_divided: f64,
    event_error: []const u8
};

pub fn command_handler(state: State, command: Command) Event {
    return switch(command) {
        .add => |val| .{ .value_added = @min(MAX_STATE_VALUE - state.value, val)},
        .sub => |val| .{ .value_subtracted = @max(MIN_STATE_VALUE, state.value - val)},
        .mul => |val| if (val * state.value > MAX_STATE_VALUE) .{ .event_error = "mul_failed"} else .{ .value_multiplied = val },
        .div => |val| if (val == 0) .{ .event_error = "division by zero"} else .{ .value_divided = val }
    };
}

pub fn event_handler(state: State, event: Event) State {
    return switch(event) {
        .value_added => |val| .{ .value = state.value + val },
        .value_subtracted => |val| .{ .value = state.value - val },
        .value_multiplied => |val| .{ .value = state.value * val },
        .value_divided => |val| .{ .value = @divExact(state.value, val) },
        .event_error => |val| {
            std.debug.print("Error -> {s}\n", .{val});
            return state;
        }
   };
}

pub fn process(state: State, command: Command) State {
    return event_handler(state, command_handler(state, command));
}

pub fn process_all(initial: State, cmds: []const Command) State {
    var current = initial;
    for (cmds) |cmd| { current = process(current, cmd); }
    return current;
}

test "evnets" {
    const initial = State{ .value =  0 };

    const cmds = [_]Command{
        .{ .add = 10 },
        .{ .add = 50 },
        .{ .div = 0},
        .{ .add = 2},
        .{ .add = 3 }
    };

    const res = process_all(initial, &cmds);
    std.debug.print("{d}\n", .{res.value});
}
