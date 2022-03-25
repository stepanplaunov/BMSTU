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
import Data.List (foldl, intercalate, nub)
import Data.Text (drop)
import qualified Data.Text as Text


-------------------------------------SUPPORT_FUNCTIONS---------------------------------------------------
inList list x = any (==x) list
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

fromMbMap :: Maybe (Map k a) -> Map k a
fromMbMap x = (Mb.fromMaybe Map.empty) x
fromMbStr :: Maybe [Char] -> [Char]
fromMbStr x = (Mb.fromMaybe "") x

lookupMbMap :: Ord k1 => k1 -> Map k1 (Map k2 a) -> Map k2 a
lookupMbMap x mp = (fromMbMap $ Map.lookup x mp)

lookupMbStr :: Ord k => k -> Map k [Char] -> [Char]
lookupMbStr x mp = (fromMbStr $ Map.lookup x mp)


---------------------------------------TASK1---------------------------------------------------
--0.000460s
--0.004713s
--0.004333s
allMatches regex str =  unwords $ concat $ ggetbrsRegexPR regex str

printtest reg str name = do
  (t, x) <- timeItT $ putStrLn $ allMatches reg str
  printf ("%s: %6.6fs\n") name t

compareRegs i str = do
  putStrLn $ id "test"++ show i ++"---------------------------"
  printtest reg1 str "reg1"
  printtest reg2 str "reg2"
  printtest reg3 str "reg3"
  --timeItT $ putStrLn $ id allMatches reg2 str
  --timeItT $ putStrLn $ id allMatches reg3 str

testRunner :: Int -> [String] -> IO ()
testRunner i [] = do
                  return ()
testRunner i list = do
  compareRegs i $ head list
  testRunner (i + 1) $ tail list

reg1 = "</?[aA-zZ]+>"
reg2 = "</?[^0-9>,.!';% _\\|\\{\\}\\[\\]/]+>"
reg3 = "</?[aA-zZ>]+?>"

