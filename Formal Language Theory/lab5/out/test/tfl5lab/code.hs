{- BEGIN_COM KEY = {0} NAME = {parseBodyLR}-}
parseBodyLR :: [[Char]] -> [[Char]] -> [[Char]] -> [[Char]]
parseBodyLR _ [] result = result
{- BEGIN_COM KEY = {1} NAME = {desc} DESC = {this term has description}-}
parseBodyLR [] _ _ = []
parseBodyLR (tag:tags) (w:ws) result
 | length w == 0 = parseBodyLR (tag:tags) ws result
{- END_COM-}
 | w /= tag = parseBodyLR (tag:tags) ws $ [(result !! 0) ++ " "++ w] ++ tail result
 | otherwise = parseBodyLR tags ws $ [""]++ result
{- END_COM-}
