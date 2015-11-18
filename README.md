# Piconot in XText

[Picobot]: https://www.cs.hmc.edu/picobot/
[XText]: https://eclipse.org/Xtext/
[Eclipse]: https://www.eclipse.org
[Graphviz]: http://www.graphviz.org/
[Tutorial1]: https://eclipse.org/Xtext/documentation/101_five_minutes.html
[Tutorial2]: https://eclipse.org/Xtext/documentation/102_domainmodelwalkthrough.html
[Tutorial3]: https://eclipse.org/Xtext/documentation/103_domainmodelnextsteps.html
[XTextDownload]: https://eclipse.org/Xtext/download.html

[ExampleFile]: /files/empty.pb
[PicobotGrammar]: /files/Picobot.xtext
[GraphvizGenerator]: /files/PicobotGenerator.xtend
[GraphvizGenerator]: /files/PicobotValidator.xtend

[XTextDocs]: https://eclipse.org/Xtext/documentation/index.html
[XTextExamples]: https://github.com/xtext/seven-languages-xtext

## Overview

This project creates an Integrated Development Environment (IDE) for a 
Domain-Specific Language. The language is based on [Picobot]. The IDE is built
using [XText], a suite of tools for making Eclipse-based IDEs. 

The IDE that we build for Picobot has the following features:

   + syntax highlighting
   + auto-complete
   + code generation, which creates a Finite State Machine diagram that
   corresponds to the Picobot program.
   + validation, which warns programmers of potential problems with their
   program (e.g., unreachable states)

This project essentially follows three XText tutorials ([1][Tutorials1], 
[2][Tutorials2], [3][Tutorials3]), specialized for Picobot.

The rest of this README file contains:

   1. a brief description of the Picobot syntax
   1. a brief description on how to build an initial IDE with syntax-
   highlighting and auto-complete
   1. a brief description on how to add code generation
   1. a brief description on how to add validation

## Picobot

We'll build an IDE for a modified version of [Picobot]. The modified version
uses slightly different syntax to specify a robot's rules: rules are named
(rather than numbered). Here's an example program, which can fill the an empty,
square room:

```
state: starting_west;
state: starting_north;
state: moving_south;
state: moving_north;

rule: starting_west  [* * x *] -> W starting_west;    
rule: starting_west  [x * W *] -> N starting_north;   
rule: starting_north [x * * *] -> N starting_north;  
rule: starting_north [N * * x] -> S moving_south;

rule: moving_south [* * * x] -> S moving_south;
rule: moving_south [* x * S] -> E moving_north;

rule: moving_north [x * * *] -> N moving_north;
rule: moving_north [N x * *] -> E moving_south;

startwith: starting_west;

```

Note that the program begins with a declaration of all the rule names, then come
the rule definitions, and finally the name of the state in which the robot
should start.


## An initial IDE

To get an initial IDE, you'll need to install XText and ANTLR, then define the
Picobot grammar.

### Installing XText and ANTLR
_Note: this step can take awhile; there may be quite a bit to download._

Visit the [XText download][XTextDownload] page and choose whether you'd like to:

   a. install XText into an version of Eclipse that you already have installed
   on your computer _or_
   b. download an entirely new version of Eclipse, with XText already installed

If you choose to use the update sites, I highly recommend that you also **use an
update site to install ANTLR** (as described on the XText download page).
‣
### Creating an initial version of the IDE

_Note: you might want to also refer to the [first XText tutorial][Tutorial1], as
you work on this part.

   1. Launch your version of Eclipse that has XText installed.
   1. Create a new "XText Project"
      1. For the project name, use `edu.hmc.cs.picobot`
      1. For the language name, use `edu.hmc.cs.picobot.Picobot`
      1. For the extension, use `pb`
   1. Eclipse will generate a bunch of projects and files. Then, it should open
   an editor with the file `Picobot.xtext`. This file provides a default grammar
   for our language. In a minute, we'll update it with the full grammar. But 
   first, let's double-check that XText is working on the default grammar.

### Testing the initial version of the IDE

Whenever you modify the code for your IDE, you need to re-generate the IDE (i.e
,. compile your code into a new IDE), then launch it. Here's how to do that for
the first time:

   1. Generate the IDE files for the default grammar by right-clicking in the
   editor and selecting `Run As ‣ Generate XText Artifacts`.
   1. Launch your generated IDE by right-clicking the _project_ 
   (`edu.hmc.cs.picobot` in the explorer pane on the left-hand side of 
   Eclipse) and selecting `Run As ‣ Eclipse Application`
   1. A _new_ instance of Eclipse should open. This is the first version of 
   an IDE for Picobot! (Eclipse might ask you if you want to enable JDT
   Weaving. Click `OK`, which will probably re-launch Eclipse.)
   1. Create a new Java project in the IDE and call it `Demo`
   1. In the `src` directory, create a new file called `empty.pb`. Your IDE
   should ask you if you want to add the "XText nature" to your project. Yes,
   you do.
   1. Fill your file with the contents of [empty.pb][ExampleFile].
   1. Your IDE should tell you that you have a syntax error, because we haven't
   yet defined the Picobot grammar. Quit your generated IDE and return to
   Eclipse (which has your IDE code).

### Defining the Picobot grammar

   1. In the project called `edu.hmc.cs.picobot`, open the file 
   `src/edu.hmc.cs.picobot/Picobot.xtext` (it may already be open)
   1. Replace the contents of this file with the 
   [Picobot grammar][PicobotGrammar].
   1. Re-generate and re-launch your IDE.
   1. Your example Picobot program should now be valid and syntax-highlighted!
   1. Try playing around with the code in the example Picobot program, to
   explore the syntax-highlighting and auto-complete features of your IDE.

## Code generation

We'll now add a code generator. This generate will translate a Picobot `.pb` 
file into a [Graphviz][Graphviz] `.dot` file. The translation happens every time
a user saves a `.pb` file in your IDE. If the user has Graphviz installed on
their computer, they can use it to open the `.dot` file and view a state-machine
diagram of their Picobot program.

To add this feature to your language:

   1. In the project called `edu.hmc.cs.picobot`, open the file 
   `src/edu.hmc.cs.picobot.generator/PicobotGenerator.xtend`
   1. Replace the contents of this file with the [code for generating Graphviz
   files][GraphvizGenerator].
   1. Re-generate and re-launch your IDE.
   1. Modify / save your example file.
   1. In the `Demo` project, there should now be file called 
   `src-gen/empty.dot`. Open it and take a look!

## Validation

We'll now add some code validation. In particular, we'll write a plugin to your
IDE that checks a Picobot program for the following problems:

   1. Any rule that tries to move in a direction that is known to be blocked.
   1. Any rule that is unreachable.

If the validator finds rules with this issue, it will provide a warning to the
programmer.

Here's how to add the validator to your IDE:

   1. In the project called `edu.hmc.cs.picobot`, open the file 
   `src/edu.hmc.cs.picobot.validator/PicobotValidator.xtend`
   1. Replace the contents of this file with the 
   [validation code][PicobotValidator].
   1. Re-generate and re-launch your IDE.
   1. Modify your example file to introduce errors that the validator can find.

## Where to go from here?
You can try repeating these steps for your own DSL! The
[XText documentation][XTextDocs] and some [example languages][XTextExamples]
might be helpful.