teststr = [
            "<p><b>asdsada</b>asdaasdasdadsad</p><a> </a><div></div>",
            "<aside id='secondary' class='widget-area'><section id='textblockswidget-2' class='widget widget_textblockswidget'><div class='text-block content-bottom'><div class='ad ad-300'><div data-type='ad' data-publisher='perltutorial.org' data-format='300x250' data-zone='content_bottom'></div></div></div></section><section id='search-4' class='widget widget_search'><form role='search' method='get' class='search-form' action='https://www.perltutorial.org/'> <label> <span class='screen-reader-text'>Search for:</span> <input type='search' class='search-field' placeholder='Search …' value='' name='s'> </label> <input type='submit' class='search-submit' value='Search'></form></section><section id='nav_menu-26' class='widget widget_nav_menu'><h2 class='widget-title'>Getting Started</h2><div class='menu-getting-started-container'><ul id='menu-getting-started' class='menu'><li id='menu-item-5911' class='menu-item menu-item-type-post_type menu-item-object-page menu-item-5911'><a href='https://www.perltutorial.org/introduction-to-perl/'>Introduction to Perl</a></li><li id='menu-item-5913' class='menu-item menu-item-type-post_type menu-item-object-page menu-item-5913'><a href='https://www.perltutorial.org/setting-up-perl-development-environment/'>Setting Up Perl Development Environment</a></li><li id='menu-item-5912' class='menu-item menu-item-type-post_type menu-item-object-page menu-item-5912'><a href='https://www.perltutorial.org/developing-the-first-perl-program/'>Developing the First Perl Program: Hello, World!</a></li></ul></div></section><section id='nav_menu-42' class='widget widget_nav_menu'><h2 class='widget-title'>Basic Perl Tutorial</h2><div class='menu-basic-perl-container'><ul id='menu-basic-perl' class='menu'><li id='menu-item-5914' class='menu-item menu-item-type-post_type menu-item-object-page menu-item-5914'><a href='https://www.perltutorial.org/perl-syntax/'>Perl Syntax</a></li><li id='menu-item-5915' class='menu-item menu-item-type-post_type menu-item-object-page menu-item-5915'><a href='https://www.perltutorial.org/perl-variables/'>Perl Variables</a></li><li id='menu-item-5916' class='menu-item menu-item-type-post_type menu-item-object-page menu-item-5916'><a href='https://www.perltutorial.org/perl-numbers/'>Perl Numbers</a></li><li id='menu-item-5917' class='menu-item menu-item-type-post_type menu-item-object-page menu-item-5917'><a href='https://www.perltutorial.org/perl-string/'>Perl String</a></li><li id='menu-item-5918' class='menu-item menu-item-type-post_type menu-item-object-page menu-item-5918'><a href='https://www.perltutorial.org/perl-operators/'>Perl Operators</a></li><li id='menu-item-5919' class='menu-item menu-item-type-post_type menu-item-object-page menu-item-5919'><a href='https://www.perltutorial.org/perl-list/'>Perl List</a></li><li id='menu-item-5920' class='menu-item menu-item-type-post_type menu-item-object-page menu-item-5920'><a href='https://www.perltutorial.org/perl-array/'>Perl Array</a></li><li id='menu-item-5921' class='menu-item menu-item-type-post_type menu-item-object-page menu-item-5921'><a href='https://www.perltutorial.org/perl-hash/'>Perl Hash</a></li><li id='menu-item-5922' class='menu-item menu-item-type-post_type menu-item-object-page menu-item-5922'><a href='https://www.perltutorial.org/perl-if/'>Perl if Statement</a></li><li id='menu-item-5923' class='menu-item menu-item-type-post_type menu-item-object-page menu-item-5923'><a href='https://www.perltutorial.org/perl-unless/'>Perl unless</a></li><li id='menu-item-5924' class='menu-item menu-item-type-post_type menu-item-object-page menu-item-5924'><a href='https://www.perltutorial.org/perl-given/'>Perl given</a></li><li id='menu-item-5925' class='menu-item menu-item-type-post_type menu-item-object-page menu-item-5925'><a href='https://www.perltutorial.org/perl-for-loop/'>Perl for Loop</a></li><li id='menu-item-5926' class='menu-item menu-item-type-post_type menu-item-object-page menu-item-5926'><a href='https://www.perltutorial.org/perl-while/'>Perl while Loop</a></li><li id='menu-item-5927' class='menu-item menu-item-type-post_type menu-item-object-page menu-item-5927'><a href='https://www.perltutorial.org/perl-do-while/'>Perl do while</a></li><li id='menu-item-5928' class='menu-item menu-item-type-post_type menu-item-object-page menu-item-5928'><a href='https://www.perltutorial.org/perl-until/'>Perl until Statement</a></li><li id='menu-item-5929' class='menu-item menu-item-type-post_type menu-item-object-page menu-item-5929'><a href='https://www.perltutorial.org/perl-do-until/'>Perl do…until Statement</a></li><li id='menu-item-5930' class='menu-item menu-item-type-post_type menu-item-object-page menu-item-5930'><a href='https://www.perltutorial.org/perl-next/'>Perl next Statement</a></li><li id='menu-item-5931' class='menu-item menu-item-type-post_type menu-item-object-page menu-item-5931'><a href='https://www.perltutorial.org/perl-last/'>Perl last Statement</a></li><li id='menu-item-5932' class='menu-item menu-item-type-post_type menu-item-object-page menu-item-5932'><a href='https://www.perltutorial.org/perl-reference/'>Perl Reference</a></li><li id='menu-item-5933' class='menu-item menu-item-type-post_type menu-item-object-page menu-item-5933'><a href='https://www.perltutorial.org/perl-subroutine/'>Perl Subroutine</a></li><li id='menu-item-5934' class='menu-item menu-item-type-post_type menu-item-object-page menu-item-5934'><a href='https://www.perltutorial.org/perl-module/'>Perl Module</a></li><li id='menu-item-5935' class='menu-item menu-item-type-post_type menu-item-object-page menu-item-5935'><a href='https://www.perltutorial.org/perl-oop/'>Perl OOP</a></li><li id='menu-item-5936' class='menu-item menu-item-type-post_type menu-item-object-page menu-item-5936'><a href='https://www.perltutorial.org/perl-dbi/'>Perl DBI</a></li><li id='menu-item-5937' class='menu-item menu-item-type-post_type menu-item-object-page menu-item-5937'><a href='https://www.perltutorial.org/perl-sort/'>Perl Sort</a></li></ul></div></section><section id='textblockswidget-4' class='widget widget_textblockswidget'><div class='text-block sidebar-middle'><div class='ad ad-300'><div data-type='ad' data-publisher='perltutorial.org' data-format='300x250' data-zone='sidebar_middle'><div style='height: 250px; width: 300px; box-sizing: border-box; border: 0px none; font-size: 0px;' id='div-gpt-ad-perltutorial.org/sidebar_middle-4' data-google-query-id='COOZvcPVp_UCFU9FwgodV_cAdA'><div id='google_ads_iframe_/6839/perltutorial.org/sidebar_middle_0__container__' style='border: 0pt none;'><iframe id='google_ads_iframe_/6839/perltutorial.org/sidebar_middle_0' title='3rd party ad content' name='google_ads_iframe_/6839/perltutorial.org/sidebar_middle_0' scrolling='no' marginwidth='0' marginheight='0' style='border: 0px none; vertical-align: bottom;' role='region' aria-label='Advertisement' tabindex='0' sandbox='allow-forms allow-popups allow-popups-to-escape-sandbox allow-same-origin allow-scripts allow-top-navigation-by-user-activation' srcdoc='' data-google-container-id='1' data-load-complete='true' width='300' height='250' frameborder='0'></iframe></div><input type='image' src='https://cdn1.developermedia.com/Content/images/undo.png' title='Report Ad' style='z-index: 1000; position: relative; left: 0px; top: -250px; margin-top: 0px; margin-left: 0px; display: block; font-size: 0px; border: 0px none; padding: 0px; height: 14px; width: 14px;' align='left'></div><div style='display: none; width: 300px; height: 250px; z-index: 100; text-align: left; border-style: solid; border-width: 1px; position: relative; background-color: white; box-sizing: border-box; top: 0px; left: 0px;'><input type='image' src='https://cdn1.developermedia.com/Content/images/redo.png' title='Show Ad' style='z-index: 1000; position: relative; left: 0px; top: 0px; width: 14px; height: 14px; margin-top: 0px; margin-left: 0px; font-size: 0px; display: block; padding: 0px; border: 0px none;'><div class='sendReportContainer' style='padding: 5px 5px; display:block; line-height:initial !important'><div style='padding-bottom:5px; font:14px/18px &quot;Segoe UI&quot;, Arial;'><b>Don't like this Ad?</b></div><div class='dropzone' style='height:100px; width: 290px; margin-top:20px; margin-bottom: 20px; background-color:lightgray; border-style:dotted; border-color:black; border-radius: 5px; border-width: 2px; text-align: center; box-sizing:border-box; white-space:normal' contenteditable='true'>1. Hit the refresh icon to show the ad again so you can take a screenshot <br>2. Drag and Drop or paste the screenshot here</div><div style='margin-top:5px; font:14px/18px &quot;Segoe UI&quot;, Arial; '> <select class='reportReason' style='max-width:150px !important; padding: 0px !important'><option>Offensive</option><option>Abusive</option><option>Off topic</option><option>Don't like the Ad</option> <option>Wrong language</option></select> </div><div style='margin-top:5px; display:block; font:14px/18px &quot;Segoe UI&quot;, Arial;'><input type='button' disabled='' class='reportButton' style='padding: 0px !important' value='Report'></div></div><div class='reportSentContainer' style='display:none; padding: 15px 20px; font:14px/18px &quot;Segoe UI&quot;, Arial; '><span style='color:#999;'>Thank you for the report!</span></div><a href='http://www.developermedia.com/' target='_blank'><img src='https://cdn1.developermedia.com/Content/images/dm-logo-150x23.png' style='max-width:100%;position:absolute; right:20px; bottom:10px;'></a></div></div></div></div></section><section id='nav_menu-43' class='widget widget_nav_menu'><h2 class='widget-title'>Perl I/O</h2><div class='menu-perl-io-container'><ul id='menu-perl-io' class='menu'><li id='menu-item-5939' class='menu-item menu-item-type-post_type menu-item-object-page menu-item-5939'><a href='https://www.perltutorial.org/perl-open-file/'>Perl Open File</a></li><li id='menu-item-5940' class='menu-item menu-item-type-post_type menu-item-object-page menu-item-5940'><a href='https://www.perltutorial.org/perl-read-file/'>Perl Read File</a></li><li id='menu-item-5941' class='menu-item menu-item-type-post_type menu-item-object-page menu-item-5941'><a href='https://www.perltutorial.org/perl-write-to-file/'>Perl Write to File</a></li><li id='menu-item-5942' class='menu-item menu-item-type-post_type menu-item-object-page menu-item-5942'><a href='https://www.perltutorial.org/perl-file-test-operators/'>Perl File Test Operators</a></li></ul></div></section><section id='textblockswidget-3' class='widget widget_textblockswidget'><div class='text-block sidebar-bottom'><div class='ad ad-300'><div data-type='ad' data-publisher='perltutorial.org' data-format='300x250' data-zone='sidebar_bottom'><div style='height: 250px; width: 300px; box-sizing: border-box; border: 0px none; font-size: 0px;' id='div-gpt-ad-perltutorial.org/sidebar_bottom-5' data-google-query-id='CPyE1cPVp_UCFUFGHgIdjIkGyg'><div id='google_ads_iframe_/6839/perltutorial.org/sidebar_bottom_0__container__' style='border: 0pt none;'><iframe id='google_ads_iframe_/6839/perltutorial.org/sidebar_bottom_0' title='3rd party ad content' name='google_ads_iframe_/6839/perltutorial.org/sidebar_bottom_0' scrolling='no' marginwidth='0' marginheight='0' style='border: 0px none; vertical-align: bottom;' role='region' aria-label='Advertisement' tabindex='0' sandbox='allow-forms allow-popups allow-popups-to-escape-sandbox allow-same-origin allow-scripts allow-top-navigation-by-user-activation' srcdoc='' data-google-container-id='2' data-load-complete='true' width='300' height='250' frameborder='0'></iframe></div><input type='image' src='https://cdn1.developermedia.com/Content/images/undo.png' title='Report Ad' style='z-index: 1000; position: relative; left: 0px; top: -250px; margin-top: 0px; margin-left: 0px; display: block; font-size: 0px; border: 0px none; padding: 0px; height: 14px; width: 14px;' align='left'></div><div style='display: none; width: 300px; height: 250px; z-index: 100; text-align: left; border-style: solid; border-width: 1px; position: relative; background-color: white; box-sizing: border-box; top: 0px; left: 0px;'><input type='image' src='https://cdn1.developermedia.com/Content/images/redo.png' title='Show Ad' style='z-index: 1000; position: relative; left: 0px; top: 0px; width: 14px; height: 14px; margin-top: 0px; margin-left: 0px; font-size: 0px; display: block; padding: 0px; border: 0px none;'><div class='sendReportContainer' style='padding: 5px 5px; display:block; line-height:initial !important'><div style='padding-bottom:5px; font:14px/18px &quot;Segoe UI&quot;, Arial;'><b>Don't like this Ad?</b></div><div class='dropzone' style='height:100px; width: 290px; margin-top:20px; margin-bottom: 20px; background-color:lightgray; border-style:dotted; border-color:black; border-radius: 5px; border-width: 2px; text-align: center; box-sizing:border-box; white-space:normal' contenteditable='true'>1. Hit the refresh icon to show the ad again so you can take a screenshot <br>2. Drag and Drop or paste the screenshot here</div><div style='margin-top:5px; font:14px/18px &quot;Segoe UI&quot;, Arial; '> <select class='reportReason' style='max-width:150px !important; padding: 0px !important'><option>Offensive</option><option>Abusive</option><option>Off topic</option><option>Don't like the Ad</option> <option>Wrong language</option></select> </div><div style='margin-top:5px; display:block; font:14px/18px &quot;Segoe UI&quot;, Arial;'><input type='button' disabled='' class='reportButton' style='padding: 0px !important' value='Report'></div></div><div class='reportSentContainer' style='display:none; padding: 15px 20px; font:14px/18px &quot;Segoe UI&quot;, Arial; '><span style='color:#999;'>Thank you for the report!</span></div><a href='http://www.developermedia.com/' target='_blank'><img src='https://cdn1.developermedia.com/Content/images/dm-logo-150x23.png' style='max-width:100%;position:absolute; right:20px; bottom:10px;'></a></div></div></div></div></section></aside>",
            "<tfltag></tfltag><tagwithparam class=paramclass></tagwithparam> ",
            "<div class='vcVZ7d' id='gws-output-pages-elements-homepage_additional_languages__als'><style>#gws-output-pages-elements-homepage_additional_languages__als{font-size:small;margin-bottom:24px}#SIvCob{color:#3c4043;display:inline-block;line-height:28px;}#SIvCob a{padding:0 3px;}.H6sW5{display:inline-block;margin:0 2px;white-space:nowrap}.z4hgWe{display:inline-block;margin:0 2px}</style></div>",
            "<div id='SIvCob'>Сервисы Google доступны на разных языках:  <a href='https://www.google.com/setprefs?sig=0_ZrUar9vI15mxb8PZBakQjVVSsRU%3D&amp;hl=en&amp;source=homepage&amp;sa=X&amp;ved=0ahUKEwj0odS15Kf1AhXHtYsKHX-tDEEQ2ZgBCA0'>English</a>  </div>",
            "<head><meta charset='UTF-8'><meta content='origin' name='referrer'><meta content='/images/branding/googleg/1x/googleg_standard_color_128dp.png' itemprop='image'><link href='/manifest?pwa=webhp' crossorigin='use-credentials' rel='manifest'><title>Google</title>",
            "<div id='back-to-top' class=''><svg viewBox='0 0 24 24'><path d='M7.41 15.41L12 10.83l4.59 4.58L18 14l-6-6-6 6z'></path></svg></div>",
            "<header id='masthead' class='site-header'><div class='wrap header-wrapper'><div class='site-branding'> <a href='https://www.perltutorial.org' rel='home' aria-current='page' class='logo' aria-label='Go to the homepage'> </a></div><nav id='site-navigation' class='site-navigation'><ul id='primary-menu' class='site-menu'><li id='menu-item-5910' class='menu-item menu-item-type-post_type menu-item-object-page menu-item-home menu-item-5910'>",
            "<div class='site-footer-sidebar widget'><h2 class='widget-title'>Site Links</h2><div class='menu-about-container'><ul id='menu-about' class='menu'><li id='menu-item-5972' class='menu-item menu-item-type-post_type menu-item-object-page menu-item-5972'><a title='About Us' href='https://www.perltutorial.org/about/'>About Us</a></li><li id='menu-item-5967' class='menu-item menu-item-type-post_type menu-item-object-page menu-item-5967'><a href='https://www.perltutorial.org/contact-us/'>Contact Us</a></li><li id='menu-item-5968' class='menu-item menu-item-type-post_type menu-item-object-page menu-item-5968'><a href='https://www.perltutorial.org/perl-resources/'>Perl Resources</a></li><li id='menu-item-5966' class='menu-item menu-item-type-post_type menu-item-object-page menu-item-5966'><a href='https://www.perltutorial.org/privacy-policy/'>Privacy Policy</a></li></ul></div></div>",
             concat $ concatMap (replicate 10000) ["<div id='a'>","<style id='b'>","<h id='c'>"]]


