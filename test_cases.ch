

% Test cases for the evaluate_guess function. Some unashamedly borrowed from here: 
% https://stackoverflow.com/questions/71324956/wordle-implementation-dealing-with-duplicate-letters-edge-case

def evaluate_guess_test_1: 1 -> bool =
  () => eq_list{eq_colour}(
    evaluate_guess("event", "peeve"),
    [grey, yellow, green, yellow, grey]
  ).

def evaluate_guess_test_2: 1 -> bool =
  () => eq_list{eq_colour}(
    evaluate_guess("close", "cheer"),
	[green, grey, yellow, grey, grey]
  ).
 
def evaluate_guess_test_3: 1 -> bool =
  () => eq_list{eq_colour}(
    evaluate_guess("close", "cocks"),
    [green, yellow, grey, grey, yellow]
  ).
 
def evaluate_guess_test_4: 1 -> bool =
  () => eq_list{eq_colour}(
    evaluate_guess("close", "leave"),
    [yellow, grey, grey, grey, green]
  ).

