module Transformer where

{- Main Module:      ShapeCreateM.elm      -}
{- File:             Transformer.elm       -}
{- Author:           Levin Noronha         -}
{- Supervisor:       Dr. Christopher Anand -}

{- Use this module to create a transformer widget for the ShapeCreate program.
   Creation of upto four widget is supported by this module. This module uses a 
   Model-View-Update architecture and you will find the following code broken up
   in the following order - Model, Update, View, and Signals.
-}
 
import Graphics.Collage exposing (..)
import Graphics.Element exposing (..)
import Graphics.Input.Field exposing (..)
import Graphics.Input exposing (..)
import Text exposing (fromString, monospace)
import String exposing (toInt)
import Color exposing (..)
import Signal exposing (..)
import Result exposing (Result)

------------------------------------------------------------------------------------------
{--MODEL--}

-- definition of transformer widget's model
type alias State = { -- dimensions of widget
                     width : Int, height : Int
                     -- keeps track of which button on widget have been clicked
                   , chooseMove : Bool, chooseRotate : Bool
                   , chooseScale : Bool, transformer : Bool
                     -- horShift and vertShift keep track of the x and y coordinates of the move transformation.
                     -- degrees keeps track of the degrees of rotation from the rotate transformation.
                     -- scaleFactor keeps track of the value by which the graphics on screen are to be scaled. 
                   , horShift : Float, vertShift : Float, degrees : Float, scaleFactor : Float
                     -- keeps track of which transformation the user has selected, and which textbox they are typing in
                   , currTextbox : String, currTrans : String
                     -- code generated by this widget that is to be output to screen as text
                   , transformCode : String
                   }

-- starting state of widget
init : State 
init =  { width =  133, height = 130
        , chooseMove = False, chooseRotate = False
        , chooseScale = False, transformer = True
        , horShift = 0, vertShift = 0, degrees = 0, scaleFactor = 1
        , currTextbox = "", currTrans = "", transformCode = ""
        }

------------------------------------------------------------------------------------------
{--UPDATE--}

update input m = 
    {- Primary Update function. Recieves input from the user and makes changes to the current model. This model 
    will later be read by view function and the display will be updated.
       input is of type Update, which means it can only be a signal from a button or a user typing in a 
    textbook within the transformer widget.
       m is the current model; models in Elm are represented by a record. The record for this model 
    has 13 fields which contains information about currently selected transformation options and the 
    values for those transformations.
     -}
    case input of
      -- analysis of input
      Button string -> changeState2 string m                                               -- signals from buttons on the transformer widget are read and the model is updated in order to make the corresponding changes to the output text and graphics
      Typing content -> checkValue (String.toFloat (checkBox content.string m)) m          -- signals from textboxes on the transformer widget are read and the model is updated in order to make the corresponding changes to the output text and graphics

checkBox string m = 
    {-Handles case when string inside a textbox is empty by returning the default value, 0.
      Parameter 'string' has piped down to this function from a signal 
      sent out by a textbox on the transformer widget. m is the current unupdated model.-}
    if string == "" then "0" else string                                                

changeState2 string m = 
    {-Determines which button the user clicked on by examining the parameter 'string', which is a token that was piped down 
      to this function from a signal sent out by a button on the transformer widget. m is the current unupdated 
      model. changeState will replace the code and values set by the previously selected transformation and replace
      it with the code and values from the newly selected transformation.-}
    if 
       -- button clicks 
       | string == "move" -> {m | transformCode <- " |> move (" ++ (toString m.horShift) ++ "," ++ (toString m.vertShift) ++ ")", chooseMove <-True, chooseRotate <- False, chooseScale <- False}       
       | string == "rotate" -> {m | transformCode <- " |> rotate (degrees " ++ (toString m.degrees) ++ ")", chooseMove <-False, chooseRotate <- True, chooseScale <- False}                             
       | string == "scale" -> {m | transformCode <- " |> scale " ++ (toString m.scaleFactor),chooseMove <-False, chooseRotate <- False, chooseScale <- True}                                            
       -- textbox clicks
       | string == "horShift" -> {m | currTextbox <- "horShift"}                        -- x-coordinate textbox
       | string == "vertShift" -> {m | currTextbox <- "vertShift"}                      -- y-coordinate textbox
       | string == "degrees" -> {m | currTextbox <- "degrees"}                          -- degrees of rotation textbox
       | string == "scaleFactor" -> {m | currTextbox <- "scaleFactor"}                  -- textbox for the scale factor
       | otherwise -> m                                                                 -- this branch will never be reached because 'string' can only have 7 possible values, each of which of have been checked in the conditional branches above