-------------------------------------TASK2---------------------------------------------------
linesChecker :: Foldable t => t [Char] -> [Char]
linesChecker list = foldl equChecker "True" list
 where equChecker acum equ
        | acum /= "True" = acum
        | (length equ) <= 2 = "small length of expression"
        | not $ checkAZ $ head equ = "wrong variable name"
        | equ !! 1 /= '=' = "equation doesn't have '='"
        | length terms == 0 = "wrong amount of terms in expression"
        --  not checklast = "wrong const"
        | checkterms /= "Right" = checkterms
        | not $ foldl (||) False $ map checkRegex terms = "need const"
        | otherwise = "True"
        where
          right = tail $ tail equ
          terms = splitOn "+" right
          checkterms = (foldl checkTerm "Right" terms)
          checklast = checkRegex $ last terms
       checkTerm acum term
        | acum /= "Right" = acum
        | (length term) < 1 = "small length of term"
        | (length term == 1) && (checkAZ $ last term) = "variables without coeficient not allowed"
        | not $ checkRegex $ rightterm = "wrong term"
        | otherwise = "Right"
        where
          rightterm
           | not $ checkAZ $ last term =  term
           | otherwise=reverse $ tail $ reverse term
       checkRegex ('(':termxs)
        | last termxs /= ')' = False
        | otherwise = foldl (&&) True $ map checkConst consts
        where 
          consts = splitOn "|" $ tail $ reverse termxs
       checkRegex term = checkConst term
       checkConst const
        | null const = False
        | otherwise = foldl (&&) True $ map checkaz const

