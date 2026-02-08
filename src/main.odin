package wordle

import "core:unicode"
import "core:terminal/ansi"
import "core:math/rand"
import "core:strings"
import "core:slice"
import "core:fmt"

WORD_LENGTH :: 5

Word :: [WORD_LENGTH]u8
Word_With_Newline :: [WORD_LENGTH+1]u8

valid_words:  []Word_With_Newline = #load("words/valid-5-letter-words.txt")
common_words: []Word_With_Newline = #load("words/common-5-letter-words.txt")

main :: proc() {

    answer := random_common_word()

    for _ in 0..<WORD_LENGTH { fmt.print(".") }
    fmt.println()
    
    for {
        guess, exit := take_guess()
        if exit {
            fmt.printfln("\nThe word was: %s", strings.to_upper(string(answer[:]), context.temp_allocator))
            break
        }

        if !is_valid_word(guess) { continue }
        print_guess(guess, answer)

        if guess == answer { break }
    }

}

print_guess :: proc(guess: Word, answer: Word) {
    answer := answer

    for c, i in guess {
        if c == answer[i] {
            fmt.print(ansi.CSI + ansi.BG_GREEN + ansi.SGR)
        } else if slice.contains(answer[:], c) {
            fmt.print(ansi.CSI + ansi.BG_YELLOW + ansi.SGR)
        }
        fmt.print(unicode.to_upper(rune(c)))
        fmt.print(ansi.CSI + ansi.RESET + ansi.SGR)
    }

    fmt.println()
}

random_common_word :: proc() -> (word: Word) {
    word_with_newline := rand.choice(common_words)
    copy(word[:], word_with_newline[:WORD_LENGTH])
    return
}

is_valid_word :: proc(word: Word) -> bool {

    compare :: proc(l: Word_With_Newline, r: Word) -> slice.Ordering {
        left, right := l, r
        left_str := string(left[:WORD_LENGTH])
        right_str := string(right[:])
        return slice.Ordering(strings.compare(left_str, right_str))
    }

    _, found := slice.binary_search_by(valid_words, word, compare)

    return found
}

take_guess :: proc() -> (word: Word, exit: bool) {
    enable_raw()
    defer disable_raw()

    count := 0
    for {
        key := read_key()
        // Enter
        if key == '\r' || key == '\n' {
            if count == WORD_LENGTH {
                // erase the line
                fmt.print("\r\x1b[2K")
                return
            }
        // Backspace
        } else if key == 8 || key == 127 {
            if count > 0 {
                count -= 1
                fmt.print("\b \b")
            }
            continue
        // Only allow a–z
        } else if key >= 'a' && key <= 'z' {
            if count < WORD_LENGTH {
                word[count] = key
                count += 1
                fmt.printf("%c", rune(key))
            }
        // Exit
        } else if key == 3 {
            exit = true
            fmt.print("\r\x1b[2K")
            return
        }
    }
}
