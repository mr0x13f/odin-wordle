#+build !windows
package wordle

import "core:sys/posix"
import "core:os/os2"

old_term: posix.termios

enable_raw :: proc() {
    posix.tcgetattr(os.stdin, &old_term)

    raw := old_term
    raw.c_lflag &= ~(posix.ICANON | posix.ECHO)
    raw.c_cc[posix.VMIN]  = 1
    raw.c_cc[posix.VTIME] = 0

    posix.tcsetattr(os.stdin, posix.TCSANOW, &raw)
}

disable_raw :: proc() {
    posix.tcsetattr(os.stdin, posix.TCSANOW, &old_term)
}

read_key :: proc() -> (key: u8) {
    os2.read(os.stdin, &key, 1)
    return
}