varCycle :: (Map String (Map String String)) -> (Map String String) -> [String] -> [String] -> ((Map String (Map String String)), (Map String String))
varCycle eqD lasts [] _ = (eqD, lasts)
varCycle eqD lasts (var:vars) variables = varCycle eqD1 lasts1 vars variables
  where
    (newEqD, newLasts) = translateVar var eqD lasts
    add z chelem = translateAll var (fst z) (snd z) chelem
    (eqD1, lasts1) = foldl add (newEqD, newLasts) variables

translateVar :: String -> (Map String (Map String String)) -> (Map String String) -> ((Map String (Map String String)), (Map String String))
translateVar var eqD lasts
 | (element var keys) = (Map.adjust boo var eqDwithoutVar, lastsresult)
 | otherwise = (eqD, lasts)
 where
 coef = (addBr c)
 boo x = (Map.map (coef ++) x)
 lastsresult
           | (length keys) == 1 = insert var c lasts
           | otherwise = lasts
 dict = lookupMbMap var eqD
 c = lookupMbStr var dict
 eqDwithoutVar = Map.adjust foo var eqD
 foo x = (Map.delete var x)
 keys = Map.keys dict
 addBr xs
  | (last xs) == ')' = xs++"*"
  | otherwise = "("++xs++")*"

