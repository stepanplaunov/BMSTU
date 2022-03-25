module Main where
import Text.Regex.Posix as POS
import Text.RegexPR as EXPR
import Text.Printf
import System.TimeIt
import System.IO
import Data.Maybe (Maybe)
import qualified Data.Maybe as Mb
import Control.Monad
import Data.List.Split
import Data.Map (Map, insert)
import qualified Data.Map as Map
import Data.Char (ord, intToDigit)
import Data.List (foldl, intercalate, nub, permutations)
import Data.Text (drop)
import Graphvis (run)

toString = intercalate " "
emp = Map.empty
checkaz :: Char -> Bool
checkaz x = (ord x) <? (97, 122)
checkAZ :: Char -> Bool
checkAZ x = (ord x) <? (65, 90)
printerln :: [String] -> IO ()
printerln [] = do return ()
printerln (x:xs) = do
                      putStrLn $ id x
                      printerln xs
(<?) :: Ord a => a -> (a,a) -> Bool
(<?) x (min, max) = x >= min && x <= max
notN x = not $ null x

fromMbMap :: Maybe (Map k a) -> Map k a
fromMbMap x = (Mb.fromMaybe Map.empty) x
fromMbStr :: Maybe [Char] -> [Char]
fromMbStr x = (Mb.fromMaybe "") x

lookupMbMap :: Ord k1 => k1 -> Map k1 (Map k2 a) -> Map k2 a
lookupMbMap x mp = fromMbMap $ Map.lookup x mp

lookupMbStr :: Ord k => k -> Map k [Char] -> [Char]
lookupMbStr x mp = fromMbStr $ Map.lookup x mp
lookupMbList x mp = Mb.fromMaybe [] $ Map.lookup x mp
checkCorrect lines
 | length lines <= 1 = "need transition"
 | not $ checkFirst $ lines !! 0 = "<state, bottom> not correct"
 | otherwise = foldl checkTransition "True" $ tail lines
 where
   checkFirst :: String -> Bool
   checkFirst first
    | length reg == 0 = False
    | first /= reg !! 0 = False
    | otherwise = True
    where
     reg = concat $ ggetbrsRegexPR "<[q-u][0-9]?,[A-Z][0-9]?>" first
   checkTransition acum x
    | acum /= "True" = acum
    | length reg == 0 = "transition not correct"
    | x /= reg !! 0 = "transition not correct"
    | otherwise = "True"
    where
     reg = concat $ ggetbrsRegexPR "<[q-u][0-9]?,([a-z]|!!),[A-Z][0-9]?>-><[q-u][0-9]?,([A-Z][0-9]?)*>" x

concatlines content =
 let
  fil = filter (`notElem` " <>\n")
  in
  map fil $ filter (/="") $ lines content

parseTransition str = concat $ map (splitOn ",") $ x
 where
    x = splitOn "-" str

parseDPDA lines = (state, bottom, transitions, states)
  where
    [state, bottom] = splitOn "," (lines !! 0)
    transitions = map parseTransition $ tail lines
    states = nub $ map (!! 0) transitions
    
generateRules (state, bottom, transitions, states) = generateStart ++ generateRules
 where
   generateStart = map (\x -> ("S", [toString [state, bottom, x]])) states
   generateRules = concatMap generateForTransition transitions
   generateForTransition transition
    | null st2 = rulesE
    | otherwise = rulesNotE
    where
      [q1, letter1, st1, q2, st2] = transition
      letter
       | letter1 == "!!" = ""
       | otherwise = letter1
      rulesE = [(toString [q1, st1, q2], [letter])]
      rulesNotE = concatMap rulesForState states
      stack = concat $ ggetbrsRegexPR "[A-Z][0-9]?" st2
      rulesForState x
       | length stack == 1 = [(toString [q1, st1, x], [letter, toString [q2, (!!) stack 0, x]])]
       | otherwise = map rules setPerm
       where
         setPerm = sequence $ (replicate $ length stack - 1) states
         rules perm =
           (toString
                    [q1, st1, x],
                    [letter] ++ map toString (toSeq (
                                                       [q2] ++ perm,
                                                       stack,
                                                       perm ++ [x]
                                                       )
                                                       [])
           )
          where
           toSeq ([], [], []) sequ = sequ
           toSeq (z, i, y) sequ = toSeq (tail z, tail i, tail y) $ sequ ++ [[head z, head i, head y]]