checkValue result m =
    {-Anaylses 'result', which is the output of the String.toFloat function, and updates model m only if String.toFloat 
    returned a valid result.-}
    case result of
      Ok value -> updateValue value m                         -- if String.toFloat was able to successfully convert a string into a float, result will be of type Ok Float, where value is of type Float and will be used to update the model m
      _ -> m                                                  -- if String.toFloat was unsuccessful in converting a string into a float, model m remains unchanged

updateValue value m = 
    {- Updates text in the view based on what is currently being typed into a textbox. This is achieved by modifying
     fields in model m using 'value'. The fields that are to be updated are determined based on the value of m.currTextbox, 
     which was set when the current textbox was selected.
    -}
    if | m.currTextbox == "horShift" -> {m | horShift <- value, transformCode <- " |> move (" ++ (toString value) ++ "," ++ (toString m.vertShift) ++ ")"}            -- x-coordinate textbox
       | m.currTextbox == "vertShift" -> {m | vertShift <- value, transformCode <- " |> move (" ++ (toString m.horShift) ++ "," ++ (toString value) ++ ")"}           -- y-coordinate textbox
       | m.currTextbox == "degrees" -> {m | degrees <- value, transformCode <- " |> rotate (degrees " ++ (toString value) ++ ")"}                                     -- degrees of rotation textbox
       | m.currTextbox == "scaleFactor" -> {m | scaleFactor <- value, transformCode <- " |> scale " ++ (toString value)}                                              -- textbox for the scale factor
       | otherwise -> m                                                                                                                                               -- this branch will never be reached because 'string' can only have 4 possible values, each of which of have been checked in the conditional branches above

------------------------------------------------------------------------------------------
{--VIEW--}

view m nf9 nf10 nf11 nf12 transSelect =
        {-Primary view function that creates the container for the transformer widget and makes further function calls to 
        create the sub-components of the widget. Model m contains predefined fields m.width and m.height that set the size
        of the container, which is also the size of the widget. nf9, nf10, nf11, nf12 and transSelect are arguments passed in
        from either the t1Display or t2Display function in the ShapeCreateM module. nf9, nf10, nf11, nf12 are textboxes, while
        transSelect is a string token representing clicked button.-}
        container m.width m.height topLeft (transMenu m.width m.height nf9 nf10 nf11 nf12 m transSelect)