element :: Eq a => a -> [a] -> Bool
element x y = (notN $ filter (==x) y)
translateAll :: String -> (Map String (Map String String)) -> (Map String String) -> String -> ((Map String (Map String String)), (Map String String))
translateAll var eqD lasts chelem
  | (var /= chelem) &&
    (elem var keyschelem)=
       (
       insert chelem (Map.delete var change) eqD,
       lastsresult change
       )
  | otherwise = (eqD, lasts)
  where
    dictvar = lookupMbMap var eqD
    keysvar = Map.keys dictvar
    dictchelem = lookupMbMap chelem eqD
    keyschelem = Map.keys dictchelem
    change = foldl ch dictchelem keysvar
    lastsresult equmap
              | (length $ Map.keys equmap) == 1 = insert chelem (lookupMbStr var equmap) lasts
              | otherwise = lasts
    ch mp item = insert item value mp
      where
        keysch = Map.keys mp
        check2 = (element item keysch)
        check1 = check2 && (notN markitem) && (notN expr)
        expr = lookupMbStr item dictvar
        markitem = lookupMbStr item mp
        markvar = lookupMbStr var mp
        value
          | check1 = "("++markitem++"+"++markvar++expr++")"
          | check2 = markitem++"+"++markvar++expr
          | otherwise = markvar++expr

