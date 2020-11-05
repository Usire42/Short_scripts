
import random
import math

WORDS = ['ahojK', 'hrnek', 'nastenkaK', 'hhhhh']

GESSED_WORD = random.choice(WORDS).upper()
COVERED_WORD = f"|{'_'* len(GESSED_WORD)}|"


def tipped_letter() -> str:
    tipped_letter = input('Gess a letter:').upper()
    if not tipped_letter.isalpha() and len(tipped_letter) > 1:
        raise TypeError('Only single char is allowed.')
    return tipped_letter

def find_letter(letter):
    global COVERED_WORD
    global WRONG_TIP
    a = 0
    for i, lett in enumerate(GESSED_WORD):
        if lett == letter:
            COVERED_WORD = list(COVERED_WORD)
            COVERED_WORD[i + 1] = letter
            COVERED_WORD = ''.join(COVERED_WORD)
            a += 1
    if a > 0:
        return COVERED_WORD
    else:
        WRONG_TIP -= 1
        return WRONG_TIP, COVERED_WORD

WRONG_TIP = math.ceil((len(GESSED_WORD) * 0.5))
while WRONG_TIP > 0:
    print(COVERED_WORD)
    print(GESSED_WORD)
    find_letter(tipped_letter())
    print(WRONG_TIP)





