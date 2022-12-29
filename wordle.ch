
readfile "PRELUDE.ch".  % Load some standard functions

readfile "common_word_list.ch".   % Load the dictionary of allowed words.

data letter = char.
data word = list(char).


def sum_int_list: list(int) -> int =
  ns => {|
      nil: () => 0
    | cons: (n, m) => add_int(n, m)
  |} ns.


data colour -> C 
  = green: 1 -> C
  | yellow: 1 -> C
  | grey: 1 -> C.

% It seems we don't get an equality operator for free when we add a new type!?

def eq_colour: colour * colour -> bool
       = (green, green) => true
       | (yellow, yellow) => true
       | (grey, grey) => true
       | _              => false.


% Drop the *last* matching element from a list (using a given equality function) if any
% are present. The returned boolean shows whether the element was found or not.

def remove_element{eq: A * A -> bool}: A * list(A) -> list(A) * bool =
  (elt, xs) => {| 
      nil: () => ([], false)
    | cons: (curr_el, (ys, removed)) => 
      (
        {
            (true, _) => (cons(curr_el, ys), true)
          | (false, true) => (ys, true)
          | (false, false) => (cons(curr_el, ys), false)
        } (removed, eq(elt, curr_el))
      )
  |} xs.

% Define list membership in terms of removal :D

def list_membership{eq: A * A -> bool}: A * list(A) -> bool =
  (elt, xs) => p1 remove_element{eq}(elt, xs).


% Which letters are green?

def green_bools: word * word -> list(bool) =
  (secret, guess) => list{eq_char}(zip(secret, guess)).


% Which letters are yellow?
 
def non_green_letters_in_guess: word * word -> list(letter) =
  (secret, guess) => list{p0} filter{(l1, l2) => not(eq_char(l1, l2))} zip(secret, guess).

def yellow_bools_helper: list(letter * bool) * list(letter) -> list(bool) = 
  (guess_with_green_bools, non_green_letters) => p0 {|
      nil: () => ([], non_green_letters)
    | cons: ((l, is_green), (res, non_green_left)) | is_green => (cons(false, res), non_green_left)
                                                   | .. => (
        {
            (with_removed, true)  => (cons(true,  res), with_removed)
          | (_, false)            => (cons(false, res), non_green_left)
        } remove_element{eq_char}(l, non_green_left)
      )
  |} guess_with_green_bools.
  
def yellow_bools: word * word -> list(bool) = 
  (secret, guess) => 
    reverse(
      yellow_bools_helper(
        reverse(zip(guess, green_bools(secret, guess))),
        non_green_letters_in_guess(secret, guess)
      )
    ).


def evaluate_guess: word * word -> list(colour) =
  (secret, guess) => list{
    x => { 
        (true, false) => green
      | (false, true) => yellow
      | _             => grey
      } x
  } zip(green_bools(secret, guess), yellow_bools(secret, guess)).


data game_state = list(word * list(colour)).

 
% Check whether a candidate word is a possibility in a given game state.

def is_possible: game_state * word -> bool =
  (state, candidate_word) => {|
      nil: () => true
    | cons: ((guess, colours), possible) | not possible => false
                                         | .. => eq_list{eq_colour}(evaluate_guess(candidate_word, guess), colours)
  |} state. 

def possible_words: game_state -> list(word) =
  state => filter{candidate_word => is_possible(state, candidate_word)} allowed_words.


% We use a simple heuristic to score the options for our next guess: we'd like to guess a word
% which is expected to lead to a lot of green and yellow letters.

def score_colours: list(colour) -> int =
  colours => sum_int_list list{
    col => {
        green => 2
      | yellow => 1
      | grey => 0
    } col
  } colours.


% Given a list of the remaining possible words, and a candidate word, heuristically score the candidate.

def score_word: word * list(word) -> int = 
  (candidate, possibilities) => sum_int_list list{
      possibility => score_colours(evaluate_guess(possibility, candidate))
  } possibilities.


% Given a list of the remaining possible candidate words, 'choose_best_word' heuristically chooses the best to guess.

def choose_best: (list(A) * list(int)) * (A * int) -> (A * int) =
  ((xs, scores), (dummy_x, dummy_score)) => {|
      nil: () => (dummy_x, dummy_score)
    | cons: ((x, score), (best_x, best_score)) | gt_int(score, best_score) => (x, score)
                                               | .. => (best_x, best_score)
  |} zip(xs, scores).

def choose_best_word: list(word) -> word =
  candidates => p0 choose_best(
    (candidates, list{candidate => score_word(candidate, candidates)} candidates),
    ("", -1)
  ).


% Tie the above stuff together: what should we guess in a given game state?

def play_turn: game_state -> word = 
  state => choose_best_word(possible_words(state)).


% 'play_full' simulates a full game of wordle, with a given secret word. Of course, the algorithm
% will always start with the same first guess. If the given word isn't in the list of allowed words,
% we just return nothing.
 
def play_full_helper_2: (word * word) * (game_state * list(colour)) -> bool * game_state =
  ((secret, guess), (state, guess_colours)) => (
    eq_list{eq_colour}(guess_colours, [green, green, green, green, green]),
    cons((guess, guess_colours), state)
  ).

def play_full_helper_1: (word * word) * game_state -> bool * game_state =
    ((secret, guess), state) => play_full_helper_2(
      (secret, guess), 
      (state, evaluate_guess(secret, guess))
    ).

def play_full: word -> SF(list(word * list(colour))) =   % There's a little subterfuge in here... ;-)

  secret => {  
      true => ss reverse(
        p1 {|
            nil: () => (false, [])
          | cons: (_, (finished, state)) | finished => (true, state)
                                         | .. => play_full_helper_1((secret, play_turn(state)), state)
        |} allowed_words
      )
    | false => ff
  } list_membership{eq_string}(secret, allowed_words).