notN :: Foldable t => t a -> Bool
notN x = (not $ null x)

parseEquations :: [[Char]] -> Map [Char] a1 -> t -> [[Char]] -> ([[Char]] -> Map k a2 -> t -> (a1, t)) -> (Map [Char] a1, t, [[Char]])
parseEquations [] equDict varsCoef vars _ = (equDict, varsCoef, vars)
parseEquations (equ:xs) equDict varsCoef vars parseTermFunction =
  parseEquations xs newEquDict newVarsCoefs newVars parseTermFunction
  where
    [variable, equation] = splitOn "=" equ
    terms = splitOn "+" equation
    (newCoef, newVarsCoefs) = parseTermFunction terms Map.empty varsCoef
    newEquDict = (insert variable newCoef equDict)
    newVars = vars ++ [variable]

(<?) :: Ord a => a -> (a,a) -> Bool
(<?) x (min, max) = x >= min && x <= max

parseTerms :: [String] -> (Map String String) -> [String] -> ((Map String String), [String])
parseTerms [] coefs varsCoefs = (coefs, varsCoefs)
parseTerms (term:terms) coefs varsCoefs =
 parseTerms terms newCoef newVarsCoefs
 where
  lst = last term
  checker = checkAZ lst
  newCoef
    | checker = (insert [lst] (take (length term - 1) term) coefs)
    | term /= "" = (insert "const" term coefs)
    | otherwise = coefs
  newVarsCoefs
   | checker = varsCoefs ++ [[lst]]
   | otherwise = varsCoefs