transMenu w h nf9 nf10 nf11 nf12 m transSelect =
        {-Called by view function. Calls function transMenuBackDrop to draw widget's background and also calls transButtons 
        functions to create the buttons for each transformations as well as their corresponding textboxes.
        -}
        let 
            collageWidth = 133          -- width of widget
            buttonWidth = 120           -- height of widget
            menuWidth = 130             -- width of an individual button
        in
        -- 
        flow outward
            [ transMenuBackDrop collageWidth menuWidth                                             -- draws widget
            , container collageWidth 130 (midTopAt (absolute (collageWidth//2)) (absolute 25))     -- draws buttons
                <| (transButtons buttonWidth nf9 nf10 nf11 nf12 m transSelect)
            ]
        --}
        
transMenuBackDrop collageWidth menuWidth = 
        {-Called by transMenu funtion to draw the widget background.-}
        collage collageWidth 130
            [ -- border
              outlined (solid black) (rect menuWidth 100) 
            , outlined (solid black) (oval menuWidth 20) |> move (0,50)
            , outlined (solid black) (oval menuWidth 20) |> move (0,-50)
            -- background colour
            , filled white (rect menuWidth 100)
            , filled white (oval menuWidth 20) |> move (0,50)
            , filled white (oval menuWidth 20) |> move (0,-50)
            -- instruction
            , text (Text.color black (fromString "PICK ONE")) |> move (0,50)
            ]

transButtons buttonWidth nf9 nf10 nf11 nf12 m transSelect =
        {-Called by transMenu funtion to draw the three transformation buttons on the widget. This function makes 3 
        further function calls to moveButton, rotateButton, and scaleButton to draw the three buttons. nf9, nf10, nf11, 
        and nf12 are textboxes. transSelect is a string token representing a button that was clicked.-}
        flow down 
            [ -- draw button
              moveButton buttonWidth nf9 nf10 m transSelect
              -- determine which transformer this button belongs to and send a signal to the corresponding mailbox 
                |> (if | transSelect == "transformer 1" -> clickable (Signal.message buttonMailbox.address "move")
                       | transSelect == "transformer 2" -> clickable (Signal.message buttonMailbox2.address "move")
                       | transSelect == "transformer 3" -> clickable (Signal.message buttonMailbox3.address "move")  
                       | otherwise -> clickable (Signal.message buttonMailbox4.address "move")
                   )       
            , -- draw button
              rotateButton buttonWidth nf11 m transSelect
              -- determine which transformer this button belongs to and send a signal to the corresponding mailbox 
                |> (if | transSelect == "transformer 1" -> clickable (Signal.message buttonMailbox.address "rotate")
                       | transSelect == "transformer 2" -> clickable (Signal.message buttonMailbox2.address "rotate")
                       | transSelect == "transformer 3" -> clickable (Signal.message buttonMailbox3.address "rotate")  
                       | otherwise -> clickable (Signal.message buttonMailbox4.address "rotate")
                   )   
            , -- draw button
              scaleButton buttonWidth nf12 m transSelect
              -- determine which transformer this button belongs to and send a signal to the corresponding mailbox 
                |> (if | transSelect == "transformer 1" -> clickable (Signal.message buttonMailbox.address "scale")
                       | transSelect == "transformer 2" -> clickable (Signal.message buttonMailbox2.address "scale") 
                       | transSelect == "transformer 3" -> clickable (Signal.message buttonMailbox3.address "scale")  
                       | otherwise -> clickable (Signal.message buttonMailbox4.address "scale")
                   )   
            ]
              
moveButton buttonWidth nf9 nf10 m transSelect =
        {-Called by transButton function to draw the button that enables the move transformation. The four if statements
        checks if move has been selected via m.chooseMove and if it has been selected it draws the textboxes in front of
        a faded grey screen to make them clickable. Otherwise, they are draw behind the transparent grey screen and are unclickable.
        nf9 and nf10 are textboxes for x and y respectively, m is the current model, and transSelect is a String that
        holds information about which transformation has been selected. -}
        collage 150 30
            [ text <| Text.color black <| fromString "move (\t\t\t\t\t\t\t\t\t\t,\t\t\t\t\t\t\t\t\t\t)" -- button description
            , if m.chooseMove then emptyForm else moveXtextbox nf9 m transSelect                        
            , if m.chooseMove then emptyForm else moveYtextbox nf10 m transSelect                       
            , toForm (transButOutline buttonWidth m.chooseMove)   -- button border
            , if m.chooseMove then moveXtextbox nf9 m transSelect else emptyForm
            , if m.chooseMove then moveYtextbox nf10 m transSelect else emptyForm
            ]

moveXtextbox nf9 m transSelect = 
    {-Draws textbox that takes in value of the x-coordinate for the move transformation. This function gets called from
    inside the moveButton function. nf9 is a textbox, m is the current model, and transSelect is a String token that contains
    information about which transformation is currently selected in the widget.-}
    size 28 18 nf9 |> (if | transSelect == "transformer 1" -> clickable (Signal.message buttonMailbox.address "horShift")
                          | transSelect == "transformer 2" -> clickable (Signal.message buttonMailbox2.address "horShift")
                          | transSelect == "transformer 3" -> clickable (Signal.message buttonMailbox3.address "horShift")
                          | otherwise -> clickable (Signal.message buttonMailbox4.address "horShift")
                      )
                   |> toForm
                   |> move (0,0)
                   
moveYtextbox nf10 m transSelect = 
    {-Draws textbox that takes in value of the y-coordinate for the move transformation. This function gets called from
    inside the moveButton function. nf10 is a textbox, m is the current model, and transSelect is a String token that contains
    information about which transformation is currently selected in the widget.-}
    size 28 18 nf10
                   |> (if | transSelect == "transformer 1" -> clickable (Signal.message buttonMailbox.address "vertShift")
                          | transSelect == "transformer 2" -> clickable (Signal.message buttonMailbox2.address "vertShift")
                          | transSelect == "transformer 3" -> clickable (Signal.message buttonMailbox3.address "vertShift")
                          | otherwise -> clickable (Signal.message buttonMailbox4.address "vertShift")
                      )
                   |> toForm
                   |> move (33,0)
            
rotateButton buttonWidth nf11 m transSelect =
        {-Draws the button that enables the move transformation. Called from inside the transButton function. The two if statements
        check m.chooseRotate to verify if rotate is currently selected and if it has been selected, it draws the textbox in front of
        emptyForm, a transparent grey screen, to make them clickable. Otherwise, the textbox is draw behind the faded-grey screen and 
        is unclickable. n11 is a textbox, m is the current model, and transSelect is a String token that holds information about which 
        transformation has been selected.-}
        collage 150 30
            [ text <| Text.color black <| fromString "rotate (degrees \t\t\t\t\t\t\t\t)"        -- description of button
            , if m.chooseRotate then emptyForm else degreeTextbox nf11 m transSelect
            , toForm (transButOutline buttonWidth m.chooseRotate)                               -- draw border for button
            , if m.chooseRotate then degreeTextbox nf11 m transSelect else emptyForm
            ]

degreeTextbox nf11 m transSelect = 
        {-Draws textbox that takes in value of the degree for the rotate transformation. This function gets called from
        inside the rotateButton function. nf10 is a textbox, m is the current model, and transSelect is a String token that contains
        information about which transformation is currently selected in the widget.-}
                  size 25 18 nf11 
                        |> (if | transSelect == "transformer 1" -> clickable (Signal.message buttonMailbox.address "degrees")
                               | transSelect == "transformer 2" -> clickable (Signal.message buttonMailbox2.address "degrees")
                               | transSelect == "transformer 3" -> clickable (Signal.message buttonMailbox3.address "degrees")
                               | otherwise -> clickable (Signal.message buttonMailbox4.address "degrees")
                           )
                        |> toForm 
                        |> move (40,0)

scaleButton buttonWidth nf12 m transSelect =
        {-Draws the button that enables the scale transformation. Called from inside the transButton function. The two if statements
        check m.chooseRotate to verify if rotate is currently selected and if it has been selected, it draws the textboxes in front of
        emptyForm, a transparent grey screen, to make them clickable. Otherwise, they are draw behind the faded-grey screen and are unclickable.
        n11 is a textbox, m is the current model, and transSelect is a String token that holds information about which transformation 
        has been selected.-}
        collage 150 30
            [ (text <| Text.color black <| fromString "scale")  |> move (-10,0)         -- draw description on button
            , if m.chooseScale then emptyForm else scaleTextbox nf12 m transSelect
            , toForm (transButOutline buttonWidth m.chooseScale)                        -- draw border on button
            , if m.chooseScale then scaleTextbox nf12 m transSelect else emptyForm
            ]

scaleTextbox nf12 m transSelect = 
      {-Draws textbox that takes in the scale factor value for the scale transformation. This function gets called from
        inside the scaleButton function. nf10 is a textbox, m is the current model, and transSelect is a String token that contains
        information about which transformation is currently selected in the widget.-}
      size 22 18 nf12 |> (if | transSelect == "transformer 1" -> clickable (Signal.message buttonMailbox.address "scaleFactor")
                             | transSelect == "transformer 2" -> clickable (Signal.message buttonMailbox2.address "scaleFactor")
                             | transSelect == "transformer 3" -> clickable (Signal.message buttonMailbox3.address "scaleFactor")
                             | otherwise -> clickable (Signal.message buttonMailbox4.address "scaleFactor")
                         )
                      |> toForm
                      |> move (20,0)

transButOutline buttonWidth select =
      {-Draw border for each of the three transformation buttons inside the widget. transButOutline is called from moveButton,
      scaleButton, rotateButton. select is a Bool that represent whether a button is selected.-} 
      if | select == True -> collage 175 40 [outlined (solid black) <| rect buttonWidth 25]        -- paint border 
         | otherwise -> collage 175 40 [filled (hsla (degrees 0) 0 1 0.5) <| rect buttonWidth 25]  -- Draws nothing. the colour 'hsla (degrees 0) 0 1 0.5' is fully transparent. Therefore no border

emptyForm = filled white (circle 0) -- Draws nothing. this constant handles the base case where nothing needs to be drawn. 

-----------------------------------------------------------------------------------------------------------------------------

{-TEXT FIELDS AND MAILBOXES-}
{-The following section allows for the capability to support four transformer widget. However, our program will only use two of these. -}


{- TRANSFORMER 1 -}

-- The following are textboxes(or text fields) for x, y, degrees, and scale factor. Each sends a signal to a particular mailbox
nf9 : Signal Element
nf9 = (field {textBoxStyle | style <- {textStyle | height <- Just 11}} (Signal.message name9.address) "x" <~ name9.signal)
nf10 : Signal Element
nf10 = (field textBoxStyle (Signal.message name10.address) "y" <~ name10.signal)
nf11 : Signal Element
nf11 = (field textBoxStyle (Signal.message name11.address) "" <~ name11.signal)
nf12 : Signal Element
nf12 = (field textBoxStyle (Signal.message name12.address) "" <~ name12.signal)

-- The following Mailboxes correspond to each of the above textboxes. 
-- Numberings in the mailbox names match the numberings of the textboxes.
name9 : Signal.Mailbox Content
name9 = Signal.mailbox (Content (toString -195) (Selection 0 0 Forward))

name10 : Signal.Mailbox Content
name10 = Signal.mailbox (Content (toString 65) (Selection 0 0 Forward))

name11 : Signal.Mailbox Content
name11 = Signal.mailbox (Content (toString 0) (Selection 0 0 Forward))

name12 : Signal.Mailbox Content
name12 = Signal.mailbox (Content (toString 1) (Selection 0 0 Forward))

-- Mailbox for all buttons in a transformer widget.
buttonMailbox : Signal.Mailbox String
buttonMailbox = Signal.mailbox "filled"

-- Combines signals from the mailboxes of each textbox in this widget and broadcasts it as one signal.
textboxMailbox  = Signal.mergeMany [ name9.signal
                                   , name10.signal
                                   , name11.signal
                                   , name12.signal
                                   ]


{- TRANSFORMER 2 -}

-- The following are textboxes(or text fields) for x, y, degrees, and scale factor. Each sends a signal to a particular mailbox
nf13 : Signal Element
nf13 = (field {textBoxStyle | style <- {textStyle | height <- Just 11}} (Signal.message name13.address) "x" <~ name13.signal)
nf14 : Signal Element
nf14 = (field textBoxStyle (Signal.message name14.address) "y" <~ name14.signal)
nf15 : Signal Element
nf15 = (field textBoxStyle (Signal.message name15.address) "" <~ name15.signal)
nf16 : Signal Element
nf16 = (field textBoxStyle (Signal.message name16.address) "" <~ name16.signal)

-- The following Mailboxes correspond to each of the above textboxes. 
-- Numberings in the mailbox names match the numberings of the textboxes.
name13 : Signal.Mailbox Content
name13 = Signal.mailbox (Content (toString 0) (Selection 0 0 Forward))

name14 : Signal.Mailbox Content
name14 = Signal.mailbox (Content (toString 0) (Selection 0 0 Forward))

name15 : Signal.Mailbox Content
name15 = Signal.mailbox (Content (toString 45) (Selection 0 0 Forward))

name16 : Signal.Mailbox Content
name16 = Signal.mailbox (Content (toString 2) (Selection 0 0 Forward))

-- Combines signals from the mailboxes of each textbox in this widget and broadcasts it as one signal.
textboxMailbox2  = Signal.mergeMany [ name13.signal
                                   , name14.signal
                                   , name15.signal
                                   , name16.signal
                                   ]                                   

-- Mailbox for all buttons in a transformer widget.
buttonMailbox2 : Signal.Mailbox String
buttonMailbox2 = Signal.mailbox "filled"


{- TRANSFORMER 3 -}

-- The following are textboxes(or text fields) for x, y, degrees, and scale factor. Each sends a signal to a particular mailbox
nf17 : Signal Element
nf17 = (field {textBoxStyle | style <- {textStyle | height <- Just 11}} (Signal.message name17.address) "x" <~ name17.signal)
nf18 : Signal Element
nf18 = (field textBoxStyle (Signal.message name18.address) "y" <~ name18.signal)
nf19 : Signal Element
nf19 = (field textBoxStyle (Signal.message name19.address) "" <~ name19.signal)
nf20 : Signal Element
nf20 = (field textBoxStyle (Signal.message name20.address) "" <~ name20.signal)

-- The following Mailboxes correspond to each of the above textboxes. 
-- Numberings in the mailbox names match the numberings of the textboxes.
name17 : Signal.Mailbox Content
name17 = Signal.mailbox (Content (toString 0) (Selection 0 0 Forward))

name18 : Signal.Mailbox Content
name18 = Signal.mailbox (Content (toString 0) (Selection 0 0 Forward))

name19 : Signal.Mailbox Content
name19 = Signal.mailbox (Content (toString 0) (Selection 0 0 Forward))

name20 : Signal.Mailbox Content
name20 = Signal.mailbox (Content (toString 0) (Selection 0 0 Forward))

-- Combines signals from the mailboxes of each textbox in this widget and broadcasts it as one signal.
textboxMailbox3 = Signal.mergeMany [ name17.signal
                                   , name18.signal
                                   , name19.signal
                                   , name20.signal
                                   ]                                   

-- Mailbox for all buttons in a transformer widget.
buttonMailbox3 : Signal.Mailbox String
buttonMailbox3 = Signal.mailbox "filled"


{- TRANSFORMER 4 -}

-- The following are textboxes(or text fields) for x, y, degrees, and scale factor. Each sends a signal to a particular mailbox
nf21 : Signal Element
nf21 = (field {textBoxStyle | style <- {textStyle | height <- Just 11}} (Signal.message name21.address) "x" <~ name21.signal)
nf22 : Signal Element
nf22 = (field textBoxStyle (Signal.message name22.address) "y" <~ name22.signal)
nf23 : Signal Element
nf23 = (field textBoxStyle (Signal.message name23.address) "" <~ name23.signal)
nf24 : Signal Element
nf24 = (field textBoxStyle (Signal.message name24.address) "" <~ name24.signal)

-- The following Mailboxes correspond to each of the above textboxes. 
-- Numberings in the mailbox names match the numberings of the textboxes.
name21 : Signal.Mailbox Content
name21 = Signal.mailbox (Content (toString 0) (Selection 0 0 Forward))

name22 : Signal.Mailbox Content
name22 = Signal.mailbox (Content (toString 0) (Selection 0 0 Forward))

name23 : Signal.Mailbox Content
name23 = Signal.mailbox (Content (toString 0) (Selection 0 0 Forward))

name24 : Signal.Mailbox Content
name24 = Signal.mailbox (Content (toString 0) (Selection 0 0 Forward))

-- Combines signals from the mailboxes of each textbox in this widget and broadcasts it as one signal.
textboxMailbox4 = Signal.mergeMany [ name21.signal
                                   , name22.signal
                                   , name23.signal
                                   , name24.signal
                                   ]                                   

-- Mailbox for all buttons in a transformer widget.
buttonMailbox4 : Signal.Mailbox String
buttonMailbox4 = Signal.mailbox "filled"

{-ATTRIBUTES OF TEXTBOX-}
textBoxStyle : Style
textBoxStyle = 
        { padding = (uniformly 1)
        , outline = { color = grey, width = uniformly 1, radius = 0 }
        , highlight = { color = blue, width = 1 }
        , style = textStyle
        }

{-ATTRIBUTES OF TEXT INSIDE TEXTBOX-}        
textStyle = 
        { typeface = []
        , height = Just 11
        , color = black
        , bold = False
        , italic = False
        , line = Nothing
        }                                   

{-Different Types of User Events - There are two ways the user can interact with the widget - through clicking buttons in the
view, or through typing in textboxes.-}
type Update = Button String | Typing Content

-- The following 4 functions combine the textbox signals and button signals for each transformer in to one signal.
-- These combined signals are used in the ShapeCreateM module to track updates for each transformer widget.
-- Having one combined signal helps makes the update function more concise and simple.
combinedInput : Signal Update
combinedInput = Signal.mergeMany [ (Signal.map Button buttonMailbox.signal)
                                 , (Signal.map Typing textboxMailbox)
                                 ]

combinedInput2 : Signal Update
combinedInput2 = Signal.mergeMany [ (Signal.map Button buttonMailbox2.signal)
                                  , (Signal.map Typing textboxMailbox2)
                                  ]

combinedInput3 : Signal Update
combinedInput3 = Signal.mergeMany [ (Signal.map Button buttonMailbox3.signal)
                                  , (Signal.map Typing textboxMailbox3)
                                  ]

combinedInput4 : Signal Update
combinedInput4 = Signal.mergeMany [ (Signal.map Button buttonMailbox4.signal)
                                  , (Signal.map Typing textboxMailbox4)
                                  ]
