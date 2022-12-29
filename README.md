# Christmas puzzler 2022: writing a Wordle solver


This repository contains a solution for the [Brandwatch](https://www.brandwatch.com/) holider puzzler for Christmas 2022. The problem is to write a solver for the [Wordle](https://www.nytimes.com/games/wordle/index.html) game. Wordle has been kinda discussed to death, so to make things more interesting, I used the experimental programming language [Charity](https://github.com/mietek/charity-lang). I'd been curious about that language for years, so I took the chance to try it out.


### What's interesting about the Charity language?


Charity is a functional language "completely grounded in category theory" (which sounds exciting already :D). But what made me curious about the language is that it's designed to be _Turing-incomplete but useful in practice_.

The lack of [Turing-completeness](https://en.wikipedia.org/wiki/Turing_completeness) means that there exist algorithms that you cannot implement in Charity. But in practice you can implement a lot of things (including a Wordle solver, happily for present purposes!). This design choice - "in theory you can't do everything, but in practice you can do quite a lot" is
sort of the opposite of the [Turing Tarpit](https://en.wikipedia.org/wiki/Turing_tarpit) languages, which can be summarised as "in theory you can do everything, but in practice you can do very little".


### All Charity programs terminate

Charity is designed so that _all programs terminate_; it simply _isn't possible_ to accidentally write a program that loops forever. Cool!? This property comes about because the use of recursion is restricted: you can only write recursions in the form of [catamorphisms](https://en.wikipedia.org/wiki/Catamorphism) which
"provide generalizations of folds of lists to arbitrary algebraic data types". If you've written list and tree folds in a language like Haskell, these will feel pretty natural.

### How to run the code

Get one of the Charity interpreters from [this site](https://github.com/mietek/charity-lang). I used [this Windows binary](https://github.com/mietek/charity-lang/blob/master/bin/2000-10-12-charity-bin-windows-i386.zip). Start the interpreter and then load in the solver program with the command

```readfile "wordle.ch".```

Once the code is loaded, you can run the wordle solver by invoking the `play_full` function. The heuristic I used seems to produce at least vaguely sensible guesses. For example, `play_full("holes").` produces the game:

```
[
  ("rates", [grey,   grey,  grey,  green, green]),
  ("lines", [yellow, grey,  grey,  green, green]),
  ("holes", [green,  green, green, green, green])
]
```

Running `play_full("intro").` produces:

```
[
  ("rates", [yellow, grey,   green, grey,  grey]),
  ("vitro", [grey,   yellow, green, green, green]),
  ("intro", [green,  green,  green, green, green])
]
```

Running `play_full("unity").` produces:

```
[
  ("rates", [grey,   grey,   yellow, grey,  grey]),
  ("tough", [yellow, grey,   yellow, grey,  grey]),
  ("quilt", [grey,   yellow, green,  grey,  yellow]),
  ("unity", [green,  green,  green,  green, green])
]
```


### Limitations

* **Smaller word list.** The [full Wordle word list](https://gist.github.com/dracos/dd0668f281e685bad51479e5acaadb93) has 12,972 words in, which is too many for the Charity interpreter to handle. The programming language appears to have no file I/O facilities, so you have to declare the dictionary as a literal list in source code. Trying to do that with the full word list leads to `*** ERROR: emit: Out of compiling memory`. I found that about 1,250 words is the maximum I could use, so I created my own smaller word list consisting of the highest-frequency 1,250 words (according to [this](https://www.kaggle.com/datasets/rtatman/english-word-frequency) frequency table) which you can find in `common_word_list.ch`.
 

- The solver itself uses a pretty simple heuristic, which you can read in the code; it isn't an optimal solver. The programming language seems not to include any floating point features, making it not so easy to do the kind of information-theoretic calculations shown for example [here](https://www.3blue1brown.com/lessons/wordle).


### Miscellaneous observations

In general, programming in Charity is perfectly pleasant once you figure out what's going on. However:

- Research on Charity seems to have stopped years ago, the documentation is incomplete and building the interpreter from source isn't straightforward. Which either adds to the fun or subtracts from it, depending on your viewpoint.

- Some subterfuge was needed in the definition of the `play_full` function. It's kind of the same trick as explained [here](http s://en.wikipedia.org/wiki/Total_functional_programming) with the quicksort algorithm.

- While doing this puzzle I learned about the concept of [paramorphisms](https://en.wikipedia.org/wiki/Paramorphism), a form of recursion which "eats its argument and keeps it too". Being able to write these, instead of only catamorphisms, would've been handy when doing the puzzle, but it seems you can't do that.




