# hubot-meme-generator

A modified version of the hubot script meme generator: https://github.com/github/hubot-scripts/blob/master/src/scripts/meme_generator.coffee.
This package is entirely adapted from the script originally written by [skalnik](https://github.com/skalnik)
and modified to only support a subset of the memes (instead of ALL THE MEMES!!). :penguin:

See [`src/meme-generator.coffee`](src/meme-generator.coffee) for full documentation.

## Installation

In hubot project repo, run:

`npm install hubot-meme-generator --save`

Then add **hubot-meme-generator** to your `external-scripts.json`:

```json
[
  "hubot-meme-generator"
]
```

## Sample Interaction

```
user1>> hubot hello
hubot>> hello!
```
