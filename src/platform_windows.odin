#+build windows
package wordle

import "core:sys/windows"

old_mode: u32
stdin := windows.GetStdHandle(windows.STD_INPUT_HANDLE)

init_console :: proc() {
    stdout := windows.GetStdHandle(windows.STD_OUTPUT_HANDLE)
    mode: u32
    windows.GetConsoleMode(stdout, &mode)
    mode |= windows.ENABLE_VIRTUAL_TERMINAL_PROCESSING
    windows.SetConsoleMode(stdout, mode)
}

enable_raw :: proc() {
    windows.GetConsoleMode(stdin, &old_mode)

    new_mode := old_mode
    new_mode &= ~(windows.ENABLE_LINE_INPUT |
                  windows.ENABLE_ECHO_INPUT |
                  windows.ENABLE_PROCESSED_INPUT)

    windows.SetConsoleMode(stdin, new_mode)
    windows.FlushConsoleInputBuffer(stdin)
}

disable_raw :: proc() {
    windows.SetConsoleMode(stdin, old_mode)
}

read_key :: proc() -> (key: u8) {
    read: u32
    windows.ReadFile(stdin, &key, 1, &read, nil)
    return
}