deleteDuplicates :: (Foldable t, Eq a) => [a] -> t a -> Bool
deleteDuplicates vc var = not $ null $ filter (`notElem` var) vc


-------------------------------------TASK3---------------------------------------------------
stringToDfa :: [Char] -> ([[Char]], [Char], Map [Char] (Map [Char] [Char]), [[Char]])
stringToDfa str = dfa
 where
   entities = map (filter (`notElem` "{}")) $ splitOn ",{" str
   fin = splitOn "," $ filter (/='>') $ entities !! 2
   sta = filter (/='<') $ entities !! 0
   edges = map (splitOn ",") $ map (filter (`notElem`"><")) $ splitOn "><" $ entities !! 1
   alp = nub $ map (!! 1) edges
   states = foldl addEdge Map.empty edges
   addEdge acum [st, sym, dir]
    | Map.notMember st acum = insert st (Map.fromList [(sym, dir)]) acum
    | otherwise = insert st (insert sym dir $ lookupMbMap st acum) acum
   dfa = (fin, sta, states, alp)

dfaToEquations :: Map a (Map [Char] [Char]) -> [(a, [Char])]
dfaToEquations edges = equ
 where
   equ = map equations $ result
   result = map terms $ Map.assocs edges
   terms (q, edges) = (q, foldl toTerms emp $ Map.assocs edges)
   toTerms acum (sym, dir)
    | Map.notMember dir acum = insert dir [sym] acum
    | otherwise = Map.adjust (++ [sym]) dir acum
   equations (q, mass) = (q, tail (foldl toEquations ""$ Map.assocs mass))
   toEquations acum (var, exp)
    | length exp == 1 = acum++ "+" ++ (head exp) ++var
    | length exp > 1 = acum++"+" ++"(" ++ (intercalate "|" exp)++")" ++var

addCoefsFinals :: [(a, [Char])] -> [[Char]] -> [(a, [Char])]
addCoefsFinals equ fin  = result
 where
   result = map (coefsForFinal . consts) equ
   consts (q, exp) = (q, exp, foldl toConsts [] terms)
    where
     terms = splitOn "+" exp
   toConsts acum term
    | (ord lst <? (65, 90)) && (notN $ filter (==[lst]) fin) = acum ++ [tail1]
    | (ord lst <? (48, 57)) && (notN $ filter (==lst2)  fin) = acum ++[tail2]
    | otherwise = acum
    where
     lst = last term
     lst2 = reverse $ take 2 (reverse term)
     n = length term
     tail1 = take (n - 1) term
     tail2 = take (n - 2) term
   coefsForFinal (q, exp, coefs)
    | (length coefs) == 1 = (q, exp++"+"++head coefs)
    | (length coefs) > 1 = (q, exp++"+(" ++ (intercalate "|" coefs)++")")
    |otherwise = (q, exp)

parseTermsForDfa :: [String] -> (Map String String) -> [String] -> ((Map String String), [String])
parseTermsForDfa [] coefs varsWithCoefs= (coefs, varsWithCoefs)
parseTermsForDfa (term:terms) coefs varsWithCoefs =
 parseTermsForDfa terms newCoef newVarsWithCoefs
 where
  lst = last term
  checker = checkAZ lst
  checkerForInt = (ord lst) <? (48, 57)
  pair = reverse $ take 2 $ reverse term
  ins i = (insert [lst] (take (length term - i) term) coefs)
  newCoef
   | checker = ins 1
   | checkerForInt = (insert pair (take (length term - 2) term) coefs)
   | term /= "" = (insert "const" term coefs)
   | otherwise = coefs
  newVarsWithCoefs
   | checker = varsWithCoefs ++ [[lst]]
   | checkerForInt = varsWithCoefs ++ [pair]
   | otherwise = varsWithCoefs
   where n = length term

