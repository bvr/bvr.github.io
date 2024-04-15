
import unicodedata
import random
from rich.console import Console
from rich.panel import Panel

def get_words(input_file):
    with open(input_file, encoding='utf-8') as file:
        return [line.rstrip() for line in file]

def upper_ascii(s):
    return unicodedata.normalize('NFKD', s.upper()).encode('ASCII', 'ignore')

def show_entry(console, guess, remaining_attempts):
    console.clear()
    console.print(Panel(
        f'Remaining {str(remaining_attempts)} attempts\n'
      + get_hangman_picture(remaining_attempts) + '\n'
      + 'Word to guess:\n'
      + ' '.join([c if visible else '-'  for c,visible in guess]
    ), expand=False, title='HANGMAN'))
    console.print()

def play(console, word):
    to_guess = [(c,False) for c in word.upper()]
    tries = []
    remaining_attempts = 7
    while remaining_attempts > 0:
        show_entry(console, to_guess, remaining_attempts)
        if len(tries) > 0:
            console.print('Already tried: ' + ' '.join(tries))
        guess = console.input(f'Guess letter (? = help): ')

        if guess == '?':
            guess = random.choice([c for c, visible in to_guess if visible == False])

        visible_before = sum(visible for _,visible in to_guess)
        to_guess = [(c, visible or upper_ascii(guess) == upper_ascii(c)) for c,visible in to_guess]
        visible_after = sum(visible for _,visible in to_guess)

        if visible_after == len(to_guess):
            show_entry(console, to_guess, remaining_attempts)
            print('You won')
            break

        if visible_after == visible_before:
            tries.append(guess)
            remaining_attempts -= 1
    else:
        show_entry(console, to_guess, remaining_attempts)
        word = ' '.join([c for c,_ in to_guess])
        print(f'You lost, the word was {word}')

def main():
    words = get_words('hangman-words.txt')
    console = Console()

    while True:
        play(console, random.choice(words))
        if input("Play Again? (Y/N) ").upper() == "N":
            break

def get_hangman_picture(remaining_attempts):
    return [
"""
    ┌┬┬┬┬┬┬┬┐
   ┌┼┼┴┴┴┴┴┴┴┐
   ├┼┘       │
   ├┤       ╭┴╮
   ├┤       ╰┬╯
   ├┤      ┌─┼─┐
   ├┤      │ │ │
   ├┤        │
   ├┤       ┌┴┐
   ├┤       │ │
   ├┤      ─┘ └─
   ├┤
═══╧╧═════════════
""",
"""
    ┌┬┬┬┬┬┬┬┐
   ┌┼┼┴┴┴┴┴┴┴┐
   ├┼┘       │
   ├┤       ╭┴╮
   ├┤       ╰┬╯
   ├┤      ┌─┼─┐
   ├┤      │ │ │
   ├┤        │
   ├┤       ┌┘
   ├┤       │
   ├┤      ─┘
   ├┤
═══╧╧═════════════
""",
"""
    ┌┬┬┬┬┬┬┬┐
   ┌┼┼┴┴┴┴┴┴┴┐
   ├┼┘       │
   ├┤       ╭┴╮
   ├┤       ╰┬╯
   ├┤      ┌─┼─┐
   ├┤      │ │ │
   ├┤        │
   ├┤
   ├┤
   ├┤
   ├┤
═══╧╧═════════════
""",
"""
    ┌┬┬┬┬┬┬┬┐
   ┌┼┼┴┴┴┴┴┴┴┐
   ├┼┘       │
   ├┤       ╭┴╮
   ├┤       ╰┬╯
   ├┤      ┌─┘
   ├┤      │ 
   ├┤
   ├┤
   ├┤
   ├┤
   ├┤
═══╧╧═════════════
""",
"""
    ┌┬┬┬┬┬┬┬┐
   ┌┼┼┴┴┴┴┴┴┴┐
   ├┼┘       │
   ├┤       ╭┴╮
   ├┤       ╰─╯
   ├┤
   ├┤
   ├┤
   ├┤
   ├┤
   ├┤
   ├┤
═══╧╧═════════════
""",
"""
    ┌┬┬┬┬┬┬┬┐
   ┌┼┼┴┴┴┴┴┴┘
   ├┼┘
   ├┤
   ├┤
   ├┤
   ├┤
   ├┤
   ├┤
   ├┤
   ├┤
   ├┤
═══╧╧═════════════
""",
"""

   ┌┐
   ├┤
   ├┤
   ├┤
   ├┤
   ├┤
   ├┤
   ├┤
   ├┤
   ├┤
   ├┤
═══╧╧═════════════
""",
"""












══════════════════
""",
    ][remaining_attempts]

if __name__ == "__main__":
    main()
