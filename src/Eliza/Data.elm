module Eliza.Data exposing (..)

import Dict exposing (Dict)
import Regex exposing (Regex, regex)


reflections =
    Dict.fromList
        [ ( "i", "you" )
        , ( "am", "are" )
        , ( "was", "were" )
        , ( "i'd", "you would" )
        , ( "i've", "you have" )
        , ( "i'll", "you will" )
        , ( "my", "your" )
        , ( "are", "am" )
        , ( "you've", "I have" )
        , ( "you'll", "I will" )
        , ( "your", "my" )
        , ( "yours", "mine" )
        , ( "you", "me" )
        , ( "me", "you" )
        ]


responses =
    [ ( regex "i need (.*)"
      , [ "Why do you need {0}?"
        , "Would it really help you to get {0}?"
        , "Are you sure you need {0}?"
        , "What problem does getting {0} solve?"
        ]
      )
    , ( regex "why don\\'?t you ([^\\?]*)\\??"
      , [ "Do you really think I don't {0}?"
        , "Perhaps eventually I will {0}."
        , "Do you really want me to {0}?"
        ]
      )
    , ( regex "why can\\'?t i ([^\\?]*)\\??"
      , [ "Do you think you should be able to {0}?"
        , "If you could {0}, what would you do?"
        , "I don't know -- why can't you {0}?"
        ]
      )
    , ( regex "i can\\'?t ([^\\?]*)"
      , [ "How do you know you can't {0}?"
        , "What are the different ways that you could {0}?"
        , "What would it take for you to {0}?"
        ]
      )
    , ( regex "i( a|')m (.*)"
      , [ "How long have you been {1}?"
        , "What were you doing before you were {1}?"
        , "Why do you tell me you're {1}?"
        , "Why do you think you're {1}?"
        , "What would happen if you weren't {1}?"
        , "Do you know anyone else who has been {1}?"
        ]
      )
    , ( regex "are you ([^\\?]*)\\??"
      , [ "Why does it matter whether I am {0}?"
        , "Would you prefer it if I were not {0}?"
        , "Perhaps you believe I am {0}."
        , "I may be {0} -- what do you think?"
        ]
      )
    , ( regex "what (.*)"
      , [ "Why do you ask?"
        , "How would an answer to that help you?"
        , "What do you think?"
        ]
      )
    , ( regex "how (.*)"
      , [ "How do you suppose?"
        , "Perhaps you can answer your own question."
        , "What is it you're really asking?"
        , "What does the documentation say?"
        ]
      )
    , ( regex "because (.*)"
      , [ "What other reasons come to mind?"
        , "What other reasons could also be true?"
        , "Does that reason apply to anything else?"
        , "If {0}, what else must be true?"
        ]
      )
    , ( regex "(.*) sorry (.*)"
      , [ "There are many times when no apology is needed."
        , "An apology is not necessary"
        ]
      )
    , ( regex "hello(.*)"
      , [ "Hello... I'm glad you could drop by today."
        , "Hi there... how are you today?"
        , "Hello, what can I help you with?"
        ]
      )
    , ( regex "i think (.*)"
      , [ "Do you doubt {0}?"
        , "Do you really think so?"
        , "But you're not sure {0}?"
        , "What other options could be true?"
        ]
      )
    , ( regex "yes"
      , [ "You seem quite sure."
        , "Ok, but can you elaborate a bit?"
        , "Yes, definitely? Or yes, probably?"
        ]
      )
    , ( regex "(.*) computer(.*)"
      , [ "Are you really talking about me?"
        , "Does it seem strange to talk to a computer?"
        , "Do you feel threatened by computers?"
        , "To solve a computer problem, perhaps you have to *think* like a computer..."
        ]
      )
    , ( regex "is it (.*)"
      , [ "Do you think it is {0}?"
        , "Perhaps it's {0} -- what do you think?"
        , "If it were {0}, what would you do?"
        , "If it were not {0}, what would you do?"
        , "It could well be that {0}."
        , "Perhaps -- what would it be if not {0}"
        ]
      )
    , ( regex "it is (.*)"
      , [ "You seem very certain."
        , "If I told you that it probably isn't {0}, what would you think?"
        ]
      )
    , ( regex "can you ([^\\?]*)\\??"
      , [ "What makes you think I can't {0}?"
        , "If I could {0}, then what?"
        , "Why do you ask if I can {0}?"
        ]
      )
    , ( regex "can I ([^\\?]*)\\??"
      , [ "Perhaps you don't want to {0}."
        , "Do you want to be able to {0}?"
        , "If you could {0}, would you?"
        , "What would being able to {0} help you solve?"
        ]
      )
    , ( regex "you are (.*)"
      , [ "Why do you think I am {0}?"
        , "Does it please you to think that I'm {0}?"
        , "Perhaps you would like me to be {0}."
        , "Perhaps you're really talking about yourself?"
        ]
      )
    , ( regex "you\\'?re (.*)"
      , [ "Why do you say I am {0}?"
        , "Why do you think I am {0}?"
        , "Are we talking about you, or me?"
        ]
      )
    , ( regex "i don\\'?t (.*)"
      , [ "Don't you really {0}?"
        , "Why don't you {0}?"
        , "Do you want to {0}?"
        , "Do you know anyone who would {0}?"
        ]
      )
    , ( regex "i have (.*)"
      , [ "How did you find out that you have {0}?"
        , "When did you find out that you've {0}?"
        , "Have you really {0}?"
        , "Now that you have {0}, what will you do next?"
        , "What does having {0} cause you to do now?"
        , "What are the knock-on effects of having {0}?"
        ]
      )
    , ( regex "i would (.*)"
      , [ "Could you explain why you would {0}?"
        , "Why would you {0}?"
        , "Who else knows that you would {0}?"
        , "If you did {0}, what would you do next?"
        ]
      )
    , ( regex "is there (.*)"
      , [ "Do you think there is {0}?"
        , "It's likely that there is {0}."
        , "Would you like there to be {0}?"
        , "Is there documentation for {0}?"
        ]
      )
    , ( regex "my (.*)"
      , [ "I see, your {0}."
        , "Why do you say that your {0}?"
        , "Does that cause any problems?"
        ]
      )
    , ( regex "you (.*)"
      , [ "We should be discussing you, not me."
        , "Why do you say that about me?"
        , "Why do you care whether I {0}?"
        ]
      )
    , ( regex "i want (.*)"
      , [ "What would it mean if you got {0}?"
        , "Why do you want {0}?"
        , "What would you do if you got {0}?"
        , "If you got {0}, then what would you do?"
        , "What problems would getting {0} allow you to solve?"
        ]
      )
    , ( regex "(.*)\\?"
      , [ "Why do you ask that?"
        , "Please consider whether you can answer your own question."
        , "Perhaps the answer lies within yourself?"
        , "Why don't you tell me?"
        ]
      )
    , ( regex "(.*)'?undefined'? is not a function ?(.*)"
      , [ "Only God can help you now"
        , "Maybe check the function name?"
        , "Maybe you could try http://elm-lang.org ?"
        ]
      )
    , ( regex "quit|(good|bye)-?bye"
      , [ "Thank you for talking with me."
        , "Good-bye."
        , "I hope that helped!"
        ]
      )
    , ( regex "(.*)"
      , [ "Please tell me more."
        , "Can you elaborate on that?"
        , "Why do you say that {0}?"
        , "I see."
        , "Very interesting."
        , "{0}."
        , "I see. And what does that tell you?"
        , "Is that causing any problems?"
        ]
      )
    ]