dfs :: (Foldable t, Ord a1) => Map a1 (Map a2 a1) -> t a1 -> a1 -> Bool
dfs dfa fin current
 | Map.notMember current dfa = False
 | otherwise = any (==current) fin || (foldl (||) False $ map (dfs newdfa fin) vertex)
 where
   newdfa = Map.delete current dfa
   vertex = map (snd) $ Map.assocs $ lookupMbMap current dfa

checkDfaEdges :: Foldable t => (a1, b, Map a2 (Map k a3), t a4) -> Bool
checkDfaEdges (_, _, edges, alp) = foldl (&&) True $ map edgeschecker $ Map.assocs edges
 where
   nalp = length alp
   edgeschecker (_, x) = (==) nalp $length $ Map.assocs x

checkDfaTraps :: (Foldable t, Ord k) => Map k (Map a2 k) -> t k -> Bool
checkDfaTraps dfa fin = foldl (&&) True $ map (dfs dfa fin) $ Map.keys dfa


-------------------------------------TASK_RUNNERS---------------------------------------------------
task1 :: IO ()
task1 = do
          testRunner 1 teststr
task2 :: IO ()
task2 = do

          content <- readFile "test/test2.txt"
          let fil = filter (`notElem` " \n")
              linesdata = map fil $ filter (/="") $ lines content
              check = linesChecker linesdata
              (maper, varsCoefs, variables) = parseEquations linesdata Map.empty [] [] (parseTerms)
              notEveryoneExists = deleteDuplicates varsCoefs variables
              vars = Map.keys $ maper
              (eq, lasts) = varCycle maper Map.empty vars vars
              result = map resultForVar $ Map.assocs eq
              resultForVar (var, _)
                | (Map.member "const" vardict) = var++" = "++(lookupMbStr "const" vardict)
                | otherwise = var++" = "++(lookupMbStr var lasts)
                where
                vardict = lookupMbMap var eq
              runner
                | check /= "True" = putStrLn $ id "Syntax error: "++check
                | notEveryoneExists = do
                                putStrLn $ id "There is a variable that has no expression"
                                return ()
                | otherwise = do
                                printerln result
                                return ()
          runner

task3 :: IO ()
task3 = do
          content <- readFile "test/test3.txt"
          let fil = filter (`notElem` " \n")
              input = foldl (++) "" $ map fil $ filter (/="") $ lines content
              dfa = stringToDfa input
              (fin, sta, edges, _) = dfa
              ter = dfaToEquations edges
              ---добавляем в выражение коефициенты при финальных переменных---
              finalEqu = addCoefsFinals ter fin
              equations = map comp finalEqu
               where comp z = (fst z)++"="++(snd z)
--              finalExp = map snd $ filter inFin finalEqu
--              inFin (q, exp) = notN $ filter (==q) fin
--              -------equation system solver part (task2)-------
              (maper, _, _) = parseEquations equations Map.empty [] [] parseTermsForDfa
              ---создаем порядок прохода по переменным---
              order = [sta]++(filter (\x -> not $ inList (fin++[sta]) x) $ map fst ter)++fin
              --notEveryoneExists = deleteDuplicates varsCoefs variables
              vars = Map.keys $ maper
              (eq, lasts) = varCycle maper Map.empty order vars
              result = map resultForVar $ Map.assocs eq
               where
               resultForVar (var, _)
                | var == sta = var++" = "++(lookupMbStr "const" vardict) ++ " result"
                | (Map.member "const" vardict) = var++" = "++(lookupMbStr "const" vardict)
                | otherwise = var++" = "++(lookupMbStr var lasts)
                where vardict = lookupMbMap var eq
              runner
                | not $ checkDfaEdges dfa = do
                                putStrLn $ id "Dfa doesn't have ways for every symbol in alphabet"
                                return ()
                | not $ checkDfaTraps edges fin = do
                                putStrLn $ id "Dfa have trap state"
                                return ()
                | otherwise = do
                                printerln result
                                return ()
          runner

printer [] = do return ()
printer ((x, y):xs) = do
                      print $ x
                      print $ y
                      printer xs
main :: IO ()
main = do
          putStrLn $ id "Task 1"
          task1
          putStrLn $ id "Task 2"
          task2
          putStrLn $ id "Task 3"
          task3