rename rules = setName (Map.fromList [("S", "S"), ("", "")]) rules getNames []
 where
   notterm = filter (/='S') ['A'..'Z']
   digit = " " ++['0'..'9']
   --fil x = (ord $ x !! 0) <? (48, 57) &&
   getNames = map (filter (`notElem` " \n"))
                  (filter (\x ->
                                not ((ord $ x !! 0) <? (48, 57))
                                )
                          $ sequence [notterm, digit]
                          )
   lookupDict (dict, x, names)
          | Map.member x dict = (dict, lookupMbStr x dict, names)
          | otherwise = (insert x (names !! 0) dict, names !! 0, tail names)
   setName dict [] _ newrules = (dict, newrules)
   setName dict ((x, y):xs) names newrules = setName yDict xs yNames $ newrules ++ [(newx, newy)]
    where
      (yDict, newy, yNames) = foldl nameFoldl (xDict, [], xNames) y
      nameFoldl (zDict, acum, zNames) z
       | sizez == 1 && (checkaz $z !! 0) = (zDict, acum++[z], zNames)
       | otherwise = (newD, acum++[newName], newNames)
       where
         sizez = length z

         (newD, newName, newNames) = lookupDict (zDict, z, zNames)
      (xDict, newx, xNames) = setX
      setX = lookupDict (dict, x, names)


printer [] = do return ()
printer (x:xs) = do
                   print x
                   printer xs

checkSym str =  (length str == 1) && (checkaz $ str !! 0)

deleteRules rules states = filter (remCheck z) removeRules
 where
   z = filter (\z -> Map.member z (dfs edgesDfs emp "S")) terms
   check (left, right) =
    (length right == 1) &&
    (checkSym $ right !! 0)
   conststates = map fst $ filter check rules
   edgesList states rule = foldl getEdges emptyedges rule
    where
      emptyedges = Map.fromList $ map (\x -> (x, [])) states
   getEdges acum x
    | not $ check x = Map.adjust (++[rulesstates]) (fst x) acum
    | otherwise = acum
    where
      rulesstates = (filter (\y -> not (null y || (checkSym y)))$ snd x)
   checkConst :: Map String [[String]] -> Map String String -> String -> Bool
   checkConst edg checked state
    | any (==state) conststates = True
    | otherwise = any checkEdge path
    where
      path = lookupMbList state edg
      checkEdge x = not (any (\y -> Map.member y checked)x) &&
                    all (checkConst edg $ insert state "" checked) x
   terms = filter (checkConst (edgesList states rules) emp) states
   removeRules = filter (remCheck terms) rules
   remCheck ter (x, y)
    | all (/=x) ter = False
    | check (x, y) = True
    | otherwise = all (\x -> any (==x) ter) notchecked
    where
      notchecked = filter (/="") $ filter (not . checkSym) y
   edgesDfs = edgesList terms removeRules
   dfs :: Map String [[String]] -> Map String String -> String -> Map String String
   dfs edg checked state
    | check = checked
    | otherwise = foldl checkDfs checkedWithX $ lookupMbList state edg
    where
      checkDfs acum x = foldl (\acu y ->Map.union (dfs edg acu y) acu) acum x
      check = Map.member state checked
      checkedWithX = insert state "" checked

printCFG :: Foldable t => [([Char], t [Char])] -> IO ()
printCFG [] = do return ()
printCFG ((x, y):rule) = do
                           putStrLn $ id $ x ++" -> "++ (concat y)
                           printCFG rule

main :: IO ()
main = do
         content <- readFile "test/test2.txt"

         let input = concatlines content
             stringsToCheck = map (filter (`notElem` " \n")) $ filter (/="") $ lines content
             (state, bottom, transitions, states)=dpdaparsed
             dpdaparsed = parseDPDA input
             rawrules = generateRules dpdaparsed
             ---переименовываем состояния---
             (namesdict, rules) = rename rawrules
             statenames = filter notN $ Map.elems namesdict
             cfg = deleteRules rules statenames
             check = checkCorrect stringsToCheck
         if check /= "True"
         then print $ id check
         else do
                run dpdaparsed
                printCFG cfg