{-# LANGUAGE OverloadedStrings #-}

module Graphvis where

import Data.Graph.Inductive
import Data.GraphViz
import Data.GraphViz.Attributes.Complete
import Data.GraphViz.Types.Generalised   as G
import Data.GraphViz.Types.Monadic
import Data.Text.Lazy                    as L
import Data.Word
import WriteRunDot
import qualified Data.List as DL
import Data.List (nub, foldl)
import Data.Map (Map, insert)
import qualified Data.Map as Map
import Data.Maybe (Maybe)
import qualified Data.Maybe as Mb
import qualified Data.Text as T

ex1Params :: GraphvizParams b L.Text L.Text () L.Text
ex1Params = nonClusteredParams { globalAttributes = ga
                               , fmtNode          = fn
                               , fmtEdge          = fe
                               }
  where fn (_,l)   = [textLabel l]
        fe (_,_,l) = [textLabel l]

        ga = [ GraphAttrs [ RankDir   FromLeft
                          , BgColor   [toWColor White]
                          ]
             , NodeAttrs  [ shape     BoxShape
                          ]
             ]

dictList states = snd $ DL.foldl (\(i, acum) x -> (i + 1, acum ++ [(x,i)])) (1, []) states
names state = DL.map swap $ dictList state
dict state =  Map.fromList $ dictList state

edg state transitions = DL.map toEdge transitions
 where
  toEdge [q1, letter, st1, q2, st2] = (lookupMbInt q1 d, lookupMbInt q2 d, pack $ letter++","++st1++"/"++st2)
  d = dict state
ex2 :: [String] -> [[String]] -> Gr Text Text
ex2 state transitions = mkGraph (names $ DL.map pack state) (edg state transitions)

fromMbInt x = (Mb.fromMaybe 0) x
lookupMbInt x mp = (fromMbInt $ Map.lookup x mp)
swap x = (snd x, fst x)

run :: (a, b, [[String]], [String]) -> IO ()
run g = do
          let
            (state, bottom, transitions, states) = g
          doDots [ ("dpda" , graphToDot ex1Params $ ex2 states transitions)]
