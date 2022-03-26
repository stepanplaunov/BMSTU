{-# LANGUAGE FlexibleContexts #-}
module Main where
import qualified Data.Maybe as Mb
import Data.List.Split
import Data.List.Unique (allUnique)
import qualified Data.Map as Map
import Data.List (intercalate, sortOn, take, drop)
import Text.Regex.TDFA

meta = ["TITLE", "AUTHOR","DEPT","REVIEWER"]

body = ["START_TASK", "END_TASK", "START_BODY", "END_BODY", "START_TESTS", "END_TESTS"]
import_reg = "[\\][\\$]IMPORT[\\][\\{]([A-Za-z0-9]*)[\\][\\}]"
system_reg = "[\\][\\$]SYSTEM[\\][\\_]([A-Za-z0-9]*)"

allTags = meta ++ body

getMetaData :: [String] -> [String] -> [String] -> [String]
getMetaData [] [] result = result
getMetaData (tag:tags) (string:input) result =
 if any (==tag) meta 
 then getMetaData tags input $ [(string =~ "\\{(.)+\\}" :: String) =~ "([^\\{\\}])+" :: String] ++ result
 else filter ((/=0) . length) $ getSectionData body (splitOn " " $ intercalate " " (string:input)) result

getSectionData :: [[Char]] -> [[Char]] -> [[Char]] -> [[Char]]
getSectionData _ [] result = result
getSectionData [] _ _ = []
getSectionData (tag:tags) (w:ws) result =
 if length w == 0
 then getSectionData (tag:tags) ws result
 else if w /= tag
      then getSectionData (tag:tags) ws $ [(result !! 0) ++ " "++ w] ++ tail result
      else getSectionData tags ws $ [""]++ result

latexT tag attr = '\\':tag ++ "{" ++attr ++ "}\n"
giveLn x =
 if length x == 0
 then x
 else if last x /= '\n'
      then x ++ "\n"
      else x

commentCoords [] [] result = result
commentCoords [] stack result = []
commentCoords (x:xs) stack result =
 if thd x == 0
 then commentCoords xs (x:stack) result
 else if length stack >= 1
      then commentCoords xs (tail stack) $ (head stack, x):result
      else []

getComments listings code =
 let
   generateLising ((b1, b2, _), (e1, e2, _)) =
    if length begin == 0
    then []
    else [id, name, strdata, desc]
    where
      beginText = subStr b1 b2 code
      (_, begin, _, atr) = (beginText =~ "{- BEGIN KEY = {([A-Za-z0-9]*)} NAME = {([A-Za-z0-9]*)}( DESCRIPTION = {([A-Za-z0-9\\ ]*)})? -}" :: (String, String, String, [String]))
      id = head atr
      name = atr !! 1
      desc = (atr++["",""]) !! 3
      strdata = subStr (b1 + b2 + 1) (e1 - (b1 + b2 + 1)) code
 in map generateLising listings

putImport lMap strdata =
 let
   coords = getAllMatches (strdata =~ import_reg) :: [(Int, Int)]
   n = length strdata
   translateImport dat (i1, i2) =
    let
      (_, _, _, [id]) = ((subStr i1 i2 strdata) =~ import_reg :: (String, String, String, [String]))
      getText [name, txt, desc] = concat $ ["\\begin{figure}[htb]\n", "\\footnotesize\n"]++ (getdsc desc)++[latexT "begin" "verbatim",txt, latexT "end" "verbatim",latexT "caption" name,latexT "end" "figure"]
      getdsc :: String -> [String]
      getdsc x =
       if length x == 0 
       then []
       else [x]
    in [getText $ Mb.fromMaybe [] $ Map.lookup id lMap] ++ dat
   setString result [] [] _ = result
   setString dat ((i1, i2):is) (x:xs) offset =
    let
      newA = (subStr 0 (i1 + offset) dat) ++ x ++ (subStr (i1 + offset + i2 + 1) (length dat) dat)
    in setString newA is xs $ offset + length x - i2 - 1
  in setString strdata coords (foldl translateImport [] coords) 0
monitorSym strdata = reverse $ foldl (\dat x ->reverse (case x of {
                                                                   '\\' -> "\\textbackslash";
                                                                   '№' -> "\\textnumero";
                                                                   '_' -> "\\_";
                                                                   '&' -> "\\&";
                                                                   '%' -> "\\%";
                                                                   '{' -> "\\{";
                                                                   '$' -> "\\$";
                                                                   '}' -> "\\}";
                                                                   x -> [x];
                                                                   }) ++
                                                        dat) [] strdata

monitorCodeWords strdata =
 let
   includeCodes = ["\\$SYSTEM_", "\\$IMPORT\\{","\\textbackslash", "\\textnumero", "\\_", "\\$", "\\&", "\\%", "\\{", "\\}"]
   check word = any (word =~) includeCodes
   checkCodeWords word = word =~ "[A-Za-z]" -- && (word=~"\\,\\.\\_\\;\\:^]"
   translateWord x =
    if check x
    then x
    else if checkCodeWords x
    then latexT "texttt" x
    else x
 in intercalate " " $ map translateWord $ splitOn " " strdata

monitorSystemWords strdata = codeText
 where
   codeText = foldl translateSystem strdata coords
   coords = getAllMatches (strdata =~ system_reg) :: [(Int, Int)]
   n = length strdata
   translateSystem dat (i1, i2) = (subStr 0 i1 dat) ++ (latexT "textsc" syst) ++ (subStr (i1 + i2 + 1) n dat)
       where
         (_, _, _, [syst]) = (subStr i1 i2 dat =~ system_reg :: (String, String, String, [String]))

thd (a, b, c) = c

subStr a b = (Data.List.take b).(Data.List.drop a)
printer [] = do return ()
printer (x:xs) = do
                   print x
                   printer xs

main :: IO ()
main = do
         let
             result = ("data/result.tex")
             dir = "data"
         labBmstu <- readFile $ dir++"/lab_report.bmstu"
         preambula <- readFile "data/preambula.txt"
         code <- readFile $ dir++"/code.hs"
         let dat = lines labBmstu
             [t, a, d, r, task, body, test] = list
             list = reverse $ getMetaData allTags dat []
             getText = concat [latexT "begin" "document", "\\maketitle\n", latexT "section" "Задача", giveLn $ toParse task, latexT "section" "Реализация", giveLn $ toParse body, latexT "section" "Тестирование", giveLn $ toParse test, latexT "end" "document"]
             begins = map (add3 0) $ (getAllMatches (code =~ "{- BEGIN KEY = {([A-Za-z0-9]*)} NAME = {([A-Za-z0-9]*)}( DESCRIPTION = {([A-Za-z0-9\\ ]*)})? -}") :: [(Int, Int)])
             ends = map (add3 1) $ (getAllMatches (code =~ "{- END -}") :: [(Int, Int)])
             add3 num (x, y) = (x, y, num)
             begintext = sortOn (\(a,b,c) -> a) $ begins ++ ends
             tupfst (a, b, c) = a
             coords = commentCoords begintext [] []
             checkComments = length coords == 0
             comments = getComments coords code
             lMap = Map.fromList $ map (\[a, b, c, d] -> (a, [b, withoutRules c, d])) comments
             beg = "{- BEGIN KEY = {([A-Za-z0-9]*)} NAME = {([A-Za-z0-9]*)}-}"
             end = "{- END-}"
             withoutRules x = intercalate "\n" $ filter (\x ->not (x =~ (end++"|"++beg))) $ splitOn "\n" x
             toParse x = putImport lMap $ monitorSystemWords $ monitorCodeWords $ monitorSym x
         if any (\x -> 0 == length x) comments
         then print $ id "Wrong comments"
         else do
                if not $ allUnique $ map (!!0) comments
                then print $ id "Comments have same id"
                else do
                        writeFile result $ preambula ++ "\n"
                        appendFile result $ latexT "title" t
                        appendFile result $ latexT "author" $ intercalate "\\\\" [a, "Группа: " ++ d, "Преподаватель: " ++ r]
                        appendFile result $ getText
--                        printer $ code !~ "{-BEGIN KEY = {([0-9]*)} NAME = {([A-Za-z0-9]*)}-}{-END-}-"
--                        print $ "aa..cqwcqww{}\n\raa" !~ "(.|[[:space:]])+"
--                        print lMap
--                        print $ (translateBsl task) /~ "\\$IMPORT\\\\{([A-Za-z0-9]*)\\\\}"
--                        print ("{Отчет по лабор}{аторной работе №5}" =~ "{(.)+}" :: String)