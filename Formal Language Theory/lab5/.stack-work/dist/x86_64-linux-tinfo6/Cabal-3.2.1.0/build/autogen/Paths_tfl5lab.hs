{-# LANGUAGE CPP #-}
{-# LANGUAGE NoRebindableSyntax #-}
{-# OPTIONS_GHC -fno-warn-missing-import-lists #-}
module Paths_tfl5lab (
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

bindir     = "/home/kolldun/IdeaProjects/tfl5lab/.stack-work/install/x86_64-linux-tinfo6/6cd09ed90ea896299167473d65f99f8ffe0c21a4612fd1040bd6cde9d64ef0d3/8.10.7/bin"
libdir     = "/home/kolldun/IdeaProjects/tfl5lab/.stack-work/install/x86_64-linux-tinfo6/6cd09ed90ea896299167473d65f99f8ffe0c21a4612fd1040bd6cde9d64ef0d3/8.10.7/lib/x86_64-linux-ghc-8.10.7/tfl5lab-0.1.0.0-5SVTBIe8j9MEPZodG2DWYK"
dynlibdir  = "/home/kolldun/IdeaProjects/tfl5lab/.stack-work/install/x86_64-linux-tinfo6/6cd09ed90ea896299167473d65f99f8ffe0c21a4612fd1040bd6cde9d64ef0d3/8.10.7/lib/x86_64-linux-ghc-8.10.7"
datadir    = "/home/kolldun/IdeaProjects/tfl5lab/.stack-work/install/x86_64-linux-tinfo6/6cd09ed90ea896299167473d65f99f8ffe0c21a4612fd1040bd6cde9d64ef0d3/8.10.7/share/x86_64-linux-ghc-8.10.7/tfl5lab-0.1.0.0"
libexecdir = "/home/kolldun/IdeaProjects/tfl5lab/.stack-work/install/x86_64-linux-tinfo6/6cd09ed90ea896299167473d65f99f8ffe0c21a4612fd1040bd6cde9d64ef0d3/8.10.7/libexec/x86_64-linux-ghc-8.10.7/tfl5lab-0.1.0.0"
sysconfdir = "/home/kolldun/IdeaProjects/tfl5lab/.stack-work/install/x86_64-linux-tinfo6/6cd09ed90ea896299167473d65f99f8ffe0c21a4612fd1040bd6cde9d64ef0d3/8.10.7/etc"

getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath
getBinDir = catchIO (getEnv "tfl5lab_bindir") (\_ -> return bindir)
getLibDir = catchIO (getEnv "tfl5lab_libdir") (\_ -> return libdir)
getDynLibDir = catchIO (getEnv "tfl5lab_dynlibdir") (\_ -> return dynlibdir)
getDataDir = catchIO (getEnv "tfl5lab_datadir") (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "tfl5lab_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "tfl5lab_sysconfdir") (\_ -> return sysconfdir)

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir ++ "/" ++ name)
