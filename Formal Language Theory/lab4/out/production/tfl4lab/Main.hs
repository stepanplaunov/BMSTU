{-# LANGUAGE FlexibleContexts #-}

module Main where

import Text.Printf
import System.IO
import Data.Maybe (Maybe)
import qualified Data.Maybe as Mb
import Control.Monad
import Data.List.Split
import Data.Map (Map, insert)
import qualified Data.Map as Map
import Data.Char (ord, intToDigit)
import Data.List (foldl, intercalate, nub)
import Data.Text (drop)
import qualified Data.Text as Text
import Text.Regex.TDFA

emp = Map.empty
ntermreg = "\\[[A-Za-z]+\\]"
termreg = ntermreg ++ "|[a-z]|[0-9]|\\_|\\*|\\+|\\=|\\(|\\)|\\$|\\;|\\:|!!"
rulereg = ntermreg ++ "::=("   ++ termreg ++ ")+"

printer [] = do return ()
printer (x:xs) = do
                   print x
                   printer xs

concatlines content =
 let
  fil = filter (`notElem` " \n\r")
  in
   filter (not . null) $ map fil $ lines content

notN x = not $ null x

(!~) :: String -> String -> [String]
(!~) str reg = getAllTextMatches (str =~ reg :: AllTextMatches [] String)

linesToGrammar lines = map (map translate . lineToRule) lines
 where lineToRule line
        | line =~ rulereg :: Bool = [head split] ++ last split !~ termreg
        | otherwise = []
        where
          split = splitOn "::=" line
       translate x
        | x == "!!" = ""
        | otherwise = x

--substitute rules subrules = 0
--  where
--    subNTerm = head $ head subrules

giveQuote x = reverse ("]'"++ (tail $ reverse x))
checkT x = x =~ "\\[(.)+\\]" :: Bool
filterDiv checker list = [filter checker list, filter (not . checker) list]
deleteNullRules rules = isFirstConst "[[A_D]_B_C]"
 where
   nullNTerms = foldl (\acum x -> insert x "" acum)emp $ map (head) $ filter checkNullRule rules
   withoutRightNull = filter (not . checkNullRule) rules
   checkNull x = Map.member x nullNTerms
   checkNullRule = (\x -> x !! 1 == "")
   dln = deleteLeftNull withoutRightNull
   deleteLeftNull grammar = translateTerms ++ newrules ++ quoteRules
    where
      [checked, translateTerms] = filterDiv (checkNull . (!!1)) rules
      checkNull x = Map.member x nullNTerms
      newrules = foldl (++) [] $ map translateNullable checked
      quoteRules = foldl (++) [] $ map (copyWithoutNull $ translateTerms ++ newrules) $ nub $ map (!!1) $ checked
      translateNullable rule = [[left, giveQuote $ rule !! 1] ++ tailRule, [left]++tailRule]
       where tailRule
              | length rule > 2 = tail $ tail rule
              | otherwise = []
             left = head rule
      copyWithoutNull grules var = map (\x -> [giveQuote $head x] ++ tail x) $
                                   filter (not . checkNullRule) $
                                   filter ((==var) . (!!0)) grules
   isFirstConst t = not $ first =~ "[A-Z]+" :: Bool
    where
      first = tail $ head $ splitOn "_" t
      
   addRightContext grammar = firstRules
    where
      firstConstRules = map firstNotNullableRules nT
      firstNames = nub $ foldl (\acum x -> acum ++ fst x) [] firstConstRules
      firstRules = foldl (\acum x -> acum ++ snd x) [] firstConstRules
      nT = nub newT
      (newT, newrules) = foldl (\(acumT, acumRules) (_, x, y) -> (acumT ++ x, acumRules ++ [y])) ([], []) rulesWC
      rulesWC = map (\y -> (translate . (foldl selectRightContext ([],[],[head y]))) $ tail y) grammar
      
      firstNotNullableRules t = (namesT, rulesT)
       where
         namesT = concat $ nub $ map fst c
         rulesT = map snd c
         c = map renameRule $ filter ((==startT) . (!!0)) newrules
         startT = (splited !! 0) ++ "]"
         splited = (splitOn "_" t)
         renameRule x
          | not $ checkT $ last x = (nameC, [t] ++ tai ++ nameC)
          | otherwise = (nameN,[t] ++ tai ++ nameN)
          where
           tai
            | length x > 2 = (tail $ rev x)
            | otherwise = []
           nameN = [renT $ last x]
           nameC = ["[" ++ (intercalate "_" $ [last x]++ (tail splited))]
           rev y = (reverse $ tail $ reverse y)
           renT :: String -> String
           renT y = "[" ++ (intercalate "_" $ ([tail $ rev y] ++ (tail splited)))
      selectRightContext (lastString, acum, acumRule) x = (newString, newAcum, newRule ++ newRule3)
       where
         newString
          | not (x =~ "\\[(.)+\\]" :: Bool) = []
          | (not $ checkNull x) = [x]
          | length lastString == 0 = []
          | otherwise = lastString ++ [x]
         newRule3
          | not (x =~ "\\[(.)+\\]" :: Bool) = [x]
          | otherwise = []
         newRule
          | length lastString == 1 && ((not $ checkNull x) || (not (x =~ "\\[(.)+\\]" :: Bool))) = acumRule ++ lastString
          | length lastString > 1 && (not (x =~ "\\[(.)+\\]" :: Bool) || not (checkNull x)) = acumRule ++ [rename lastString]
          | otherwise = acumRule

         newAcum
          | length lastString > 1 && (not (x =~ "\\[(.)+\\]" :: Bool) || not (checkNull x)) = acum ++ [rename lastString]
          | otherwise = acum
      rename str = intercalate "_" $ splitOn "][" $ concat str
      translate (lastString, acum, acumRule)
       | length lastString > 1 = (lastString, acum ++ [rename lastString], acumRule ++ [rename lastString])
       | otherwise = (lastString, acum, acumRule ++ lastString)
main :: IO ()
main = do
         content <- readFile "test/test4.txt"
         let input = concatlines content
             n = last $ splitOn "=" $ head input
             check = any null grammar
             grammar = linesToGrammar $ tail input

         if check
         then print $ id "Syntax error"
         else do
              print $ deleteNullRules grammar

