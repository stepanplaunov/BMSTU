{- BEGIN KEY = {0} NAME = {testcomment} DESCRIPTION = {Descriptionexample} -}
commentCoords [] [] result = result
commentCoords [] stack result = []
commentCoords (x:xs) stack result =
 if tupcomments x == 0
 then commentCoords xs (x:stack) result
 else if length stack >= 1
      then commentCoords xs (tail stack) $ (head stack, x):result
      else []
{- END -}