{-# LANGUAGE CPP #-}
{-# LANGUAGE NoRebindableSyntax #-}
{-# OPTIONS_GHC -fno-warn-missing-import-lists #-}
module Paths_tfl4lab (
    version,
    getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir,
    getDataFileName, getSysconfDir
  ) where

import qualified Control.Exception as Exception
import Data.Version (Version(..))
import System.Environment (getEnv)
import Prelude

#if defined(VERSION_base)

#if MIN_VERSION_base(4,0,0)
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#else
catchIO :: IO a -> (Exception.Exception -> IO a) -> IO a
#endif

#else
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#endif
catchIO = Exception.catch

version :: Version
version = Version [0,1,0,0] []
bindir, libdir, dynlibdir, datadir, libexecdir, sysconfdir :: FilePath

bindir     = "/home/kolldun/IdeaProjects/tfl4lab/.stack-work/install/x86_64-linux-tinfo6/e2c73f9133758b4e1416c106ad0eb2fcec9eb914674541a20489a4f094836032/8.10.7/bin"
libdir     = "/home/kolldun/IdeaProjects/tfl4lab/.stack-work/install/x86_64-linux-tinfo6/e2c73f9133758b4e1416c106ad0eb2fcec9eb914674541a20489a4f094836032/8.10.7/lib/x86_64-linux-ghc-8.10.7/tfl4lab-0.1.0.0-8SJFGSBL46VK7DgDYs0tEl"
dynlibdir  = "/home/kolldun/IdeaProjects/tfl4lab/.stack-work/install/x86_64-linux-tinfo6/e2c73f9133758b4e1416c106ad0eb2fcec9eb914674541a20489a4f094836032/8.10.7/lib/x86_64-linux-ghc-8.10.7"
datadir    = "/home/kolldun/IdeaProjects/tfl4lab/.stack-work/install/x86_64-linux-tinfo6/e2c73f9133758b4e1416c106ad0eb2fcec9eb914674541a20489a4f094836032/8.10.7/share/x86_64-linux-ghc-8.10.7/tfl4lab-0.1.0.0"
libexecdir = "/home/kolldun/IdeaProjects/tfl4lab/.stack-work/install/x86_64-linux-tinfo6/e2c73f9133758b4e1416c106ad0eb2fcec9eb914674541a20489a4f094836032/8.10.7/libexec/x86_64-linux-ghc-8.10.7/tfl4lab-0.1.0.0"
sysconfdir = "/home/kolldun/IdeaProjects/tfl4lab/.stack-work/install/x86_64-linux-tinfo6/e2c73f9133758b4e1416c106ad0eb2fcec9eb914674541a20489a4f094836032/8.10.7/etc"

getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath
getBinDir = catchIO (getEnv "tfl4lab_bindir") (\_ -> return bindir)
getLibDir = catchIO (getEnv "tfl4lab_libdir") (\_ -> return libdir)
getDynLibDir = catchIO (getEnv "tfl4lab_dynlibdir") (\_ -> return dynlibdir)
getDataDir = catchIO (getEnv "tfl4lab_datadir") (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "tfl4lab_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "tfl4lab_sysconfdir") (\_ -> return sysconfdir)

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir ++ "/" ++ name)
